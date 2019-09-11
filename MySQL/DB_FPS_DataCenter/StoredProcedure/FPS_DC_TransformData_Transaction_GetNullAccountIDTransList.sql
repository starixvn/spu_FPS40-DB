

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Transaction_GetNullAccountIDTransList$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Transaction_GetNullAccountIDTransList(IN ip_Size INT)
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
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_GetNULLAccountIDList' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT		ts.StagingTransID
    FROM		FPS_DataCenter.Transaction AS ts
    WHERE		ts.AccountID IS NULL
    LIMIT		ip_Size;
   
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
    	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);  
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 

    

    
END$$
DELIMITER ;
