DELIMITER $$

USE FPS_RawTransaction$$

DROP PROCEDURE IF EXISTS FPS_RawTransaction.FPS_RT_TransformData_GetPackage$$

CREATE PROCEDURE FPS_RawTransaction.FPS_RT_TransformData_GetPackage (IN ip_IsProcessed TINYINT, IN ip_NoOfTickets INT, IN ip_NoOfBatch INT)
BEGIN
	DECLARE		Counter		INT UNSIGNED DEFAULT 0;
    DECLARE		IsStop		INT DEFAULT 0;
    
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
		MinStagingTransId			INT
        , MaxStagingTransId			INT
    ); 
    
	
     loop_label:  LOOP
		
		IF ((SELECT COUNT(1) FROM Temp_StagingTrans) < ip_NoOfBatch AND IsStop != -1)   THEN       
			       
			INSERT INTO Temp_StagingTrans
			SELECT	MIN(pk.StagingTransID) 		AS MinStagingTransID
					, MAX(pk.StagingTransID)	AS MaxStagingTransID
			FROM	(
						SELECT	rt.StagingTransID	
						FROM 	FPS_RawTransaction.RawTransaction AS rt
						WHERE	rt.IsProcessed = ip_IsProcessed
									And StagingTransID > Counter
						LIMIT	 ip_NoOfTickets
					) pk;
                
            SET Counter = (SELECT MAX(MaxStagingTransID) FROM Temp_StagingTrans);
		ELSE
            LEAVE  loop_label;
        END IF;
        
        IF(Counter = IsStop) THEN 
			SET IsStop = -1;
        ELSE 
			Set IsStop = Counter;
        END IF;
        
    END LOOP;
    
    SELECT tmpTT.MinStagingTransId
        , tmpTT.MaxStagingTransId
	FROM  Temp_StagingTrans AS tmpTT;
    
   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
	### PERFORMANCE
	SET		vrEndTime = CURRENT_TIMESTAMP(4);
    
    SELECT 	Count(1), Min(MinStagingTransId), Max(MaxStagingTransId)
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
