/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_UserAgent$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_UserAgent(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	
	DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_UserAgent' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    ### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS Temp_UserAgent;
    CREATE TEMPORARY TABLE Temp_UserAgent 
    (		
		UserAgent			TEXT
        , UserAgentCode		VARCHAR(32)
    );    
	    
    INSERT INTO Temp_UserAgent (UserAgent, UserAgentCode)
    SELECT		rt.UserAgent
				, MD5(rt.UserAgent)
	FROM		FPS_RawTransaction.RawTransaction AS rt
    LEFT JOIN	FPS_DataCenter.UserAgent AS ua
				ON ua.UserAgentCode = MD5(rt.UserAgent)
    WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0
                AND ua.UserAgentID IS NULL
    GROUP BY	rt.UserAgent;
    
	#========INSERT: Subscriber which are unhandled interagtion=====================================================

	INSERT INTO FPS_DataCenter.UserAgent (UserAgent, UserAgentCode)
	SELECT 		tu.UserAgent
				, tu.UserAgentCode
    FROM		Temp_UserAgent AS tu;	

	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 
END$$
DELIMITER ;
