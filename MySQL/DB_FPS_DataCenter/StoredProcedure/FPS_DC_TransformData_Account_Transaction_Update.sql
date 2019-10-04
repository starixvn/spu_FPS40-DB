DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_Transaction_Update$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_Transaction_Update(IN ip_AccountIDJson JSON)
BEGIN
    /*
	Created: 20190730@Casey.Huynh
	Task : Update Transaction AccountID 
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_Transaction_Update' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	
    DECLARE		vrTotalRecord		INT;
    DECLARE		vrFromID	BIGINT;
    DECLARE		vrToID		BIGINT;
  
    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Insert New Account by Json';	
    SET 	vrStepID = 1;    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);	
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime);
	### PERFORMANCE: END  
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	DROP TEMPORARY TABLE IF EXISTS temp_Transaction;    
	CREATE TEMPORARY TABLE temp_Transaction (
		 StagingTransID BIGINT
	);
    
    INSERT INTO temp_Transaction
		(	
			 StagingTransID
		)
	SELECT	tmpAcc.StagingTransID
	FROM JSON_TABLE(	ip_AccountIDJson
						, "$[*]" COLUMNS(	StagingTransID 	BIGINT PATH "$.StagingTransID")        
					) AS tmpAcc;
                 
	UPDATE 		FPS_DataCenter.Transaction AS ts
    INNER JOIN	temp_Transaction AS tmpAcc
				ON ts.StagingTransID = tmpAcc.StagingTransID
	INNER JOIN	FPS_DataCenter.Account AS acc USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
				ON ts.LoginNameWithPrefixID IN (acc.FirstLoginNameID, acc.UsernameID, acc.Username2ID)
	SET			ts.AccountID = acc.AccountID;   
    	
	### PERFORMANCE  
	SET		vrEndTime = CURRENT_TIMESTAMP(4);
    
    SELECT Count(1), Min(tts.StagingTransID), Max(tts.StagingTransID)
    INTO	vrTotalRecord, vrFromID, vrToID
    FROM	temp_Transaction AS tts;
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
            , z.TotalRecord = vrTotalRecord
            , z.FromID = vrFromID
            , z.ToID		= vrToID
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
            
            
END$$
DELIMITER ;
