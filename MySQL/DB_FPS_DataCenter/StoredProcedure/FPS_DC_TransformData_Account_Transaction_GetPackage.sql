DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_Transaction_GetPackage$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_Transaction_GetPackage(IN ip_Size INT)
BEGIN
      /*
	Created: 20190730@Casey.Huynh
	Task : Get Translist within Null Account
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/
	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_Transaction_GetPackage' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Get Input Data';		
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);   
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, TotalRecord)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_Size);	 
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
    
	SELECT		ts.StagingTransID
    FROM		FPS_DataCenter.Transaction AS ts
    WHERE		ts.AccountID IS NULL
    LIMIT		ip_Size;  
   
	
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
