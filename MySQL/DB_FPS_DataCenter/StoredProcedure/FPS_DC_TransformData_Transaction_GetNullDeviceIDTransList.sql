
DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Transaction_GetNullDeviceIDTransList$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Transaction_GetNullDeviceIDTransList(IN ip_Size INT)
BEGIN
    /*
	Created: 20190730@Casey.Huynh
	Task : Get Trans List with Null DeviceID
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Transaction_GetNullDeviceIDTransList' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	INT ;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
	
    ### PERFORMANCE: START
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
    
	SELECT		ts.StagingTransID
    FROM		FPS_DataCenter.Transaction AS ts
    WHERE		ts.DeviceID IS NULL
    LIMIT		IP_SIZE;
   
   
	
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);  
    
    SET Notes = CONCAT('Size: ', ip_Size);
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
END$$
DELIMITER ;
