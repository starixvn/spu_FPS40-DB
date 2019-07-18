USE `FPS_Admin`;
DROP PROCEDURE IF EXISTS `FPS_AD_GetSubscriberByAssignedStatus`;

DELIMITER $$
USE `FPS_Admin`$$
CREATE PROCEDURE `FPS_AD_GetSubscriberByAssignedStatus` (IN ip_userId INT(11))
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
	FROM FPS_Admin.Subscriber sub 
    LEFT JOIN FPS_Admin.UserSubscriber us ON sub.SubscriberID = us.SubscriberID AND us.UserID = ip_userId
	WHERE us.UserID = ip_userId OR us.UserID IS NULL AND sub.IsTest = 0 AND sub.Status = 1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;