DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_GetForUpdateCustInfo$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_GetForUpdateCustInfo (in ip_Size INT)
BEGIN
	/*
		Created: 20190620@Harvey
		Task : Get Account for updating IBC info
		DB: FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
			
		### PERFORMANCE: START
		DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_GetForUpdateCustInfo' ;
		DECLARE		GroupID 	INT;
		DECLARE 	Notes	 	VARCHAR(500);
		DECLARE 	StartTime	TIMESTAMP(4);
		DECLARE		EndTime 	TIMESTAMP(4);
		DECLARE		Duration 	BIGINT ;
		### PERFORMANCE: END
		
		SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
		
		### PERFORMANCE: START
		SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
		SET 	StartTime = CURRENT_TIMESTAMP(4);
        
		SET Notes = CONCAT('Size:',ip_Size);	
		INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime)
		VALUES(SPName, GroupID, 0, Notes, StartTime);
		### PERFORMANCE: END
	
		SELECT acc.AccountID
				, acc.SubscriberID
				, (CASE	WHEN acc.IsDeposit = 1 THEN CONCAT(sub.SubscriberPrefix, acc.FirstLoginName) 
						ELSE acc.FirstLoginName END) AS LoginName
		FROM		FPS_DataCenter.Account acc
		INNER JOIN	FPS_Admin.Subscriber sub
					ON acc.SubscriberID = sub.SubscriberID
		WHERE 	acc.IsDeposit IS NOT NULL
				AND acc.CustID IS NULL
		LIMIT 	ip_Size;	
		
		### PERFORMANCE
		SET EndTime = CURRENT_TIMESTAMP(4);	   
		Update FPS_DataCenter.zzTracePerformance t
        SET	t.EndTime = EndTime
			, t.Duration = TIMESTAMPDIFF(MICROSECOND, t.StartTime, t.EndTime)
        WHERE	t.StartTime = StartTime AND t.SPName = SPName;
		### PERFORMANCE 
        
		SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

