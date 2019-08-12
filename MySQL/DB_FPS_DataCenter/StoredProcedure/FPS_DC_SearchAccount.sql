DELIMITER $$
USE FPS_DataCenter $$
DROP PROCEDURE IF EXISTS FPS_DC_SearchAccount $$

CREATE PROCEDURE FPS_DC_SearchAccount(IN ip_SubscriberID SMALLINT, IN ip_Username VARCHAR(50))
BEGIN
	/*
		Created:	20190812@Long.Luu
		Task :		Search Account
		DB:			FPS_DataCenter
		Original:

		Revisions:
        
		Param's Explanation (filtered by):
	*/

	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT 	*
    FROM 	dbo.Account AS acc
    WHERE	acc.SubscriberID = ip_SubscriberID
		AND (acc.Username LIKE CONCAT('%', ip_Username, '%') OR acc.Username2 LIKE CONCAT('%', ip_Username, '%'));	  
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$

DELIMITER ;