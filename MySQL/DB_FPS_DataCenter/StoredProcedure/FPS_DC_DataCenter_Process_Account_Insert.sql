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
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_Account_Insert' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    ### PERFORMANCE: END

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
        , UNUN2
		)
	SELECT    
		tac.SubscriberID
        , tac.IsDeposit
		, tac.LoginName
        , tac.CreatedDate
        , tac.CustID
		, tac.Username #(CASE WHEN CustID IS NULL THEN LoginName ELSE tac.Username END) AS Username
		, (CASE WHEN tac.CustID IS NULL THEN LoginName ELSE tac.LoginNameWithPrefix END) AS Username2 #tac.Username2		
		, tac.RoleID
		, tac.CurrencyID
		, tac.CurrencyName
        , (CASE WHEN tac.IsDeposit = 1	THEN CONCAT(';',tac.LoginNameWithPrefix,';')
										ELSE CONCAT(';', tac.UserName,';', tac.UserName2,';')
										END)
	FROM		Temp_Account AS tac
	LEFT JOIN	FPS_DataCenter.Account AS acc USE INDEX (IX_Account_SubscriberID_FirstLoginName_UserName_Username2)
				ON	tac.SubscriberID = acc.SubscriberID
					AND acc.UNUN2 LIKE CONCAT('%;', REPLACE(tac.LoginNameWithPrefix,'_','\_'),';%')
	WHERE	acc.AccountID IS NULL;	
    	
	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
	
    SET Notes = CONCAT('NoOfAccount',(SELECT COUNT(1) FROM Temp_Account));
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 
    
END$$
DELIMITER ;
