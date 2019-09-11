
DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_Insert$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_Insert(IN ip_AccountJson JSON)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Insert Account
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/

    ####
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_DataCenter_Process_Account_Insert' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END

    #=========================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Account;
	
	CREATE TEMPORARY TABLE Temp_Account
    ( 
        SubscriberID			BIGINT
        , IsDeposit				TINYINT
		, LoginName				VARCHAR(50)
        , LoginNameWithPrefix	VARCHAR(100)
		, CreatedDate			DATETIME        
		, CustID				BIGINT
		, Username				VARCHAR(50)
		, Username2				VARCHAR(50)
		, RoleID				TINYINT			
		, CurrencyID			SMALLINT
		, CurrencyName			VARCHAR(50)        
	);   
      
    INSERT INTO Temp_Account(
				SubscriberID, 
				IsDeposit, 
				LoginName, 
				LoginNameWithPrefix,
				CustID, 
				Username, 
				Username2, 
				RoleID, 
				CurrencyID, 
				CurrencyName, 
				CreatedDate)
	SELECT *
			 FROM
			   JSON_TABLE(
				ip_AccountJson,
				 "$[*]" COLUMNS(
				  SubscriberID 			BIGINT PATH "$.SubscriberID"         
				, IsDeposit				TINYINT PATH "$.IsDeposit"   
				, LoginName				VARCHAR(50) PATH "$.LoginName"   
				, LoginNameWithPrefix 	VARCHAR(100) PATH "$.LoginNameWithPrefix"   
				, CustID				BIGINT PATH "$.CustID"   
				, Username				VARCHAR(50) PATH "$.Username"   
				, Username2				VARCHAR(50) PATH "$.Username2"   
				, RoleID				TINYINT	PATH "$.RoleID"   
				, CurrencyID			SMALLINT PATH "$.CurrencyID"   
				, CurrencyName			VARCHAR(50) PATH "$.CurrencyName"  
                , CreatedDate			DATETIME PATH "$.CreatedDate"
				 )
			   ) AS  tmpAcc;
               
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
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
        , FirstLoginNameID
        , UsernameID
		, Username2ID	
		)
	SELECT    
		tac.SubscriberID
        , tac.IsDeposit
		, tac.LoginName
        , tac.CreatedDate
        , tac.CustID
		, tac.Username
		, tac.Username2		
		, tac.RoleID
		, tac.CurrencyID
		, tac.CurrencyName
        , CRC32(LOWER(tac.LoginNameWithPrefix)) AS FirstLoginNameID
        , CRC32(LOWER(tac.Username)) AS UsernameID
		, CRC32(LOWER(tac.Username2)) AS Username2ID	
	FROM		Temp_Account AS tac
	LEFT JOIN	FPS_DataCenter.Account AS acc USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
				ON CRC32(LOWER(tac.LoginNameWithPrefix)) IN (acc.FirstLoginNameID, acc.UsernameID, acc.Username2ID)
	WHERE	acc.AccountID IS NULL;	

    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
	
    SET Notes = CONCAT('NoOfAccount',(SELECT COUNT(1) FROM Temp_Account));
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    	
    #============================================
	DROP TEMPORARY TABLE IF EXISTS Temp_Account;
    #==============================================
	
END$$
DELIMITER ;
