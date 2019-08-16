DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_InsertBrowser $$

CREATE PROCEDURE FPS_DC_InsertBrowser(IN ip_Browser VARCHAR(100), OUT op_BrowserID INT)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Insert BrowserName into table Browser
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/   
    
    DECLARE LastID INT UNSIGNED;
    
    SET LastID = (SELECT BrowserID FROM FPS_DataCenter.Browser AS br WHERE br.BrowserName = ip_Browser);       
    
    IF LastID is NULL THEN
		INSERT IGNORE INTO FPS_DataCenter.Browser(BrowserName, CreatedDate) VALUES(ip_Browser, NOW());
        SET op_BrowserID = (SELECT MAX(BrowserID) FROM FPS_DataCenter.Browser);  
    ELSE
		SET op_BrowserID = LastID;
    END IF;
   
END$$

DELIMITER ;