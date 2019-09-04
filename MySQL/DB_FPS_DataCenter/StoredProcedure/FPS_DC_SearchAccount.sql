DELIMITER $$
USE FPS_DataCenter $$
DROP PROCEDURE IF EXISTS FPS_DC_SearchAccount $$

CREATE PROCEDURE FPS_DC_SearchAccount(IN ip_SubscriberIDs LONGTEXT, IN ip_Username VARCHAR(50), IN ip_userId INT)
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
	CREATE TEMPORARY TABLE tmp_SubscriberList( SubscriberID INT, SubscriberName VARCHAR(30) );
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
    SET ip_Username = REPLACE(ip_Username, '_', '\_');
    
    IF ip_SubscriberIDs = '-1' THEN
		INSERT INTO tmp_SubscriberList (SubscriberID, SubscriberName)
        SELECT sub.SubscriberID, sub.SubscriberName
        FROM FPS_Admin.Subscriber AS sub
			INNER JOIN FPS_Admin.UserSubscriber AS us ON us.UserID = ip_userId AND (us.SubscriberID = -1 OR sub.SubscriberID = us.SubscriberID)
		WHERE sub.IsTest = 0 
			AND sub.Status = 1;
    ELSE
		SET @sql = CONCAT("INSERT INTO tmp_SubscriberList (SubscriberID) VALUES ('", REPLACE(ip_SubscriberIDs, ",", "'),('"),"');");
		PREPARE stmt1 from @sql;
		EXECUTE stmt1;    
        
        DELETE FROM tmp_SubscriberList
		WHERE SubscriberID NOT IN ( SELECT us.SubscriberID
									FROM FPS_Admin.UserSubscriber AS us
                                    WHERE us.UserID = ip_userId);
        
        UPDATE tmp_SubscriberList AS tsl,
			FPS_Admin.Subscriber AS sub
		SET tsl.SubscriberName = sub.SubscriberName
        WHERE tsl.SubscriberID = sub.SubscriberID;
    END IF;    
    
    SELECT 	acc.AccountID
		,	acc.CustID
		,	tsl.SubscriberName
        ,	acc.Username
        ,	acc.Username2
    FROM 	FPS_DataCenter.Account AS acc
		INNER JOIN tmp_SubscriberList AS tsl ON acc.SubscriberID = tsl.SubscriberID
    WHERE	(acc.Username LIKE CONCAT('%', ip_Username, '%') OR acc.Username2 LIKE CONCAT('%', ip_Username, '%'))
    ORDER BY acc.Username;	  
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$

DELIMITER ;