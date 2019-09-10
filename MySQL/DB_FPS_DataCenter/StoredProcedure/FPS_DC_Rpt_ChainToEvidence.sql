USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_ChainToEvidence`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_ChainToEvidence` (IN targetId BIGINT, IN targetType TINYINT, IN userId INT, IN isMaster TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get chain to evidence
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_Rpt_ChainToEvidence (186,0,2809,0);
*/

    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT acc.Username 'MainAccount'
		,acc2.Username 'RootAccount'
		,te.EvidenceCode
	FROM FPS_DataCenter.TargetEvidence te
	INNER JOIN FPS_DataCenter.Account acc ON te.TargetID = acc.AccountID
	INNER JOIN FPS_DataCenter.Account acc2 ON te.CentralPointID = acc2.AccountID
	WHERE te.TargetID = targetId
		AND te.TargetType = targetType
		AND (te.IsCreatedByMaster = isMaster OR te.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = userId));
    
    -- We need to handle for Exception !!!
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;
