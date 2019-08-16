DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_InsertOS $$

CREATE PROCEDURE FPS_DC_InsertOS(IN ip_OS VARCHAR(100), OUT op_OSID INT)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Insert OSName into table OS
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/    
    
    DECLARE LastID INT UNSIGNED;
    
    SET LastID = (SELECT OSID FROM FPS_DataCenter.OS AS br WHERE br.OSName = ip_OS);       
    
    IF LastID is NULL THEN
		INSERT IGNORE INTO FPS_DataCenter.OS(OSName, CreatedDate) VALUES(ip_OS, NOW());
        SET op_OSID = (SELECT MAX(OSID) FROM FPS_DataCenter.OS);  
    ELSE
		SET op_OSID = LastID;
    END IF;
   
END$$

DELIMITER ;