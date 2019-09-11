DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_UserAgent_Insert$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_UserAgent_Insert(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task :	Insert UserAgent
	DB:		FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
    
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_DataCenter_Process_UserAgent' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS Temp_UserAgent;
    CREATE TEMPORARY TABLE Temp_UserAgent 
    (		
		UserAgent			TEXT
        , UserAgentCode		VARCHAR(32)
    );    
	
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
    
    INSERT INTO Temp_UserAgent (UserAgent, UserAgentCode)
    SELECT		rt.UserAgent
				, MD5(rt.UserAgent)
	FROM		FPS_RawTransaction.RawTransaction AS rt
    LEFT JOIN	FPS_DataCenter.UserAgent AS ua
				ON ua.UserAgentCode = MD5(rt.UserAgent)
    WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0
                AND ua.UserAgentCode IS NULL
    GROUP BY	rt.UserAgent;
    #ON DUPLICATE KEY UPDATE UserAgentCode = MD5(rt.UserAgent);
    
	#========INSERT: Subscriber which are unhandled interagtion=====================================================
	INSERT INTO FPS_DataCenter.UserAgent (UserAgent, UserAgentCode)
	SELECT 		tu.UserAgent
				, tu.UserAgentCode
    FROM		Temp_UserAgent AS tu;   

    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
END$$
DELIMITER ;
