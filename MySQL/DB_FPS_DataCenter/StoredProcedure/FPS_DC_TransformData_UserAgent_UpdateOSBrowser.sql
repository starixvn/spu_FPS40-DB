DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_UserAgent_UpdateOSBrowser $$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_UserAgent_UpdateOSBrowser(IN ip_UserAgentJson JSON)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Update User Agent (OS, Browser)
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_UserAgent_UpdateOSBrowser' ;
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
    
	DROP TABLE IF EXISTS Temp_UserAgent;

	CREATE TEMPORARY TABLE Temp_UserAgent
	( 
		UserAgentID 		BIGINT
		,	BrowserID 		INT
		,	BrowserName		VARCHAR(100)
		,	OSID 			INT	
		,	OSName			VARCHAR(100)
	);

	#=======================

	INSERT INTO Temp_UserAgent(UserAgentID, BrowserID, BrowserName, OSID, OSName)
	SELECT *
	FROM
	JSON_TABLE(
				ip_UserAgentJson
				, "$[*]" COLUMNS(
								UserAgentID 		BIGINT PATH "$.UserAgentId"         
								, BrowserID			INT PATH "$.BrowserId" 
								, BrowserName		VARCHAR(100) PATH "$.BrowserName" 
								, OSID				INT PATH "$.OSId"  
								, OSName		VARCHAR(100) PATH "$.OSName" 
								)
				) AS  tmpUA;

	#=======================
	
	# Insert Browser
	INSERT IGNORE INTO FPS_DataCenter.Browser(BrowserName, CreatedDate)
	SELECT		tmpBr.BrowserName, Now() 
    FROM 		Temp_UserAgent AS tmpBr 
    GROUP BY 	tmpBr.BrowserName;

	# Insert OS
	INSERT IGNORE INTO FPS_DataCenter.OS(OSName, CreatedDate)
	SELECT 		tmpOs.OSName, Now() 
	FROM 		Temp_UserAgent AS tmpOs 
    GROUP BY 	tmpOs.OSName;

	# Update Browser and OS Id into temporary table
	UPDATE 		Temp_UserAgent as tmpAU 
	INNER JOIN	FPS_DataCenter.OS AS os
				ON tmpAU.OSName = os.OSName
	INNER JOIN	FPS_DataCenter.Browser AS br 
				ON tmpAU.BrowserName = br.BrowserName
	SET  		tmpAU.BrowserID = br.BrowserID
				, tmpAU.OSID = os.OSID;             
	
	# Update Browser and OS into User Agent table
	UPDATE 		FPS_DataCenter.UserAgent AS us 
	INNER JOIN	Temp_UserAgent AS tmp 
				ON us.UserAgentID = tmp.UserAgentID
	SET 		us.BrowserID = tmp.BrowserID
				, us.OSID = tmp.OSID
				, us.Browser = tmp.BrowserName
				, us.OS = tmp.OSName;

	#=======================
	DROP TABLE IF EXISTS Temp_UserAgent;
	#=======================
    
	### PERFORMANCE: Start
    SET EndTime = CURRENT_TIMESTAMP(4);   
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE: End
    
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;