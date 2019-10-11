USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_InsertException`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_InsertException` (IN ip_MainAccountId BIGINT, IN ip_RootAccountId BIGINT, IN ip_SubscriberId INT, IN ip_Remark VARCHAR(200), IN ip_CreatedBy INT)
BEGIN
/*
	Created: 20190913@Harvey
	Task : Insert exception
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
		ip_MainAccountId: account is shown on report
        ip_RootAccountId: account has root evidence
    
    Flow:
		1. Insert exception
        2. Delete Evidence level 2 !!
    CALL FPS_DC_InsertException (7180,1995,6,'Harvey Test',1);
*/

    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
       
	IF NOT EXISTS (SELECT 1
					FROM Exception ex
					WHERE ex.FromAccountID IN (ip_MainAccountId, ip_RootAccountId)
						OR ex.ToAccountID IN (ip_MainAccountId, ip_RootAccountId)
					) THEN
	INSERT INTO Exception (
		FromAccountID
		,ToAccountID
		,SubscriberID
		,Remark
		,CreatedDate
		,CreatedBy
		,IsActive
		)
	VALUES (
		ip_MainAccountId
		,ip_RootAccountId
		,ip_SubscriberId
		,ip_Remark
		,current_timestamp()
		,ip_CreatedBy
		,1);
	END IF ;
    
    DELETE te
	FROM FPS_DataCenter.TargetEvidence te
	WHERE te.TargetID = ip_MainAccountId
		AND te.CentralPointID = ip_RootAccountId
		AND te.TargetLevel = 2
        AND te.SubscriberID = ip_SubscriberId;    
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;
