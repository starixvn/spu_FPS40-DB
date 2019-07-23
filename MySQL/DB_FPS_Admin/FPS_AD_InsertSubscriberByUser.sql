USE `FPS_Admin`;
DROP PROCEDURE IF EXISTS `FPS_AD_InsertSubscriberByUser`;

DELIMITER $$
USE `FPS_Admin`$$
CREATE PROCEDURE `FPS_AD_InsertSubscriberByUser` (IN ip_isMasterSub BIT, IN ip_subscriberIds LONGTEXT, IN ip_userId INT(11), IN ip_createdBy INT(11))
BEGIN
	/*
		Created:	20190715@Harvey
		Task:		Assign subscriber for user [Redmine ID: 116528]
		DB:			FPS_Admin
		Original:
        
		Revisions: 
		Param's Explanation (filtered by):
	*/    

	DECLARE currentTime DATETIME DEFAULT NOW();
    DECLARE listSubForDelete VARCHAR(1000);
    
    SELECT CONCAT_WS(',', GROUP_CONCAT(SubscriberID)) 
    FROM FPS_Admin.UserSubscriber
	WHERE userid = ip_userId
    INTO listSubForDelete;

    DELETE FROM FPS_Admin.UserSubscriber WHERE UserID = ip_userId;
    INSERT INTO `FPS_Admin`.`UserLog`(
			`LogTypeID`
		,	`SPName`
		,	`LogInfo`
		,	`CreatedDate`
		,	`CreatedBy`)
		VALUES(
			3
		,	'FPS_AD_InsertSubscriberByUser'
		,	CONCAT('DELETE UserSubscriber Table - UserID: ', ip_userId, ' - List Subs: ', listSubForDelete)
		,	currentTime
		,	ip_createdBy);

    
    IF ip_isMasterSub = 1 THEN
		INSERT INTO FPS_Admin.UserSubscriber (UserID, SubscriberID, CreatedDate, CreatedBy)
		SELECT ip_userId, 0, NOW(), ip_createdBy;
        
        INSERT INTO `FPS_Admin`.`UserLog`(
			`LogTypeID`
		,	`SPName`
		,	`LogInfo`
		,	`CreatedDate`
		,	`CreatedBy`)
		VALUES(
			1
		,	'FPS_AD_InsertSubscriberByUser'
		,	CONCAT('INSERT UserSubscriber Table - UserID: ', ip_userId, ' - List Subs: 0 (Master Sub)')
		,	currentTime
		,	ip_createdBy);
    ELSE		
		IF ip_subscriberIds <> '' THEN
			DROP TEMPORARY TABLE IF EXISTS tmp_SubscriberId;
			CREATE TEMPORARY TABLE tmp_SubscriberId( userId INT, subId INT );
			SET @sql = CONCAT("INSERT INTO tmp_SubscriberId (subId) VALUES ('", REPLACE(ip_subscriberIds, ",", "'),('"),"');");
			PREPARE stmt1 from @sql;
			EXECUTE stmt1;
			
			UPDATE tmp_SubscriberId
			SET userId = ip_userId;		
			
			INSERT INTO FPS_Admin.UserSubscriber (UserID, SubscriberID, CreatedDate, CreatedBy)
			SELECT userId, subId, NOW(), ip_createdBy FROM tmp_SubscriberId;
			
			INSERT INTO `FPS_Admin`.`UserLog`(
				`LogTypeID`
			,	`SPName`
			,	`LogInfo`
			,	`CreatedDate`
			,	`CreatedBy`)
			VALUES(
				1
			,	'FPS_AD_InsertSubscriberByUser'
			,	CONCAT('INSERT UserSubscriber Table - UserID: ', ip_userId, ' - List Subs: ', ip_subscriberIds)
			,	currentTime
			,	ip_createdBy);
		END IF;
    END IF;
END$$

DELIMITER ;