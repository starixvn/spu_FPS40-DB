DELIMITER $$

USE FPS_RawTransaction$$

DROP PROCEDURE IF EXISTS FPS_RawTransaction.FPS_RT_TransformData_UpdateCompletedProcess$$
CREATE PROCEDURE FPS_RawTransaction.FPS_RT_TransformData_UpdateCompletedProcess(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Mark Completed from Raw Transaction
	DB: FPS_RawTransaction(Staging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

		### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName		VARCHAR(200) DEFAULT 'FPS_RT_TransformData_UpdateCompletedProcess' ;
    DECLARE		vrStepID		INT;
	DECLARE 	vrNotes	 		VARCHAR(500);
	DECLARE 	vrStartTime		TIMESTAMP(4);
	DECLARE		vrEndTime 		TIMESTAMP(4);
	DECLARE		vrDuration 		BIGINT;	
    DECLARE		vrTotalRecord	INT;
    DECLARE		vrFromID		BIGINT;
    DECLARE		vrToID			BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Update Completed Transfrom';		
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4); 
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, FromID, ToID)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_FromStagingTransID, ip_ToStagingTransID);
	   
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  
	UPDATE 		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_DataCenter.Transaction AS ts
				ON ts.StagingTransID = rt.StagingTransID
	SET			rt.IsProcessed = 1
    WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;
            
     SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
	### PERFORMANCE
	SET	vrEndTime = CURRENT_TIMESTAMP(4);

    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END

END$$
DELIMITER ;
