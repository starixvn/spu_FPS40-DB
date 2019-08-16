DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_CheckBrowserExist $$

CREATE PROCEDURE FPS_DC_CheckBrowserExist(IN ip_BrowserXML LONGTEXT)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Check accounts if they are existed in Browser table
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/    
    DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TEMPORARY TABLE IF EXISTS temp_Browser;    
	CREATE TEMPORARY TABLE temp_Browser (
		 UserAgentID INT,
         BrowserID INT,
		 BrowserName VARCHAR(100),
         IsExisting INT
	);
    
    SET RowCount = EXTRACTVALUE(ip_BrowserXML,'count(//root/browser)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/browser['
			,   RowIndex
			,   ']');
            
		INSERT INTO temp_Browser
		(	
			 UserAgentID
			,BrowserID
			,BrowserName
            ,IsExisting
		)
		VALUES
		( 
			 EXTRACTVALUE(ip_BrowserXML,CONCAT(XpathRow,'/attribute::UserAgentID'))
			,0
			,EXTRACTVALUE(ip_BrowserXML,CONCAT(XpathRow,'/attribute::Browser'))
            ,0
		);
		
	END WHILE;
   
   UPDATE temp_Browser AS tmp INNER JOIN FPS_DataCenter.Browser AS br ON tmp.BrowserName = br.BrowserName
   SET 	tmp.BrowserID = br.BrowserID
		,tmp.BrowserName = br.BrowserName
		,tmp.IsExisting = 1;
   
   SELECT * FROM temp_Browser;
   
END$$

DELIMITER ;