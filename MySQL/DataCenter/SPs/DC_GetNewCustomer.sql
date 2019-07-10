/*
	Created: 20190620@Harvey
	Task : Get Customer for updating IBC info
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_GetNewCustomer`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_GetNewCustomer` (in ip_Size int)
BEGIN
	   
    SELECT acc.AccountID
			, acc.SubscriberID
            , (CASE	WHEN acc.IsDeposit = 1 THEN CONCAT(sub.SubscriberPrefix, acc.FirstLoginName) 
					ELSE acc.FirstLoginName END) AS LoginName
	FROM		FPS_DataCenter.Account acc
	INNER JOIN	FPS_Admin.Subscriber sub
				ON acc.SubscriberID = sub.SubscriberID
	WHERE 	acc.IsDeposit IS NOT NULL
			AND acc.CustID IS NULL
    LIMIT ip_Size;
  
END$$

DELIMITER ;
