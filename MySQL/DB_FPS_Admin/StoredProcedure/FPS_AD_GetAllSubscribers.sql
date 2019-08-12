DELIMITER $$
USE FPS_Admin $$
DROP PROCEDURE IF EXISTS FPS_AD_GetAllSubscribers $$

CREATE PROCEDURE FPS_AD_GetAllSubscribers (IN ip_userId INT)
BEGIN
	/*
		Created:	20190812@Long.Luu
		Task:		Get all subscribers [Redmine ID: 117399]
		DB:			FPS_Admin
		Original:

		Revisions:
        
		Param's Explanation (filtered by):
	*/
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        

    SELECT	sub.SubscriberID
		,	sub.SubscriberName
	FROM dbo.Subscriber sub
	WHERE sub.IsTest = 0 
        AND sub.Status = 1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;