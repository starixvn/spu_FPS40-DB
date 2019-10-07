DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_GetForUpdateCustInfo$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_GetForUpdateCustInfo (in ip_Size INT)
BEGIN
	/*
		Created: 20190620@Terry
		Task : Update IPTableLog
		DB: FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
			
	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_GetForUpdateCustInfo' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	
    DECLARE		vrFromID	BIGINT;
    DECLARE		vrToID		BIGINT;
    DECLARE		vrBegin		BIGINT;
    DECLARE		vrTotalRecord		INT;
	    
    SET		vrExecKey = CRC32((UUID_Short()));
    SET		vrNotes = 'Get AccountID IS NULL From Transaction';	
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);	
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, TotalRecord)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_Size); 
    
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
	
	SELECT acc.AccountID
			, acc.SubscriberID
			, (CASE	WHEN acc.IsDeposit = 1 THEN CONCAT(sub.SubscriberPrefix, acc.FirstLoginName) 
					ELSE acc.FirstLoginName END) AS LoginName
	FROM		FPS_DataCenter.Account acc
	INNER JOIN	FPS_Admin.Subscriber sub
				ON acc.SubscriberID = sub.SubscriberID
	WHERE 	acc.CustID = 0
	LIMIT 	ip_Size;	
	
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

