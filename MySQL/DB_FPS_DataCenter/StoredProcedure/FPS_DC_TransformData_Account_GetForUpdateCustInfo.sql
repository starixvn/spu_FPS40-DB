DELIMITER $$

USE FPSB_DataCenter$$

DROP PROCEDURE IF EXISTS FPSB_DataCenter.FPSB_DC_TransformData_Account_GetForUpdateCustInfo$$

CREATE PROCEDURE FPSB_DataCenter.FPSB_DC_TransformData_Account_GetForUpdateCustInfo (in ip_Size INT)
BEGIN
	/*
		Created: 20190620@Harvey
		Task : Get Account for updating IBC info
		DB: FPSB_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
		SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
		SELECT acc.AccountID
				, acc.SubscriberID
				, (CASE	WHEN acc.IsDeposit = 1 THEN CONCAT(sub.SubscriberPrefix, acc.FirstLoginName) 
						ELSE acc.FirstLoginName END) AS LoginName
		FROM		FPSB_DataCenter.Account acc
		INNER JOIN	FPSB_Admin.Subscriber sub
					ON acc.SubscriberID = sub.SubscriberID
		WHERE 	acc.IsDeposit IS NOT NULL
				AND acc.CustID IS NULL
		LIMIT 	ip_Size;
		SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;

