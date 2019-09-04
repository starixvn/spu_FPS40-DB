/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Device$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Device(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	
	DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
	DECLARE DeviceStatusNew			TINYINT DEFAULT 1;			# New Device
	DECLARE DeviceStatusOld			TINYINT DEFAULT 2;			# Old Device
	DECLARE DeviceStatusRecover		TINYINT DEFAULT 3;			# Recover Device
    DECLARE i 						INT Default 1;
    DECLARE n 						INT;
    DECLARE vr_StagingTransID			INT; 
    DECLARE vr_SubscriberID				INT;
    DECLARE vr_AccountID 				INT; 
    DECLARE vr_DeviceCode 				VARCHAR(32);
	DECLARE vr_FingerprintCode 			VARCHAR(640);
    DECLARE	vr_GroupDevice				BIGINT;
	DECLARE	vr_CreatedDate				DATETIME;
	
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_Device' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    ### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
    CREATE TEMPORARY TABLE Temp_Transaction 
    (	
		StagingTransID		BIGINT
		, LoginName			VARCHAR(50)   
        , DeviceCode		VARCHAR(32)
        , FingerprintCode		VARCHAR(640)
        , FingerprintMoreInfo	TEXT
        , UserAgentCode		VARCHAR(32)
        , PluginID			INT
        , CreatedDate		DATETIME
        , TransDate			DATETIME
        
        , AccountID			BIGINT
        , SubscriberID		INT
        , SubscriberPrefix	VARCHAR(30)
        , IsDeposit			TINYINT
        , DeviceID			INT
        , DeviceFingerprintID INT
        , MergedFingerprintCode	VARCHAR(600)
        , GroupDeviceByCode	BIGINT
        , GroupDevice		BIGINT
    );
    
      DROP TEMPORARY TABLE IF EXISTS Temp_Transaction2;
    CREATE TEMPORARY TABLE Temp_Transaction2 
    (	
		StagingTransID		BIGINT
		, LoginName			VARCHAR(50)
        , DeviceCode		VARCHAR(32)
        , FingerprintCode		VARCHAR(640)
        , FingerprintMoreInfo	TEXT
        , UserAgentCode		VARCHAR(32)
        , PluginID			INT
        , CreatedDate		DATETIME
        , TransDate			DATETIME
        
        , AccountID			BIGINT
        , SubscriberID		INT
        , SubscriberPrefix	VARCHAR(30)
        , IsDeposit			TINYINT
        , DeviceID			INT
        , DeviceFingerprintID INT
        , MergedFingerprintCode	VARCHAR(600)
        , GroupDeviceByCode	BIGINT
        , GroupDevice		BIGINT
    );
    
    #==================================================================
	DROP TEMPORARY TABLE IF EXISTS Temp_AccountDevice;
    CREATE TEMPORARY TABLE Temp_AccountDevice 
    (		
		AccountID			BIGINT
        , DeviceID			BIGINT
        , DeviceCode		VARCHAR(32)
        , DeviceFingerprint	TEXT
        , CreatedDate		DATETIME
    );
    
    #==================================================================  
    INSERT INTO Temp_Transaction (StagingTransID, LoginName, AccountID, DeviceCode, FingerprintCode, FingerprintMoreInfo
				, UserAgentCode, PluginID, CreatedDate, TransDate,  SubscriberID, SubscriberPrefix, IsDeposit, DeviceID)
    SELECT		rt.StagingTransID
				, rt.LoginName
                , ac.AccountID
                , rt.DeviceCode
                , rt.FingerprintCode
                , rt.FingerprintMoreInfo
                , MD5(rt.UserAgent)
                , rt.PluginID
                , rt.CreatedDate
                , rt.TransDate                
                , su.SubscriberId
                , su.SubscriberPrefix
                , su.IsDeposit
                , dc.DeviceID
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber su
				ON rt.SubscriberName = su.SubscriberName
	INNER JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_Account_SubscriberID_FirstLoginName_UserName_Username2)
			ON su.SubscriberID = ac.SubscriberID
			AND	ac.UNUN2 LIKE CONCAT('%;',su.SubScriberPrefix,REPLACE(rt.LoginName,'_','\_'),';%')
    LEFT JOIN	FPS_DataCenter.DeviceCode	AS dc
				ON dc.DeviceCode = rt.DeviceCode
    WHERE		rt.DeviceCode != ''
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID                
                AND rt.IsProcessed = 0;     
   
	# Update DeviceStatus for Old Device
    UPDATE 		FPS_DataCenter.Device dv
    INNER JOIN	Temp_Transaction ts
				ON ts.DeviceID = dv.DeviceID
	SET			dv.DeviceStatus = DeviceStatusOld
    WHERE 		ts.DeviceID IS NOT NULL;  

	INSERT INTO Association(AccountID, DeviceID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		ts.AccountID
				, ts.DeviceID
                , ts.SubscriberID
                , MIN(ts.CreatedDate)
                , 0 # SyncGraphDB
    FROM		Temp_Transaction ts
    WHERE		ts.DeviceID IS NOT NULL
    GROUP BY 	ts.AccountID, ts.DeviceID, ts.SubscriberID;    
	
    # Remove Transaction - Old DeviceCode
    DELETE	ts
    FROM 	Temp_Transaction AS ts
    WHERE	ts.DeviceID IS NOT NULL; 
    
    # Recover Device BY DeviceFingering AND AccountID
	# GET ACCOUNTID
   
    UPDATE		Temp_Transaction AS ts
	INNER JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_Account_SubscriberID_FirstLoginName_UserName_Username2)
				ON ts.SubscriberID = ac.SubscriberID
				AND	ac.UNUN2 LIKE CONCAT('%;',ts.SubScriberPrefix,REPLACE(ts.LoginName,'_','\_'),';%')
    SET			ts.AccountID = ac.AccountID;
    
    # UPDATE 	Recover Device
	UPDATE		Temp_Transaction AS ts
    INNER JOIN	FPS_DataCenter.Association AS ass
				ON ts.AccountID = ass.AccountID
	INNER JOIN	FPS_DataCenter.Device AS dv
				ON dv.DeviceID = ass.DeviceID					
	SET			ts.DeviceID = dv.DeviceID
				, ts.MergedFingerprintCode = FPS_DC_MERGEIFDIFFERENCELISTS(';', ts.FingerprintCode, dv.FingerprintCode)
	WHERE		FPS_DC_ISLISTSMATCHBYITEM(';',ts.FingerprintCode, dv.FingerprintCode) = 1;
   
	# UPDATE DEVICE Recover
    UPDATE		FPS_DataCenter.Device AS dv
    INNER JOIN	Temp_Transaction AS ts
				ON dv.DeviceID = ts.DeviceID
	SET			dv.FingerprintCode = ts.MergedFingerprintCode    		
				, dv.DeviceStatus = DeviceStatusRecover
                , dv.LastDeviceCode = ts.DeviceCode
				, dv.FingerprintMoreInfo = ts.FingerprintMoreInfo;
  
    # INSERT RecoverDeviceCode
	INSERT INTO FPS_DataCenter.DeviceCode(DeviceCode, DeviceID, CreatedDate)
    SELECT 		ts.DeviceCode
				, ts.DeviceID
                , MIN(ts.CreatedDate)
    FROM		Temp_Transaction ts
	WHERE 	 ts.DeviceID IS NOT NULL
    GROUP BY 	ts.DeviceCode
				, ts.DeviceID; 
    
	INSERT INTO Association(AccountID, DeviceID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		ts.AccountID
				, ts.GroupDevice
                , ts.SubscriberID
                , MIN(ts.CreatedDate)
                , 0 # SyncGraphDB
    FROM		Temp_Transaction ts
    WHERE		ts.GroupDevice IS NOT NULL
    GROUP BY 	ts.AccountID, ts.GroupDevice, ts.SubscriberID;    
   
	# Remove Transaction - RecoveredDevice
    DELETE	ts
    FROM 	Temp_Transaction AS ts
    WHERE	ts.DeviceID IS NOT NULL; 
    
    # Group Device
	DROP TEMPORARY TABLE IF EXISTS Temp_DeviceFisrtTrans;
    CREATE temporary TABLE Temp_DeviceFisrtTrans
    (
		AccountID			BIGINT
        , SubscriberID		BIGINT
        , DeviceCode		VARCHAR(32)
        , FingerprintCode	TEXT
        , StagingTransID	BIGINT
        , GroupDevice		INT
        , CreatedDate		DATETIME
    ); 
	
	DROP TEMPORARY TABLE IF EXISTS Temp_DeviceFisrtTrans2;
    CREATE temporary TABLE Temp_DeviceFisrtTrans2
    (
		AccountID			BIGINT
        , SubscriberID		BIGINT
        , DeviceCode		VARCHAR(32)
        , FingerprintCode		TEXT
        , StagingTransID		BIGINT
        , GroupDevice			INT
        , CreatedDate			DATETIME
    ); 
   
    SET n = (SELECT COUNT(ts.StagingTransID) FROM Temp_Transaction AS ts);

    WHILE (i <= n) DO
    
		SELECT    ts.AccountID 
				, ts.SubscriberID
				, ts.DeviceCode
                , ts.FingerprintCode
                , ts.StagingTransID
                , ts.StagingTransID
                , ts.CreatedDate
        INTO  vr_AccountID
				, vr_SubscriberID
				, vr_DeviceCode
                , vr_FingerprintCode
                , vr_StagingTransID
                , vr_GroupDevice
                , vr_CreatedDate
        FROM Temp_Transaction AS ts
		LEFT JOIN Temp_DeviceFisrtTrans AS dft
					ON dft.StagingTransID = ts.StagingTransID
		WHERE 		dft.StagingTransID IS NULL
        ORDER BY ts.TransDate ASC LIMIT 1; 
        
        SELECT dft.GroupDevice
        INTO vr_GroupDevice
		FROM Temp_DeviceFisrtTrans AS dft
        WHERE dft.DeviceCode = vr_DeviceCode 
        LIMIT 1;
		
        IF (vr_GroupDevice = vr_StagingTransID) THEN
			SELECT dft.GroupDevice 
            INTO vr_GroupDevice 
            FROM Temp_DeviceFisrtTrans AS dft 
            WHERE vr_AccountID = dft.AccountID AND FPS_DC_ISLISTSMATCHBYITEM(';', vr_FingerprintCode, dft.FingerprintCode) = 1 
            LIMIT 1;
        END IF;       

		#IF(vr_StagingTransID = vr_GroupDevice) THEN
		INSERT INTO Temp_DeviceFisrtTrans(AccountID, SubscriberID, DeviceCode, FingerprintCode, StagingTransID, GroupDevice, CreatedDate)
        SELECT vr_AccountID
				, vr_SubscriberID
				, vr_DeviceCode
                , vr_FingerprintCode
                , vr_StagingTransID
                , IFNULL (vr_GroupDevice,vr_StagingTransID) AS GroupDevice
                , vr_CreatedDate;
        #END IF;
        SET i = i + 1;  
    END WHILE;
    
	INSERT INTO Temp_DeviceFisrtTrans2(AccountID, DeviceCode, FingerprintCode, StagingTransID, GroupDevice)
	SELECT		AccountID, DeviceCode, FingerprintCode, StagingTransID, GroupDevice
    FROM 		Temp_DeviceFisrtTrans;
    
	# INSERT  NEW DEVICE
    INSERT INTO FPS_DataCenter.Device(FirstDeviceCode, LastDeviceCode,  FingerprintCode, FingerprintMoreInfo, StagingTransID, UserAgentID, PluginID, FirstAccountID, CreatedDate, DeviceStatus)
    SELECT 	ts.DeviceCode
			, ts.DeviceCode
			, ts.FingerprintCode
            , ts.FingerprintMoreInfo
            , ts.StagingTransID
            , ua.UserAgentID
            , ts.PluginID
            , ts.AccountID
            , ts.CreatedDate
            , DeviceStatusNew AS DeviceStatus
	FROM	Temp_Transaction AS ts
    INNER JOIN	Temp_DeviceFisrtTrans AS dft 
				ON ts.StagingTransID = dft.StagingTransID
    INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	LEFT JOIN	FPS_DataCenter.DeviceCode AS dc
				ON dc.DeviceCode = ts.DeviceCode
    WHERE 	dft.StagingTransID = dft.GroupDevice
			AND dc.DeviceCode IS NULL;	
    
    UPDATE Temp_DeviceFisrtTrans2 AS dft2
    INNER JOIN FPS_DataCenter.Device AS dv
				ON dft2.DeviceCode = dv.LastDeviceCode
	LEFT JOIN  FPS_DataCenter.DeviceCode AS dc
				ON dc.DeviceCode = dft2.DeviceCode
	SET		 GroupDevice = dv.DeviceID
	WHERE 	 dc.DeviceCode IS NULL;

	UPDATE Temp_DeviceFisrtTrans AS dft
    INNER JOIN Temp_DeviceFisrtTrans2 dft2
				ON  dft.GroupDevice = dft2.StagingTransID
	SET		 dft.GroupDevice = dft2.GroupDevice;

	INSERT INTO FPS_DataCenter.DeviceCode(DeviceCode, DeviceID, CreatedDate)
    SELECT 		dft.DeviceCode
				, dft.GroupDevice
                , MIN(dft.CreatedDate)
    FROM		Temp_DeviceFisrtTrans AS dft
	LEFT JOIN  	FPS_DataCenter.DeviceCode AS dc
				ON dc.DeviceCode = dft.DeviceCode
	WHERE 	 dc.DeviceCode IS NULL
    GROUP BY dft.DeviceCode, dft.GroupDevice; 
  
    INSERT INTO Association(AccountID, DeviceID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		dft.AccountID
				, dft.GroupDevice
                , dft.SubscriberID
                , MIN(CreatedDate)
                , 0 # SyncGraphDB
    FROM		Temp_DeviceFisrtTrans dft
    GROUP BY 	dft.AccountID, dft.GroupDevice, dft.SubscriberID;   
	
	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 

END$$

DELIMITER ;
