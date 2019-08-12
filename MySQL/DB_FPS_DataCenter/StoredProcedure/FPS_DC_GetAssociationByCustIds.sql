/*
	Created: 20190620@Harvey
	Task : Get evidence for customer
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_GetAssociationByCustIds (1,1)
*/

USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_GetAssociationByCustIds`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_GetAssociationByCustIds` (in custIds LONGTEXT, in roleId TINYINT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS tmp_CustId;
	CREATE TEMPORARY TABLE tmp_CustId( custId INT );
	SET @sql = CONCAT("INSERT INTO tmp_CustId (custId) VALUES ('", REPLACE(custIds, ",", "'),('"),"');");
	PREPARE stmt1 from @sql;
	EXECUTE stmt1;
        
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
	
    SELECT 
		 acc.CustID 'FromCustId'
		,acc2.CustID 'ToCustId'
		,acc2.Username 'ToOWUsername'
		,acc2.CurrencyName
	FROM FPS_DataCenter.Account acc
		INNER JOIN tmp_CustId cus ON acc.CustID = cus.CustID
		INNER JOIN FPS_DataCenter.Association ass ON acc.AccountID = ass.AccountID AND acc.SubscriberID = ass.SubscriberID
		INNER JOIN FPS_DataCenter.Association ass2 ON ass.DeviceID = ass2.DeviceID
		INNER JOIN FPS_DataCenter.Account acc2 ON acc2.AccountID = ass2.AccountID AND acc2.SubscriberID = ass2.SubscriberID
	WHERE acc.CustID <> acc2.CustID AND acc2.RoleID = roleId;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;



-- CALL `FPS_DataCenter`.`FPS_DC_GetAssociationByCustomers`('1234',1);
