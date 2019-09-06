USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_Rpt_GetAssociationByAccount`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_Rpt_GetAssociationByAccount` (IN accountId BIGINT)
BEGIN
/*
	Created: 20190827@Harvey
	Task : Get association for report
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_Rpt_GetAssociationByAccount (47)
*/
	
    DROP TEMPORARY TABLE IF EXISTS associationInfo;
	CREATE TEMPORARY TABLE associationInfo(AccountId INT, AssociatedAccount INT, AssociatedDevice INT, SharedDevices INT, NonShareDevices INT, AccountException INT );
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    INSERT INTO associationInfo (AccountId, AssociatedAccount, AssociatedDevice)
    SELECT ass.AccountID
		,count(ass2.AccountID) 'AssociatedAccount'
		,count(DISTINCT ass.DeviceID) 'AssociatedDevice'
	FROM Association ass
	LEFT JOIN Association ass2 ON ass.DeviceID = ass2.DeviceID
		AND ass.AccountID <> ass2.AccountID
	WHERE ass.AccountID = accountId;
    
    UPDATE associationInfo
    SET SharedDevices = (SELECT count(1)
						 FROM Association ass
						 LEFT JOIN Association ass2 ON ass.DeviceID = ass2.DeviceID
							AND ass.AccountID <> ass2.AccountID
						 WHERE ass.AccountID = accountId
							AND ass2.AccountID IS NOT NULL);
	
    UPDATE associationInfo
    SET NonShareDevices = (SELECT count(1)
							FROM Association ass
							LEFT JOIN Association ass2 ON ass.DeviceID = ass2.DeviceID
								AND ass.AccountID <> ass2.AccountID
							WHERE ass.AccountID = accountId
								AND ass2.AccountID IS NULL);
                                
	UPDATE associationInfo
    SET AccountException = (SELECT count(1)
							FROM Exception
							WHERE AccountID = accountId
								AND IsActive = 1);
   
	SELECT AccountId
		,AssociatedAccount
		,AssociatedDevice
		,SharedDevices
		,NonShareDevices
		,AccountException
	FROM associationInfo;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    DROP TABLE associationInfo;

END$$

DELIMITER ;
