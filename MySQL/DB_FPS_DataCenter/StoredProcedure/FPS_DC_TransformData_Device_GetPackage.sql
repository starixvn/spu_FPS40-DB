DELIMITER $$

USE FPS_RawTransaction$$

DROP PROCEDURE IF EXISTS FPS_RawTransaction.FPS_DC_TransformData_Device_Transaction_GetPackage_v1$$

CREATE PROCEDURE FPS_RawTransaction.FPS_DC_TransformData_Device_Transaction_GetPackage_v1 (IN ip_NoOfTickets INT, IN ip_NoOfBatch INT)
BEGIN
	DECLARE		TotalRecord		INT UNSIGNED DEFAULT 0;
	DECLARE		Batch			TINYINT DEFAULT 1;
    
	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName		VARCHAR(200)  DEFAULT 'FPS_RT_TransformData_GetPackage' ;
    DECLARE		vrStepID		INT;
	DECLARE 	vrNotes	 		VARCHAR(500);
	DECLARE 	vrStartTime		TIMESTAMP(4);
	DECLARE		vrEndTime 		TIMESTAMP(4);
	DECLARE		vrDuration 		BIGINT;	
    DECLARE		vrTotalRecord	INT;
    DECLARE		vrFromID		BIGINT;
    DECLARE		vrToID			BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = CONCAT('Input: ',ip_NoOfTickets,'_', ip_NoOfBatch) ;		
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);	
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime);

	### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS Temp_StagingTrans;
    CREATE TEMPORARY TABLE Temp_StagingTrans 
    (	
		BatchID				TINYINT
		, StagingTransID	BIGINT	UNSIGNED
        , AccountID			BIGINT	UNSIGNED
        , SubscriberID		BIGINT
		, UserAgentID		BIGINT
        , DeviceCodeID		BIGINT
    ); 
   
	SET TotalRecord=ip_NoOfTickets*ip_NoOfBatch;
    
	INSERT INTO Temp_StagingTrans(StagingTransID, AccountID, SubscriberID, UserAgentID, DeviceCodeID)
    SELECT	ts.StagingTransID
			, ts.AccountID
            , ts.SubscriberID
            , ts.UserAgentID
            , ts.DeviceCodeID
	FROM 	FPS_DataCenter.Transaction AS ts
	WHERE	ts.AccountID 	IS NOT NULL
			AND ts.DeviceID IS NULL
	LIMIT	TotalRecord;
    
    WHILE (EXISTS (SELECT (1) FROM Temp_StagingTrans WHERE BatchID IS NULL LIMIT 1)) DO
    	  UPDATE 	Temp_StagingTrans
		  SET		BatchID = Batch
          WHERE		BatchID IS NULL 
          LIMIT 	ip_NoOfTickets;    
		  SET Batch = Batch + 1;
    END WHILE;
    
    SELECT	ts.BatchID
			, ts.StagingTransID
			, ts.AccountID
            , ts.SubscriberID
            , ts.UserAgentID
            , ts.DeviceCodeID
	FROM Temp_StagingTrans AS ts;
    
   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
	### PERFORMANCE
	SET		vrEndTime = CURRENT_TIMESTAMP(4);
    
    SELECT 	Count(1), Min(StagingTransId), Max(StagingTransId)
    INTO	vrTotalRecord, vrFromID, vrToID
    FROM	Temp_StagingTrans AS tts;
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
            , z.TotalRecord = vrTotalRecord
            , z.FromID = vrFromID
            , z.ToID		= vrToID

    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END 
END$$
DELIMITER ;
