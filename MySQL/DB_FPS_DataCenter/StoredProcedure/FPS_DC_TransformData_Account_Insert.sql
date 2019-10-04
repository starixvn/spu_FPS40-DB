
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

    ### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_Insert' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	
    DECLARE		vrTotalRecord		INT;
  
    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Insert New Account by Json';	
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime);    
    	
	### PERFORMANCE: END  
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	

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
   
	INSERT IGNORE INTO FPS_DataCenter.Account
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
        , InsertTime
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
        , CURRENT_TIMESTAMP(4) 		AS InsertTime
	FROM		Temp_Account AS tac
	LEFT JOIN	FPS_DataCenter.Account AS acc USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
				ON CRC32(LOWER(tac.LoginNameWithPrefix)) IN (acc.FirstLoginNameID, acc.UsernameID, acc.Username2ID)
	WHERE	acc.AccountID IS NULL;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
    
	### PERFORMANCE  
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    SELECT Count(1)
    INTO	vrTotalRecord
    FROM	Temp_Account AS tts;
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
            , z.TotalRecord = vrTotalRecord
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
    	
    #============================================
	DROP TEMPORARY TABLE IF EXISTS Temp_Account;
    #============================================

END$$
DELIMITER ;
