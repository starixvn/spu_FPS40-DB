USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_GetAssociatedAccountByAccount`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_GetAssociatedAccountByAccount` (IN custIds LONGTEXT, IN rootAccountId BIGINT, IN userId INT, IN isMaster TINYINT)
BEGIN
/*
	Created: 20190823@Harvey
	Task : Get associated accounts for report
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL `FPS_DataCenter`.`FPS_DC_Rpt_GetAssociatedAccountByAccount`('4139416,3945234,7777983', 397,2809,0);

*/
	DROP TEMPORARY TABLE IF EXISTS tmp_CustId;
	CREATE TEMPORARY TABLE tmp_CustId( custId INT, accountId INT );
    
	SET @sql = CONCAT("INSERT INTO tmp_CustId (custId) VALUES ('", REPLACE(custIds, ",", "'),('"),"');");
	PREPARE stmt1 from @sql;
	EXECUTE stmt1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
    UPDATE tmp_CustId cus
		INNER JOIN FPS_DataCenter.Account acc ON cus.custId = acc.CustID
	SET cus.accountId = acc.AccountID;
	
    SELECT 	trans.AccountID
			,acc.CustID
			,MAX(trans.TransDate) 		'LastLogin'
			,acc.CreatedDate 			'FirstLogin'
			,COUNT(1) 					'TotalLoginWithRootAccount'
			,MIN(trans2.TransDate) 		'AssociatedWithRootAccountOn'
            ,MIN(tarEvi.TargetLevel)	'EvidenceLevel'
	FROM FPS_DataCenter.Transaction trans
	INNER JOIN FPS_DataCenter.Account acc ON trans.AccountID = acc.AccountID
	INNER JOIN FPS_DataCenter.Transaction trans2 ON trans.DeviceID = trans2.DeviceID
		AND trans2.AccountID = rootAccountId
	LEFT JOIN FPS_DataCenter.TargetEvidence tarEvi ON acc.AccountID = tarEvi.TargetID AND tarEvi.TargetType = 0
	WHERE trans.AccountID IN (SELECT AccountID FROM tmp_CustId) 
		AND (tarEvi.IsCreatedByMaster = isMaster OR tarEvi.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = userId))
	GROUP BY trans.AccountID
		,acc.CreatedDate;
    
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    DROP TABLE tmp_CustId;
END$$

DELIMITER ;
