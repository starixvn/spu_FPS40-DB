DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_GetUserAgent $$

CREATE PROCEDURE FPS_DC_GetUserAgent(IN in_size INT)
BEGIN
	 /*
		Created:	20190815@Terry.Nguyen
		Task :		Get user agent list by size
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	SELECT 		UserAgentCode, UserAgent
	FROM		FPSA_DataCenter.UserAgent	
    WHERE 		BrowserID IS NULL 
				AND OSID IS NULL 
    LIMIT in_size; 
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
END$$

DELIMITER ;