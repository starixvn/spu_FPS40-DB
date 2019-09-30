DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_UpdateCustomerInfo$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_UpdateCustomerInfo (IN custDataXml LONGTEXT, OUT op_ErrorCode TINYINT, OUT op_ErrorMessage VARCHAR(500))
BEGIN
/*
	Created: 20190620@Harvey
	Task : Get Account To Update Cust Info
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    ### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_UpdateCustomerInfo' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    DECLARE		NoOfAccount	INT;
    ### PERFORMANCE: END
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
	
    ### PERFORMANCE: START
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
	
    
    #=======================
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

	#=====================================================
    SET op_ErrorCode =0;
    SELECT op_ErrorMessage='Successfull';
    
    SET RowCount = EXTRACTVALUE(custDataXml,'count(//root/customer)');
    
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
    
    UPDATE		FPS_DataCenter.Account AS acc
	INNER JOIN	Temp_Account tempAcc 
				ON	acc.AccountID = tempAcc.AccountID
					AND acc.SubscriberID = tempAcc.SubscriberID
	SET acc.CustID = tempAcc.CustID
		,acc.Username = tempAcc.Username
		,acc.Username2 = tempAcc.Username2
		,acc.RoleID = tempAcc.RoleID
		,acc.CurrencyID = tempAcc.CurrencyID
		,acc.CurrencyName = tempAcc.CurrencyName;
	
    ### PERFORMANCE
	
    SET EndTime = CURRENT_TIMESTAMP(4);
	
    SET NoOfAccount = (SELECT Count(1) FROM Temp_Account);
    SET Notes = CONCAT('NoOfAccount: ', NoOfAccount );	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
END$$

DELIMITER ;

