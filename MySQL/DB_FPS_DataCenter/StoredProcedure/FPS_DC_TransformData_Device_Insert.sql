DELIMITER $$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Device_Insert$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Device_Insert(IN ip_TransJson TEXT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Transform Device Info
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/

	DECLARE DeviceStatusNew			TINYINT DEFAULT 1;			# New Device
	DECLARE DeviceStatusOld			TINYINT DEFAULT 2;			# Old Device
	DECLARE DeviceStatusRecover		TINYINT DEFAULT 3;			# Recover Device
	DECLARE	MaxDeviceID				BIGINT;
/*
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Device_Insert' ;
	DECLARE		GroupID 	INT;
	DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT;
	DECLARE		Step		INT;
    DECLARE		MinID		BIGINT;
    DECLARE		MaxID		BIGINT;
    DECLARE		vrBegin		BIGINT;
	### PERFORMANCE: END

	

	### PERFORMANCE: START
	SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
	SET 	vrStartTime = CURRENT_TIMESTAMP(4);
	SET		vrBegin = vrStartTime;
	SET Step = 1;
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Get Json Data');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step , Notes, vrStartTime);    
	### PERFORMANCE: END    
	*/
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
    
	DROP TEMPORARY TABLE IF EXISTS Temp_InputTrans;
	CREATE TEMPORARY TABLE Temp_InputTrans 
	(	
		StagingTransID			BIGINT			UNSIGNED
		, AccountID				BIGINT			UNSIGNED
		, SubscriberID			INT
        , UserAgentID			BIGINT			UNSIGNED
		, DeviceCodeID			BIGINT			UNSIGNED
	);

	#========GET INPUT DATA===========================

	INSERT INTO Temp_InputTrans(
				StagingTransID 
				, AccountID
				, SubscriberID
                , UserAgentID
				, DeviceCodeID
				)
	SELECT tmpTrans.StagingTransID
			, tmpTrans.AccountID
			, tmpTrans.SubscriberID
            , tmpTrans.UserAgentID
			, tmpTrans.DeviceCodeID
			 FROM
			   JSON_TABLE(
				ip_TransJson,
				 "$[*]" COLUMNS(
				  StagingTransID 			BIGINT UNSIGNED PATH "$.StagingTransId"         
				, AccountID					BIGINT UNSIGNED PATH "$.AccountId"
				, SubscriberID				TINYINT PATH "$.SubscriberId"
                , UserAgentID 				BIGINT UNSIGNED PATH "$.UserAgentId"         
				, DeviceCodeID				BIGINT UNSIGNED PATH "$.DeviceCodeId"
				 )
			   ) AS  tmpTrans;
/*
	INSERT INTO Temp_InputTrans(
				StagingTransID 
				, AccountID
				, SubscriberID
                , UserAgentID
                , DeviceCodeId
				)
	SELECT		StagingTransID 
				, AccountID
				, SubscriberID
                , UserAgentID
                , DeviceCodeId
	FROM		FPS_DataCenter.Transaction
	WHERE		AccountID IS NOT NULL
				AND DeviceID IS NULL
	LIMIT 100;
*/
    /*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    
    SELECT Min(StagingTransID), Max(StagingTransID)
    INTO	MinID, MaxID
    FROM	Temp_InputTrans;
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
            , z.Notes = CONCAT(MinID, '_', MaxID, ': Get Json Data')
    WHERE	z.StepID = Step;
    
	SET Step = 2;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Get Raw Data');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
    
	#======GET DATA FROM RAW TRANSACTION===========================
	DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
	CREATE TEMPORARY TABLE Temp_Transaction(
		StagingTransID			BIGINT	UNSIGNED
		, AccountID				BIGINT	UNSIGNED
		, SubscriberID			INT
        , UserAgentID			BIGINT
        , DeviceCodeID			BIGINT
		, DeviceCode			VARCHAR(64)
		, FingerprintCode		VARCHAR(1000)
        , FingerprintMoreInfo	TEXT
		
		, PluginID				INT
		, CreatedDate			DATETIME
		, TransDate				DATETIME
		
		, DeviceID				BIGINT	UNSIGNED		NULL
		, DeviceStatus			TINYINT					NULL
		, FirstDeviceCode		VARCHAR(64)				NULL
        , LastDeviceStatus		TINYINT					NULL				
	);
	  
	INSERT INTO Temp_Transaction(StagingTransID, AccountID, SubscriberID, UserAgentID, DeviceCodeID, DeviceCode, FingerprintCode, FingerprintMoreInfo, PluginID, CreatedDate, TransDate)
	SELECT 		tit.StagingTransID
				, tit.AccountID
				, tit.SubscriberID
                , tit.UserAgentID
                , tit.DeviceCodeID
				, rt.DeviceCode
				, rt.FingerprintCode
                , rt.FingerprintMoreInfo
				, rt.PluginID
				, rt.CreatedDate
				, rt.TransDate
	FROM		Temp_InputTrans						AS tit
	INNER JOIN	FPS_RawTransaction.RawTransaction	AS rt
				ON	tit.StagingTransID = rt.StagingTransID;
	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 3;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','UPDATE	Temp_Transaction: Device Empty ');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
	#======DeviceCode EMPTY==================================
	UPDATE	Temp_Transaction AS tts
	SET		tts.DeviceID = 0
			, tts.DeviceStatus = 0
			, tts.FirstDeviceCode = ''
            , tts.LastDeviceStatus = 0
	WHERE	tts.DeviceCode = '';
    
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 4;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','UPDATE	Temp_Transaction: Device CodeExisting ');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
    
	#=======DeviceCode EXISTING =================================
	UPDATE		Temp_Transaction AS tts
	INNER JOIN	FPS_DataCenter.DeviceCode AS dc
				ON	tts.DeviceCodeID = dc.DeviceCodeID
	SET			tts.DeviceID = dc.DeviceID
				, tts.DeviceStatus = (CASE WHEN dc.FirstStagingTransID = tts.StagingTransID THEN dc.FirstStatus ELSE DeviceStatusOld END)
				, tts.FirstDeviceCode = dc.FirstDeviceCode
	WHERE		tts.DeviceID IS NULL;
    
    
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET		Step = 5;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','INSERT INTO Temp_NewDeviceCode: Select Min Max ');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/    
    
	#======GROUP BY NewDeviceCode=============================
	DROP TEMPORARY TABLE IF EXISTS Temp_NewDeviceCode;
	CREATE TEMPORARY TABLE Temp_NewDeviceCode(
		DeviceCode				VARCHAR(64)
		, MinStagingTransID		BIGINT			UNSIGNED
		, MaxStagingTransID		BIGINT			UNSIGNED
	);

	INSERT INTO Temp_NewDeviceCode(DeviceCode, MinStagingTransID, MaxStagingTransID)
	SELECT	tts.DeviceCode
			, MIN(tts.StagingTransID)
			, MAX(tts.StagingTransID)
	FROM	Temp_Transaction	AS tts
	GROUP BY	tts.DeviceCode;
	
   
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 6;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','UPDATE	Temp_Transaction: Get RecoverDevice');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
     
	#======GET Recover DeviceID==============================    
	
	IF EXISTS (SELECT 1 FROM Temp_Transaction tts WHERE tts.DeviceID IS NULL)
    THEN		
		UPDATE		Temp_Transaction AS tts    
		INNER JOIN	Temp_NewDeviceCode AS tnc
					ON	tts.StagingTransID = tnc.MinStagingTransID
		INNER JOIN	FPS_DataCenter.Association AS ass
					ON tts.AccountID = ass.AccountID
		INNER JOIN	FPS_DataCenter.Device AS dv
					ON ass.DeviceID = dv.DeviceID
		INNER JOIN	FPS_DataCenter.DeviceFingerprint AS df
					ON  dv.DeviceID = df.DeviceID
					AND	FPS_DC_ISLISTSMATCHBYITEM(';',tts.FingerprintCode, df.FingerprintCode) = 1
		SET			tts.DeviceID = df.DeviceID
					, tts.DeviceStatus = DeviceStatusRecover
					, tts.DeviceCode = dv.FirstDeviceCode
		WHERE		tts.DeviceID IS NULL;        
	END IF;
	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 7;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','UPDATE	Temp_Transaction: Update NewDevice');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
    
	#=======Update DeviceStatus: FOR New Device
    IF EXISTS (SELECT 1 FROM Temp_Transaction tts WHERE tts.DeviceID IS NULL)
    THEN
		UPDATE		Temp_Transaction AS tts
		LEFT JOIN	Temp_NewDeviceCode AS tnd
					ON	tts.StagingTransID = tnd.MinStagingTransID
		SET			tts.DeviceID = CRC32(tts.DeviceCode)
					, tts.DeviceStatus = (CASE WHEN tnd.DeviceCode IS NOT NULL THEN DeviceStatusNew ELSE DeviceStatusOld END)
					, tts.FirstDeviceCode = tts.DeviceCode
		WHERE		tts.DeviceID IS NULL;    
	END IF;
    
    
	#==========================================================================
	DROP TEMPORARY TABLE IF EXISTS Temp_Transaction_02;
	CREATE TEMPORARY TABLE Temp_Transaction_02(
		StagingTransID			BIGINT	UNSIGNED
		, AccountID				BIGINT	UNSIGNED
		, SubscriberID			INT
		, DeviceCode			VARCHAR(64)
		, FingerprintCode		VARCHAR(1000)
		, UserAgentID			BIGINT
		, PluginID				INT
		, CreatedDate			DATETIME
		, TransDate				DATETIME
		
		, DeviceID				BIGINT	UNSIGNED		NULL
		, DeviceStatus			TINYINT					NULL
		, FirstDeviceCode		VARCHAR(64)				NULL
	);

	INSERT INTO Temp_Transaction_02(StagingTransID, AccountID, SubscriberID, DeviceCode, FingerprintCode, UserAgentID, PluginID, CreatedDate, TransDate, DeviceID, DeviceStatus, FirstDeviceCode)
	SELECT 		tts.StagingTransID
				, tts.AccountID
				, tts.SubscriberID
				, tts.DeviceCode
				, tts.FingerprintCode
				, tts.UserAgentID
				, tts.PluginID
				, tts.CreatedDate
				, tts.TransDate
				, tts.DeviceID
				, tts.DeviceStatus
				, tts.FirstDeviceCode
	FROM			Temp_Transaction		AS tts
	INNER JOIN	Temp_NewDeviceCode		AS tnd
				ON tts.StagingTransID = tnd.MinStagingTransID;

	UPDATE 		Temp_Transaction AS tts
	INNER JOIN	Temp_NewDeviceCode	AS tnd
				ON tts.StagingTransID = tnd.MinStagingTransID
	INNER JOIN	Temp_Transaction_02	tts02
				ON	tts02.AccountID = tts.AccountID
					AND tts.StagingTransID > tts02.StagingTransID
					AND FPS_DC_ISLISTSMATCHBYITEM(';',tts.FingerprintCode, tts02.FingerprintCode) = 1
	SET		tts.DeviceStatus = DeviceStatusRecover
			, tts.FirstDeviceCode = tts02.DeviceCode
			, tts.DeviceID	= tts02.DeviceID;
	
    TRUNCATE TABLE Temp_Transaction_02;
    INSERT INTO Temp_Transaction_02(StagingTransID, AccountID, SubscriberID, DeviceCode, FingerprintCode, UserAgentID, PluginID, CreatedDate, TransDate, DeviceID, DeviceStatus, FirstDeviceCode)
	SELECT 		tts.StagingTransID
				, tts.AccountID
				, tts.SubscriberID
				, tts.DeviceCode
				, tts.FingerprintCode
				, tts.UserAgentID
				, tts.PluginID
				, tts.CreatedDate
				, tts.TransDate
				, tts.DeviceID
				, tts.DeviceStatus
				, tts.FirstDeviceCode
	FROM		Temp_Transaction		AS tts
	INNER JOIN	Temp_NewDeviceCode		AS tnd
				ON tts.StagingTransID = tnd.MaxStagingTransID;
    
    UPDATE 		Temp_Transaction AS tts
    INNER JOIN	Temp_Transaction_02 AS tts02
				ON tts.DeviceID = tts02.DeviceID
	SET			tts.LastDeviceStatus = tts02.DeviceStatus;

    	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 8;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Insert new Device');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
        
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	#=======Insert New Device    
	INSERT IGNORE INTO	FPS_DataCenter.Device (DeviceID, FirstDeviceCode, UserAgentID, FirstStagingTransID, CreatedDate, DeviceStatus, InsertTime)
	SELECT		DeviceID
				, FirstDeviceCode
				, UserAgentID
				, StagingTransID
				, CreatedDate
				, tts.DeviceStatus
                , CURRENT_TIMESTAMP(4) 		AS InsertTime
	FROM 		Temp_Transaction AS tts
	INNER JOIN	Temp_NewDeviceCode	AS tnd
				ON tts.StagingTransID = tnd.MinStagingTransID
	WHERE		tts.DeviceStatus = DeviceStatusNew
    ORDER BY	tts.StagingTransID Desc;
    
    	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 9;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Insert new DeviceCode');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/      
    
	INSERT IGNORE INTO	FPS_DataCenter.DeviceCode (DeviceCodeID, DeviceCode, DeviceID, CreatedDate, FirstDeviceCode, LastStatus, FirstStagingTransID, FirstStatus, InsertTime)
	SELECT		tts.DeviceCodeID
				, tts.DeviceCode
				, tts.DeviceID
				, tts.CreatedDate
				, tts.FirstDeviceCode
				, tts.DeviceStatus			AS LastStatus
                , tts.StagingTransID
                , tts.DeviceStatus
                , CURRENT_TIMESTAMP(4) 		AS InsertTime
	FROM 		Temp_Transaction AS tts
	INNER JOIN	Temp_NewDeviceCode	AS tnd
				ON tts.StagingTransID = tnd.MinStagingTransID
	WHERE		tts.DeviceStatus = DeviceStatusNew
				AND tts.DeviceID !=0 ;   
	
	UPDATE 		FPS_DataCenter.DeviceCode dc
    INNER JOIN	Temp_Transaction AS tts
				ON tts.DeviceCodeID = dc.DeviceCodeID
	SET			dc.LastStatus = tts.LastDeviceStatus;
    
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 10;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Insert new DeviceFingerprint');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/
        
	INSERT IGNORE INTO FPS_DataCenter.DeviceFingerprint(FingerprintID, FingerprintCode, FingerprintMoreInfo, UserAgentID, PluginID, DeviceID, CreatedDate, InsertTime)
    SELECT		CRC32(MD5(tts.FingerprintCode)) AS FingerprintID
				, tts.FingerprintCode
                , tts.FingerprintMoreInfo
                , tts.UserAgentID
                , tts.PluginID
                , tts.DeviceID
                , tts.CreatedDate
                , CURRENT_TIMESTAMP(4)	AS InsertTime
    FROM		Temp_Transaction AS tts
	WHERE		tts.DeviceID != 0;   
    	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 11;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Insert new Association');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);       
    ### PERFORMANCE: END*/   
    
   INSERT IGNORE INTO FPS_DataCenter.Association(AssociationID, AccountID, DeviceID, SubscriberID, CreatedDate, SyncGraphDB, InsertTime)
	SELECT		CRC32(CONCAT(AccountID,'A',DeviceID)) AS AssociationID
				, tts.AccountID
				, tts.DeviceID
                , tts.SubscriberID
                , MIN(tts.CreatedDate)
                , 0 # SyncGraphDB
                , CURRENT_TIMESTAMP(4) AS InsertTime
    FROM		Temp_Transaction AS tts
    WHERE		tts.DeviceID != 0
    GROUP BY 	tts.SubscriberID
				, tts.AccountID
				, tts.DeviceID;   
   	
	/*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 12;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','Update Transaction DeviceID');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);      
    
    ### PERFORMANCE: END*/                
   UPDATE FPS_DataCenter.Transaction ts
   INNER JOIN Temp_Transaction AS tts
				ON	ts.StagingTransID = tts.StagingTransID
   SET		ts.DeviceID = tts.DeviceID
			, ts.DeviceStatus = tts.DeviceStatus
			, ts.FirstDeviceCode = tts.DeviceCode;
	
	
    /*### PERFORMANCE: START
    SET		vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	SET Step = 0;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    SET Notes = CONCAT(MinID, '_', MaxID, ': ','All');	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
    VALUES(SPName, GroupID, Step, Notes, vrStartTime);      
    
    ### PERFORMANCE: END*/     
    /*
    ### PERFORMANCE
     SET	vrEndTime = CURRENT_TIMESTAMP(4);
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.StepID = Step;
    
	### PERFORMANCE */
	
	#============================================
    DROP TEMPORARY TABLE IF EXISTS Temp_NewDeviceCode;
	DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction_02;
	DROP TEMPORARY TABLE IF EXISTS Temp_InputTrans;
    #==============================================

    	  
END$$

DELIMITER ;
