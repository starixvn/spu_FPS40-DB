USE `FPS_DataCenter`;
DROP procedure IF EXISTS `DC_GetTotalAssociationByCustomers`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `DC_GetTotalAssociationByCustomers` (in custIds LONGTEXT, in roleId TINYINT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS tmp_CustId;
	CREATE TEMPORARY TABLE tmp_CustId( custId INT );
	SET @sql = CONCAT("INSERT INTO tmp_CustId (custId) VALUES ('", REPLACE(custIds, ",", "'),('"),"');");
	PREPARE stmt1 from @sql;
	EXECUTE stmt1;
	SELECT DISTINCT (custId) 
		FROM tmp_CustId;
        
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
	
    SELECT 
		 acc.CustID
		,COUNT(DISTINCT acc2.CustID) 'TotalAssociation'
	FROM Account acc
		INNER JOIN tmp_CustId cus ON acc.CustID = cus.CustID
		INNER JOIN Association ass ON acc.AccountID = ass.AccountID AND acc.SubscriberID = ass.SubscriberID
		INNER JOIN Association ass2 ON ass.DeviceID = ass2.DeviceID
		INNER JOIN Account acc2 ON acc2.AccountID = ass2.AccountID AND acc2.SubscriberID = ass2.SubscriberID
	WHERE acc.CustID <> acc2.CustID AND acc2.RoleID = roleId
    GROUP BY acc.CustID;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

-- CALL `FPS_DataCenter`.`DC_GetTotalAssociationByCustomers`('1234');
