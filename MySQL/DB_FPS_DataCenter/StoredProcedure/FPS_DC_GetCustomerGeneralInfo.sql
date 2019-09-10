DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_GetCustomerGeneralInfo$$

CREATE PROCEDURE FPS_DC_GetCustomerGeneralInfo (IN ip_accountId INT, IN ip_isMaster BOOL, IN ip_userId INT)
BEGIN
	/*
		Created: 20190815@Long.Luu
		Task : Get Customer General info for Search Account Details
		DB: FPS_DataCenter
		Original:

		Revisions:
		
		Param's Explanation (filtered by):
			- @AccountEvidenceStatus: 1 (clean), 2 (to be flagged), 0 (central point)
            
		call FPS_DataCenter.FPS_DC_GetCustomerGeneralInfo(9907, 1, 8);
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
    SET @AccountEvidenceStatus = 1;
    
    IF EXISTS (SELECT 1 FROM FPS_DataCenter.TargetEvidence AS te WHERE te.TargetID = ip_accountId AND (te.IsCreatedByMaster = ip_isMaster OR te.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = ip_userId))) THEN
		SET @AccountEvidenceStatus = 2;
    END IF;
    
    IF EXISTS (SELECT 1 FROM FPS_DataCenter.TargetEvidence AS te WHERE te.CentralPointID = ip_accountId AND (te.IsCreatedByMaster = ip_isMaster OR te.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = ip_userId))) THEN
		SET @AccountEvidenceStatus = 0;
    END IF;
    
    SELECT 	MAX(t.CreatedDate) INTO @LastLogin
    FROM FPS_DataCenter.Transaction AS t
    WHERE t.AccountID = ip_accountId;
    
    SELECT COUNT(1) INTO @LoginCount
    FROM FPS_DataCenter.Transaction AS t
    WHERE t.AccountID = ip_accountId;
    
    SELECT 	acc.AccountID AS `AccountID`
		,	acc.CustID AS `CustID`
        ,	@AccountEvidenceStatus AS `AccountEvidenceStatus`	
        ,	acc.FirstLoginName AS `FirstLoginName`
        ,	acc.Username AS `Username`
        ,	acc.Username2 AS `Username2`
        ,	acc.CurrencyID AS `CurrencyID` 
        ,	acc.CurrencyName AS `CurrencyName` 		
        ,	acc.SubscriberID AS `SubscriberID` 
        ,	s.SubscriberName AS `SubscriberName` 
        ,	acc.RoleID AS `RoleID` 	
        ,	acc.IsDeposit AS `IsDeposit` 
        ,	acc.CreatedDate AS `CreatedDate` 		
        ,	@LastLogin AS `LastLoginDate`		
        ,	@LoginCount AS `LoginCount`
        ,	ABS(DATEDIFF(acc.CreatedDate, @LastLogin)) AS `AccountAge`	
    FROM FPS_DataCenter.Account AS acc    
		INNER JOIN FPS_Admin.Subscriber AS s ON acc.SubscriberID = s.SubscriberID
    WHERE acc.AccountID = ip_accountId;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

