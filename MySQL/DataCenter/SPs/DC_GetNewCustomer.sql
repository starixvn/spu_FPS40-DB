USE `FPS_DataCenter`;
DROP procedure IF EXISTS `DC_GetNewCustomer`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `DC_GetNewCustomer` (in size int)
BEGIN
	SET @rowId = 0;
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
	
    SELECT	tempAccount.AccountID
			,tempAccount.SubscriberID
            ,tempAccount.LoginName
    FROM (SELECT acc.AccountID
				,acc.SubscriberID
				,CASE 
					WHEN acc.IsDeposit
						THEN CONCAT (
								sub.SubscriberPrefix
								,acc.FirstLoginName
								)
					ELSE acc.FirstLoginName
					END AS LoginName
				,@rowId := @rowId + 1 RowNumber
			FROM FPS_DataCenter.Account acc
				INNER JOIN FPS_Admin.Subscriber sub ON acc.SubscriberID = sub.SubscriberID
			WHERE CustID IS NULL
				AND acc.IsDeposit IS NOT NULL
			ORDER BY acc.CreatedDate ASC) tempAccount
	WHERE RowNumber <= size
	LIMIT 999999;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;
