DELIMITER $$
USE FPS_DataCenter $$
DROP PROCEDURE IF EXISTS FPS_DC_SearchAccount $$

CREATE PROCEDURE FPS_DC_SearchAccount(IN ip_SubscriberIDs LONGTEXT, IN ip_Username VARCHAR(50))
BEGIN
	/*
		Created:	20190812@Long.Luu
		Task :		Search Account
		DB:			FPS_DataCenter
		Original:

		Revisions:
        
		Param's Explanation (filtered by):
	*/
	
    DROP TEMPORARY TABLE IF EXISTS tmp_SubscriberList;
	CREATE TEMPORARY TABLE tmp_SubscriberList( SubscriberID INT );
	SET @sql = CONCAT("INSERT INTO tmp_SubscriberList (SubscriberID) VALUES ('", REPLACE(ip_SubscriberIDs, ",", "'),('"),"');");
	PREPARE stmt1 from @sql;
	EXECUTE stmt1;
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT 	acc.AccountID
		,	sub.SubscriberName
        ,	acc.Username
        ,	acc.Username2
    FROM 	FPS_DataCenter.Account AS acc
		INNER JOIN tmp_SubscriberList AS tsl ON acc.SubscriberID = tsl.SubscriberID
		INNER JOIN FPS_Admin.Subscriber AS sub ON acc.SubscriberID = sub.SubscriberID
    WHERE	(acc.Username LIKE CONCAT('%', ip_Username, '%') OR acc.Username2 LIKE CONCAT('%', ip_Username, '%'));	  
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$

DELIMITER ;