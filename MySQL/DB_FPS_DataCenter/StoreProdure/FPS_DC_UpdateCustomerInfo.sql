/*
	Created: 20190620@Harvey
	Task : Get IBC info
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

USE FPS_DataCenter;
DROP procedure IF EXISTS FPS_DC_UpdateCustomerInfo;

DELIMITER $$
USE FPS_DataCenter$$
CREATE PROCEDURE FPS_DC_UpdateCustomerInfo (in custDataXml LONGTEXT, OUT op_ErrorCode TINYINT(1), OUT op_ErrorMessage VARCHAR(500))
BEGIN
	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    #=======================
    DROP TABLE IF EXISTS Temp_Account;
	
	CREATE TEMPORARY TABLE Temp_Account
    ( 
		AccountID 		BIGINT (20) 
	,	SubscriberID 		SMALLINT (6) 
	,	IsDeposit 		TINYINT (1) 
	,	FirstLoginName	VARCHAR(50) 
	,	CustID 			BIGINT (20) 
	,	Username 			VARCHAR(50) 
	,	Username2 		VARCHAR(50) 
	,	RoleID 			TINYINT (4) 
	,	CurrencyID 		TINYINT (4) 
	,	CurrencyName		VARCHAR(50) 
	,	CreatedDate 		DATETIME 
	);

	#=====================================================
    SET op_ErrorCode =0;
    SELECT op_ErrorMessage='Successfull';
    
    SET RowCount = extractValue(custDataXml,'count(//root/customer)');
    
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/customer['
			,   RowIndex
			,   ']');            
            
		#========1.GET DATA FROM XML TO TEMP TABLE===============================
		
		INSERT INTO Temp_Account(AccountID, SubscriberID, IsDeposit, FirstLoginName, CustID, Username, Username2, RoleID, CurrencyID, CurrencyName, CreatedDate)
		SELECT 	EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::AccountID'))
				, EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::SubscriberID'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::IsDeposit'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::FirstLoginName'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::CustID'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::Username'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::Username2'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::RoleID'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::CurrencyID'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::CurrencyName'))
				 , EXTRACTVALUE(custDataXml,CONCAT(XpathRow,'/attribute::CreatedDate')
		);
    
	END WHILE;
    
    UPDATE FPS_DataCenter.Account AS acc
	INNER JOIN Temp_Account tempAcc ON acc.AccountID = tempAcc.AccountID
		AND acc.SubscriberID = tempAcc.SubscriberID
	SET acc.CustID = tempAcc.CustID
		,acc.Username = tempAcc.Username
		,acc.Username2 = tempAcc.Username2
		,acc.RoleID = tempAcc.RoleID
		,acc.CurrencyID = tempAcc.CurrencyID
		,acc.CurrencyName = tempAcc.CurrencyName;

END$$

DELIMITER ;

