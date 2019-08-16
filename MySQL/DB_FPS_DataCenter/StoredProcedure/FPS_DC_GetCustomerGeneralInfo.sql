DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_GetCustomerGeneralInfo$$

CREATE PROCEDURE FPS_DC_GetCustomerGeneralInfo (IN ip_accountId INT)
BEGIN
	/*
		Created: 20190815@Long.Luu
		Task : Get Customer General info for Search Account Details
		DB: FPS_DataCenter
		Original:

		Revisions:
		
		Param's Explanation (filtered by):
	*/
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TABLE IF EXISTS Temp_Account;
	
	CREATE TEMPORARY TABLE Temp_Account
    ( 
		AccountID 		BIGINT
	,	SubscriberID 	SMALLINT
	,	IsDeposit 		TINYINT
	,	FirstLoginName	VARCHAR(50) 
	,	CustID 			BIGINT
	,	Username 		VARCHAR(50) 
	,	Username2 		VARCHAR(50) 
	,	RoleID 			TINYINT
	,	CurrencyID 		TINYINT
	,	CurrencyName	VARCHAR(50) 
	,	CreatedDate 	DATETIME 
	);
    
    SELECT 	`AccountID` 		= acc.AccountID 
		,	`CustID` 			= acc.CustID
        ,	`FirstLoginName`	= acc.FirstLoginName
        ,	`Username` 			= acc.Username
        ,	`Username2` 		= acc.Username2
        ,	`CurrencyID` 		= acc.CurrencyID
        ,	`CurrencyName` 		= acc.CurrencyName
        ,	`SubscriberID` 		= acc.SubscriberID
        ,	`RoleID` 			= acc.RoleID
        ,	`IsDeposit` 		= acc.IsDeposit
        ,	`CreatedDate` 		= acc.CreatedDate
    FROM FPS_DataCenter.Account AS acc
    WHERE acc.AccountID = ip_accountId;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

