DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_CheckBrowserExist $$

CREATE PROCEDURE FPS_DC_CheckBrowserExist(IN ip_BrowserJson JSON)
BEGIN
/*
		Created:	20190815@Terry.Nguyen
		Task :		Check accounts if they are existed in Browser table
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/    

    
    DROP TEMPORARY TABLE IF EXISTS temp_Browser;    
	CREATE TEMPORARY TABLE temp_Browser (
		 UserAgentCode VARCHAR(32),
         BrowserID INT,
		 BrowserName VARCHAR(100),
         IsExisting INT
	);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    INSERT INTO temp_Browser
		(	
			 UserAgentCode
			, BrowserID
			, BrowserName
            , IsExisting
		)
        SELECT 
				  tmpBR.UserAgentCode
				, 0 AS BrowserID
				, tmpBR.BrowserName
				, 0 AS IsExisting
                FROM JSON_TABLE(
							ip_BrowserJson, "$[*]" COLUMNS(
															UserAgentCode 	VARCHAR(32) PATH "$.UserAgentCode"         
															, BrowserName	VARCHAR(100) PATH "$.BrowserName"  
				 )) AS  tmpBR;
   
   UPDATE temp_Browser AS tmp 
   INNER JOIN FPS_DataCenter.Browser AS br 
			ON tmp.BrowserName = br.BrowserName
   SET 	
		tmp.BrowserID = br.BrowserID
		,tmp.BrowserName = br.BrowserName
		,tmp.IsExisting = 1;
   
   SELECT  UserAgentCode
			,BrowserID
			,BrowserName
            ,IsExisting 
	FROM temp_Browser;  
    
   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
   
END$$

DELIMITER ;