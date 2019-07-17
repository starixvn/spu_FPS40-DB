USE `FPS_Admin`;
DROP procedure IF EXISTS `FPS_AD_GetSubscriberByAssignedStatus`;

DELIMITER $$
USE `FPS_Admin`$$
CREATE PROCEDURE `FPS_AD_GetSubscriberByAssignedStatus` (in ip_userId INT(11))
BEGIN
	/*
		Created: 20190715@Harvey
		Task : Get subscriber by assigned status
		DB: FPS_DataCenter
		Original:

		Revisions: 
		Param's Explanation (filtered by):
	*/
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
    SELECT sub.SubscriberID
		, sub.SubscriberName
		, CASE WHEN us.UserID IS NOT NULL THEN 1 ELSE 0 END AS 'isAssigned'
	FROM Subscriber sub LEFT JOIN UserSubscriber us ON sub.SubscriberID = us.SubscriberID AND us.UserID = ip_userId
	WHERE us.UserID = ip_userId OR us.UserID IS NULL AND sub.IsTest = 0 AND sub.Status = 1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;


  CALL `FPS_Admin`.`FPS_AD_GetSubscriberByAssignedStatus`(1);

