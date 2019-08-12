DELIMITER $$
USE FPS_Admin $$
DROP PROCEDURE IF EXISTS FPS_AD_GetAllSubscribers $$

CREATE PROCEDURE FPS_AD_GetAllSubscribers (IN ip_userId INT)
BEGIN
	/*
		Created:	20190715@Harvey
		Task:		Get subscriber by assigned status [Redmine ID: 116528]
		DB:			FPS_Admin
		Original:

		Revisions:
        
		Param's Explanation (filtered by):
	*/
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        

    SELECT	sub.SubscriberID
		,	sub.SubscriberName
		,	CASE WHEN us.UserID IS NOT NULL THEN 1 ELSE 0 END AS 'isAssigned'
        ,	EXISTS(SELECT UserID FROM dbo.UserSubscriber us WHERE UserID = ip_userId AND SubscriberID = -1) 'IsMaster'
	FROM FPS_Admin.Subscriber AS sub 
		LEFT JOIN FPS_Admin.UserSubscriber AS us ON sub.SubscriberID = us.SubscriberID AND us.UserID = ip_userId
	WHERE (us.UserID IS NULL OR us.UserID = ip_userId)
        AND sub.IsTest = 0 
        AND sub.Status = 1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;