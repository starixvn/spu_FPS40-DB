USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_ChainToEvidence`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_ChainToEvidence` (IN ip_TargetId BIGINT, IN ip_TargetType TINYINT, IN ip_UserId INT, IN ip_IsMaster TINYINT, IN ip_IsActiveEvidence TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get chain to evidence
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_Rpt_ChainToEvidence (1995,0,6,1,1);
*/

    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT acc.AccountID 'MainAccountID' 
		,acc.Username 'MainAccount'
		,acc2.AccountID 'RootAccountID'
		,acc2.Username 'RootAccount'
		,te.EvidenceCode
        -- ,te.IsActive
	FROM FPS_DataCenter.TargetEvidence te
		INNER JOIN FPS_DataCenter.Account acc ON te.TargetId = acc.AccountID
		INNER JOIN FPS_DataCenter.Account acc2 ON te.CentralPointID = acc2.AccountID
	WHERE te.TargetId = ip_TargetId
		AND te.TargetType = ip_TargetType
        AND te.IsActive = ip_IsActiveEvidence
		AND (ip_IsMaster = 1
			OR (te.IsCreatedByMaster = 0 
				AND te.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = ip_UserId)));
    
    -- We need to handle for Exception !!!
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;
