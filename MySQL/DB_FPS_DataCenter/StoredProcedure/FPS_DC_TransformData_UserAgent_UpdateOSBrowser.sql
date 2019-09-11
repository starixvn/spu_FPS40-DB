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

	DROP TABLE IF EXISTS Temp_UserAgent;

	CREATE TEMPORARY TABLE Temp_UserAgent
	( 
		UserAgentCode 	VARCHAR(32)
		,	BrowserID 		INT
		,	BrowserName		VARCHAR(100)
		,	OSID 			INT	
		,	OSName			VARCHAR(100)
	);

	#=======================

	INSERT INTO Temp_UserAgent(UserAgentCode, BrowserID, BrowserName, OSID, OSName)
	SELECT *
	FROM
	JSON_TABLE(
				ip_UserAgentJson
				, "$[*]" COLUMNS(
								UserAgentCode 	VARCHAR(32) PATH "$.UserAgentCode"         
								, BrowserID			INT PATH "$.BrowserId" 
								, BrowserName		VARCHAR(100) PATH "$.BrowserName" 
								, OSID				INT PATH "$.OSId"  
								, OSName		VARCHAR(100) PATH "$.OSName" 
								)
				) AS  tmpUA;

	#=======================
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
	# Insert Browser
	INSERT IGNORE INTO FPSA_DataCenter.Browser(BrowserName, CreatedDate)
	SELECT		tmpBr.BrowserName, Now() 
    FROM 		Temp_UserAgent AS tmpBr 
    GROUP BY 	tmpBr.BrowserName;

	# Insert OS
	INSERT IGNORE INTO FPSA_DataCenter.OS(OSName, CreatedDate)
	SELECT 		tmpOs.OSName, Now() 
	FROM 		Temp_UserAgent AS tmpOs 
    GROUP BY 	tmpOs.OSName;

	# Update Browser and OS Id into temporary table
	UPDATE 		Temp_UserAgent as tmpAU 
	INNER JOIN	FPSA_DataCenter.OS AS os
				ON tmpAU.OSName = os.OSName
	INNER JOIN	FPSA_DataCenter.Browser AS br 
				ON tmpAU.BrowserName = br.BrowserName
	SET  		tmpAU.BrowserID = br.BrowserID
				, tmpAU.OSID = os.OSID;             

	# Update Browser and OS into User Agent table
	UPDATE 		FPSA_DataCenter.UserAgent AS us 
	INNER JOIN	Temp_UserAgent AS tmp 
				ON us.UserAgentCode = tmp.UserAgentCode
	SET 		us.BrowserID = tmp.BrowserID
				, us.OSID = tmp.OSID
				, us.Browser = tmp.BrowserName
				, us.OS = tmp.OSName;

	#=======================
	DROP TABLE IF EXISTS Temp_UserAgent;
	#=======================
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;