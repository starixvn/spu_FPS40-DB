/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Account_Insert$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Account_Insert(IN ip_AccountXml LONGTEXT)
BEGIN
	DECLARE RowIndex 			INT DEFAULT 0;
	DECLARE RowCount 			INT;
	DECLARE XpathRow 			VARCHAR(50);
    DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
    DECLARE DeviceStatusNew			TINYINT DEFAULT 1;			# New Device
    DECLARE DeviceStatusExisting	TINYINT DEFAULT 2;			# Existing Device has not been recover
    DECLARE DeviceStatusRecover		TINYINT DEFAULT 3;			# Recover Device	
    
    ####
    
    DECLARE StartTime			DATETIME;
    DECLARE ENDTime				DATETIME;
   
    SET StartTime	= CURRENT_TIMESTAMP();
    #=========================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Account;
	
	CREATE TEMPORARY TABLE Temp_Account
    ( 
        SubscriberID		BIGINT
        , IsDeposit			TINYINT
		, LoginName			VARCHAR(50)
        , LoginNameWithPrefix VARCHAR(100)
		, CreatedDate		DATETIME        
		, CustID			BIGINT
		, Username			VARCHAR(50)
		, Username2			VARCHAR(50)
		, RoleID			TINYINT			
		, CurrencyID		SMALLINT
		, CurrencyName		VARCHAR(50)        
	);   
  
    #========1.GET DATA FROM XML TO TEMP TABLE=================================================================================
    SET RowCount = EXTRACTVALUE(ip_AccountXml,'count(//root/account)');      
      
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/account['
			,   RowIndex
			,   ']');                         
		INSERT INTO Temp_Account(SubscriberID, IsDeposit, LoginName, LoginNameWithPrefix, CustID, Username, Username2, RoleID, CurrencyID, CurrencyName, CreatedDate)
		SELECT 	EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::SubscriberID'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::IsDeposit'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::LoginName')) 
                , EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::LoginNameWithPrefix'))  
                , EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::CustID'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::Username'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::Username2'))
                , EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::RoleID'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::CurrencyID'))
				, EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::CurrencyName'))
                , EXTRACTVALUE(ip_AccountXml,CONCAT(XpathRow,'/attribute::CreatedDate'))
		;
	END WHILE;
    
	INSERT INTO FPS_DataCenter.Account
		(
		SubscriberID
        , IsDeposit
		, FirstLoginName
        , CreatedDate
        , CustID
		, Username
		, Username2		
		, RoleID
		, CurrencyID
		, CurrencyName		
		)
	SELECT    
		tac.SubscriberID
        , tac.IsDeposit
		, tac.LoginName
        , tac.CreatedDate
        , tac.CustID
		, tac.Username #(CASE WHEN CustID IS NULL THEN LoginName ELSE tac.Username END) AS Username
		, tac.Username2		
		, tac.RoleID
		, tac.CurrencyID
		, tac.CurrencyName
	FROM		Temp_Account AS tac
	LEFT JOIN	FPS_DataCenter.Account AS acc
				ON	tac.SubscriberID = acc.SubscriberID
					AND	( 	tac.LoginName = acc.FirstLoginName
							OR tac.LoginName = acc.UserName
                            OR tac.LoginNameWithPrefix = acc.Username2
						)
	WHERE	acc.AccountID IS NULL;

END$$
DELIMITER ;
