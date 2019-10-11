USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_GetExceptionByAccountId`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_GetExceptionByAccountId` (IN ip_AccountId BIGINT, IN ip_UserId INT, IN ip_IsMaster TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get evidence by account
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    call FPS_DataCenter.FPS_DC_Rpt_GetExceptionByAccountId(18, 8, 1);
*/    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DROP TEMPORARY TABLE IF EXISTS tmp_ExceptionAccountId;
	CREATE TEMPORARY TABLE tmp_ExceptionAccountId (
		MainAccountId BIGINT
		,ExceptionAccountId BIGINT
        ,TargetEvidenceID BIGINT
		,EviCode VARCHAR(10)
        ,IsActive TINYINT
		);

	INSERT INTO tmp_ExceptionAccountId (
		MainAccountId
		,ExceptionAccountId)
	SELECT ip_AccountId
		,FromAccountID
	FROM FPS_DataCenter.Exception ex
	WHERE ex.ToAccountID = ip_AccountId
		AND ex.IsActive = 1
	UNION
	SELECT ip_AccountId
		,ToAccountID
	FROM FPS_DataCenter.Exception ex
	WHERE ex.FromAccountID = ip_AccountId
		AND ex.IsActive = 1;

	UPDATE tmp_ExceptionAccountId ea
	INNER JOIN TargetEvidence te ON te.TargetID = ea.ExceptionAccountId
		AND te.CentralPointID = ea.ExceptionAccountId
	SET ea.TargetEvidenceID = te.TargetEvidenceID
		, ea.EviCode = te.EvidenceCode
		, ea.IsActive = te.IsActive
	WHERE ip_IsMaster = 1
		OR (
			te.IsCreatedByMaster = 0
			AND te.SubscriberID IN (
				SELECT SubscriberID
				FROM FPS_Admin.UserSubscriber
				WHERE UserID = ip_UserId
				)
			);

	SELECT ea.MainAccountId
		,acc.Username 'MainAccountUsername'
		,ea.ExceptionAccountId 'RootAccountId'
		,acc2.Username 'RootAccountUsername'
		,ea.TargetEvidenceID
        ,ea.EviCode
        ,ea.IsActive
	FROM tmp_ExceptionAccountId ea
		INNER JOIN Account acc ON ea.MainAccountId = acc.AccountID
		INNER JOIN Account acc2 ON ea.ExceptionAccountId = acc2.AccountID
	 WHERE ea.TargetEvidenceID IS NOT NULL;

    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;
