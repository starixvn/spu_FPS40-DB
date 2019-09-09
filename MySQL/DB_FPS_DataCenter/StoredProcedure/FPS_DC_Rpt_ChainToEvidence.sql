USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_ChainToEvidence`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_ChainToEvidence` (IN targetId BIGINT, IN targetType TINYINT, IN subIdList LONGTEXT, IN isMaster TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get chain to evidence
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_Rpt_ChainToEvidence (186,0,'6',0);
*/
	DROP TEMPORARY TABLE IF EXISTS tmp_SubId;
	CREATE TEMPORARY TABLE tmp_SubId( subId INT );
    
	SET @sql = CONCAT("INSERT INTO tmp_SubId (subId) VALUES ('", REPLACE(subIdList, ",", "'),('"),"');");
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT acc.Username 'MainAccount'
		,acc2.Username 'RootAccount'
		,te.EvidenceCode
	FROM FPS_DataCenter.TargetEvidence te
	INNER JOIN FPS_DataCenter.Account acc ON te.TargetID = acc.AccountID
	INNER JOIN FPS_DataCenter.Account acc2 ON te.CentralPointID = acc2.AccountID
	WHERE te.TargetID = targetId
		AND te.TargetType = targetType
		AND (te.IsCreatedByMaster = isMaster OR te.SubscriberID IN (SELECT subId FROM tmp_SubId));
    
    -- We need to handle for Exception !!!
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    DROP TABLE tmp_SubId;

END$$

DELIMITER ;
