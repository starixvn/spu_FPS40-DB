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
    
    SET @LastLogin = CURRENT_TIMESTAMP();
    SET @LoginCount = 0;
    SET @AccountStatus = 0;
    
    SELECT @AccountStatus = 1
    FROM FPS_DataCenter.TargetEvidence AS te
    WHERE te.TargetID = ip_accountId;
    
    SELECT @AccountStatus = 2
    FROM FPS_DataCenter.TargetEvidence AS te
    WHERE te.CentralPointID = ip_accountId;
    
    SELECT 	@LastLogin = MAX(t.CreatedDate)
		,	@LoginCount = COUNT(1)
    FROM FPS_DataCenter.Transaction AS t
    WHERE t.AccountID = ip_accountId;
    
    SELECT 	acc.AccountID AS `AccountID`
		,	acc.CustID AS `CustID`
        ,	@AccountStatus AS `AccountStatus`	
        ,	acc.FirstLoginName AS `FirstLoginName`
        ,	acc.Username AS `Username`
        ,	acc.Username2 AS `Username2`
        ,	acc.CurrencyID AS `CurrencyID` 
        ,	acc.CurrencyName AS `CurrencyName` 		
        ,	acc.SubscriberID AS `SubscriberID` 
        ,	acc.RoleID AS `RoleID` 	
        ,	acc.IsDeposit AS `IsDeposit` 
        ,	acc.CreatedDate AS `CreatedDate` 		
        ,	@LastLogin AS `LastLoginDate`		
        ,	@LoginCount AS `LoginCount`
        ,	DATEDIFF(acc.CreatedDate, @LastLogin) AS `AccountAge`	
    FROM FPS_DataCenter.Account AS acc    
    WHERE acc.AccountID = ip_accountId;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

