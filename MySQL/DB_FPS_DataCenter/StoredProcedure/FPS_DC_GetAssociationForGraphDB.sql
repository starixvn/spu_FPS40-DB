DELIMITER $$
USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_GetAssociationForGraphDB;
CREATE PROCEDURE FPS_DataCenter.FPS_DC_GetAssociationForGraphDB(IN ip_SyncGraphDB TINYINT, IN ip_Size INT)
BEGIN
	/*
	Created:	20190610@Casey.Huynh
	Task :		Get Association list by SyncGraphDB status;
	DB:			FPS_DataCenter
	Original:

	Revisions:
		- 20191022@Harvey.Nguyen:	remove temp table & get more column
	Param's Explanation (filtered by):
	*/
    #=========================================================================================
	   
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    

	SELECT	ass.AssociationID
			, ass.DeviceID
			, ass.AccountID
            , ass.CreatedDate		'AssociatedDate'	
			, sub.SubscriberID
			, sub.SubscriberName
			, sub.IsDeposit
			, acc.CustID
			, acc.Username
			, acc.Username2
			, acc.RoleID
			, acc.CurrencyID
			, acc.CurrencyName
            , acc.CreatedDate		'AccountCreatedDate'
	FROM		FPS_DataCenter.Association ass
	INNER JOIN	FPS_Admin.Subscriber sub
				ON ass.SubscriberID = sub.SubscriberID
	INNER JOIN	FPS_DataCenter.Account acc
				ON ass.AccountID = acc.AccountID
	WHERE	ass.SyncGraphDB = ip_SyncGraphDB
			AND sub.IsDeposit IS NOT NULL
			AND acc.CustID IS NOT NULL AND acc.CustID <> 0
	LIMIT ip_Size;	
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$
DELIMITER ;


