USE `FPS_Admin`;
DROP procedure IF EXISTS `FPS_AD_InsertSubscriberByUser`;

DELIMITER $$
USE `FPS_Admin`$$
CREATE PROCEDURE `FPS_AD_InsertSubscriberByUser` (in ip_isMasterSub BIT, in ip_subscriberIds LONGTEXT, in ip_userId INT(11), in ip_createdBy INT(11))
BEGIN
	/*
		Created: 20190715@Harvey
		Task : Assign subscriber for user
		DB: FPS_Admin
		Original:

		Revisions: 
		Param's Explanation (filtered by):
	*/    

    DELETE FROM UserSubscriber WHERE UserID = ip_userId;
    INSERT INTO `FPS_Admin`.`UserLog`
		(`LogTypeID`,
		`SPName`,
		`LogInfo`,
		`CreatedDate`,
		`CreatedBy`)
		VALUES
		(3,
		'FPS_AD_InsertSubscriberByUser',
		CONCAT('DELETE FROM UserSubscriber WHERE UserID = ', ip_userId),
		NOW(),
		ip_createdBy);

    
    IF ip_isMasterSub = 1 THEN
		INSERT INTO UserSubscriber (UserID, SubscriberID, CreatedDate, CreatedBy)
		SELECT ip_userId, 0, NOW(), ip_createdBy;
        
        INSERT INTO `FPS_Admin`.`UserLog`
		(`LogTypeID`,
		`SPName`,
		`LogInfo`,
		`CreatedDate`,
		`CreatedBy`)
		VALUES
		(1,
		'FPS_AD_InsertSubscriberByUser',
		CONCAT('INSERT INTO UserSubscriber - list subscriber: Master sub'),
		NOW(),
		ip_createdBy);
    ELSE		
		DROP TEMPORARY TABLE IF EXISTS tmp_SubscriberId;
		CREATE TEMPORARY TABLE tmp_SubscriberId( userId INT, subId INT );
		SET @sql = CONCAT("INSERT INTO tmp_SubscriberId (subId) VALUES ('", REPLACE(ip_subscriberIds, ",", "'),('"),"');");
		PREPARE stmt1 from @sql;
		EXECUTE stmt1;
        
		UPDATE tmp_SubscriberId
		SET userId = ip_userId;		
		
		INSERT INTO UserSubscriber (UserID, SubscriberID, CreatedDate, CreatedBy)
		SELECT userId, subId, NOW(), ip_createdBy 
		FROM tmp_SubscriberId;
        
        INSERT INTO `FPS_Admin`.`UserLog`
		(`LogTypeID`,
		`SPName`,
		`LogInfo`,
		`CreatedDate`,
		`CreatedBy`)
		VALUES
		(1,
		'FPS_AD_InsertSubscriberByUser',
		CONCAT('INSERT INTO UserSubscriber - list subscriber: ', ip_subscriberIds),
		NOW(),
		ip_createdBy);
    END IF;
END$$

DELIMITER ;


--  CALL `FPS_Admin`.`FPS_AD_InsertSubscriberByUser`(1,'', 2,8);


