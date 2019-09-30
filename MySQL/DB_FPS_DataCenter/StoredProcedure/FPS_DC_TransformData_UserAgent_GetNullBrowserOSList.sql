DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_UserAgent_GetNullBrowserOSList $$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_UserAgent_GetNullBrowserOSList(IN ip_size INT)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Get user agent list by size
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
    ### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_UserAgent_GetNullBrowserOSList' ;
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
    ### PERFORMANCE: END

	SELECT 		UserAgentID, UserAgent
	FROM		FPS_DataCenter.UserAgent	
    WHERE 		BrowserID IS NULL 
				AND OSID IS NULL 
    LIMIT ip_size; 
	
    ### PERFORMANCE: Start
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT('Size: ', ip_Size);
	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE: End
	
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;