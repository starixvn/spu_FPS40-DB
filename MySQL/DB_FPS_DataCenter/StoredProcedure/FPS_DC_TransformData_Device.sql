

DELIMITER $$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Device$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Device(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Transform Device Info
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/
    
	DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
	DECLARE DeviceStatusNew			TINYINT DEFAULT 1;			# New Device
	DECLARE DeviceStatusOld			TINYINT DEFAULT 2;			# Old Device
	DECLARE DeviceStatusRecover		TINYINT DEFAULT 3;			# Recover Device
	DECLARE	MaxDeviceID				BIGINT;
	
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_DataCenter_Process_Device' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
    CREATE TEMPORARY TABLE Temp_Transaction 
    (	
		StagingTransID			BIGINT
		, LoginName				VARCHAR(50)   
        , DeviceCode			VARCHAR(32)
        , FingerprintCode		VARCHAR(640)
        , FingerprintMoreInfo	TEXT
        , UserAgentCode			VARCHAR(32)
        , PluginID				INT
        , CreatedDate			DATETIME
        , TransDate				DATETIME
        
        , AccountID				BIGINT
        , SubscriberID			INT
        , IsDeposit				TINYINT     
        , DeviceID				BIGINT
        , DeviceStatus			BIGINT
        , RecoverFingerprintID 	BIGINT
        , NewFingerprintCode	VARCHAR(600)
        , FirstStagingTransID	BIGINT
        , LastStagingTransID	BIGINT
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
    
    #====== 1. Get Transaction to temp_table====================================
    INSERT INTO Temp_Transaction (StagingTransID, LoginName, AccountID, DeviceCode, FingerprintCode, FingerprintMoreInfo
				, UserAgentCode, PluginID, CreatedDate, TransDate,  SubscriberID, IsDeposit)
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
                , su.IsDeposit
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber su
				ON rt.SubscriberName = su.SubscriberName
	INNER JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_ACCOUNT_SUBSCRIBERID_FIRSTLOGINNAMEID_USERNAMEID_USERNAME2ID)
				ON CRC32(LOWER(CONCAT(su.SubscriberPrefix, rt.LoginName))) IN (ac.FirstLoginNameID, ac.UsernameID, ac.Username2ID)
    WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID                
                AND rt.IsProcessed = 0
                AND rt.DeviceCode != '';
                
    #====== 3. Get DeviceID of ExistingDeviceCode===============================
    UPDATE		Temp_Transaction AS tts
    INNER JOIN	FPS_DataCenter.DeviceCode AS dc
				ON	tts.DeviceCode = dc.DeviceCode
    SET			tts.DeviceID = dc.DeviceID
				, tts.DeviceStatus = DeviceStatusOld;
	
    UPDATE		FPS_DataCenter.Device AS dv
    INNER JOIN	Temp_Transaction AS tts
				ON dv.DeviceID = tts.DeviceID
    SET			dv.DeviceStatus = tts.DeviceStatus;
    
    #====== 3. New Device IF DeviceCode IS NOT NULL AND NOT EXISTING ANY Association BY ACCOUNTID AND MATCH FingerprintCode
        
	DROP TEMPORARY TABLE IF EXISTS Temp_DeviceCode;
    CREATE TEMPORARY TABLE Temp_DeviceCode(
		DeviceCode				VARCHAR(32)
        , FirstStagingTransID	BIGINT
        , LastStagingTransID	BIGINT
        );    
    
    INSERT INTO Temp_DeviceCode(DeviceCode, FirstStagingTransID, LastStagingTransID)
    SELECT		tts.DeviceCode
				, MIN(tts.StagingTransID)
                , MAX(tts.StagingTransID)
    FROM		Temp_Transaction AS tts
	GROUP BY	tts.DeviceCode;
    
    UPDATE		Temp_Transaction AS tts
    INNER JOIN	Temp_DeviceCode AS  tdc
				ON tts.DeviceCode =  tdc.DeviceCode
	SET			tts.FirstStagingTransID = tdc.FirstStagingTransID
				, tts.LastStagingTransID = tdc.LastStagingTransID;
	
    #======GET Recover DeviceID==============================
    UPDATE		Temp_Transaction AS tts    
	INNER JOIN	FPS_DataCenter.Association AS ass
				ON tts.AccountID = ass.AccountID
	INNER JOIN	FPS_DataCenter.Device AS dv
				ON	dv.DeviceID = ass.DeviceID
                AND	FPS_DC_ISLISTSMATCHBYITEM(';',tts.FingerprintCode, dv.FingerprintCode) = 1
	SET			tts.DeviceID = dv.DeviceID
				, tts.DeviceStatus = DeviceStatusRecover
    WHERE		tts.DeviceID IS NULL;
    
    #===========INSERT NEW DEVICE AND ASSOCIATION =================================================
    SET MaxDeviceID = (SELECT IFNULL(MAX(dv.DeviceID),0) FROM FPS_DataCenter.Device AS dv);
    
    INSERT INTO Device(FirstDeviceCode, LastDeviceCode, FingerprintCode, FingerprintMoreInfo, PluginID, FirstAccountID, CreatedDate, DeviceStatus)
    SELECT 	tts.DeviceCode
				, tts.DeviceCode
				, tts.FingerprintCode
				, tts.FingerprintMoreInfo
				, tts.PluginID
				, tts.AccountID
				, tts.CreatedDate
				, DeviceStatusNew AS DeviceStatus
    FROM		Temp_Transaction AS tts
    INNER JOIN	Temp_DeviceCode AS tdc
				ON tdc.FirstStagingTransID = tts.FirstStagingTransID
    WHERE		tts.DeviceID IS NULL;    
      
    UPDATE		Temp_Transaction AS tts 
    INNER JOIN	FPS_DataCenter.Device AS dv
				ON	dv.LastDeviceCode = tts.DeviceCode
    SET			tts.DeviceID = dv.DeviceID
				, tts.DeviceStatus = DeviceStatusNew
    WHERE		dv.DeviceID > MaxDeviceID
				AND tts.DeviceID IS NULL;
    
    #===========UPDATE RECOVERED DEVICE==============================================
    UPDATE		FPS_DataCenter.Device AS dv
    INNER JOIN	Temp_Transaction AS tts
				ON	dv.DeviceID = tts.DeviceID
					AND tts.DeviceStatus = DeviceStatusRecover
	INNER JOIN	Temp_DeviceCode AS tdc
				ON	tdc.LastStagingTransID = tts.StagingTransID
    SET			dv.LastDeviceCode = tts.DeviceCode
				, dv.DeviceStatus = tts.DeviceStatus
                , dv.FingerprintCode = FPS_DC_MERGELISTS(';', dv.FingerprintCode, tts.FingerprintCode);
    
     #===========INSERT NEW ASSOCIATION =================================================
    INSERT INTO FPS_DataCenter.Association(AccountID, DeviceID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		tts.AccountID
				, tts.DeviceID
                , tts.SubscriberID
                , MIN(tts.CreatedDate)
                , 0 # SyncGraphDB
    FROM		Temp_Transaction AS tts
    LEFT JOIN	FPS_DataCenter.Association AS ass USE INDEX(IX_ASSOCIATION_SUBSCRIBERID_ACCOUNTID)
				ON ass.SubscriberID = tts.SubscriberID 
					AND ass.AccountID = tts.AccountID
                    AND ass.DeviceID = tts.DeviceID
    WHERE		ass.SubscriberID IS NULL
				AND tts.DeviceID IS NOT NULL
    GROUP BY 	tts.AccountID, tts.DeviceID, tts.SubscriberID;    
    
    INSERT INTO FPS_DataCenter.DeviceCode(DeviceCode, DeviceID, CreatedDate)
    SELECT		tss.DeviceCode
				, tss.DeviceID
                , tss.CreatedDate
	FROM		Temp_Transaction AS tss
    INNER JOIN 	Temp_DeviceCode AS tdc
				ON tdc.LastStagingTransID = tss.StagingTransID
	WHERE		tss.DeviceStatus != DeviceStatusOld;
	
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 

	#============================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
	DROP TEMPORARY TABLE IF EXISTS Temp_DeviceCode;
    #==============================================
    
    	  
END$$

DELIMITER ;
