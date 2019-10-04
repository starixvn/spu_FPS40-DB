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
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_UpdateCustomerInfo' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	
    DECLARE		vrTotalRecord		INT;
    DECLARE		vrFromID	BIGINT;
    DECLARE		vrToID		BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'UpdateCustomerInfo';		
    SET 	vrStepID = 1;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);  
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime);
	  
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
	
    
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
    
    INSERT INTO Temp_Account(AccountID, SubscriberID, IsDeposit, FirstLoginName, CustID, Username, Username2, RoleID, CurrencyID, CurrencyName, CreatedDate)
	SELECT	AccountID
			, SubscriberID
            , IsDeposit
            , FirstLoginName
            , CustID
            , Username
            , Username2
            , RoleID
            , CurrencyID
            , CurrencyName
            , CreatedDate
	FROM
	JSON_TABLE(
				ip_CustomerInfo
				, "$[*]" COLUMNS(
					AccountID 		BIGINT PATH "$.AccountId"
				,	SubscriberID 	SMALLINT PATH "$.SubscriberId"
				,	IsDeposit 		TINYINT PATH "$.IsDeposit"
				,	FirstLoginName	VARCHAR(50) PATH "$.FirstLoginName"
				,	CustID 			BIGINT PATH "$.CustId"
				,	Username 		VARCHAR(50) PATH "$.Username"
				,	Username2 		VARCHAR(50) PATH "$.Username2"
				,	RoleID 			TINYINT PATH "$.RoleId"
				,	CurrencyID 		TINYINT PATH "$.CurrencyId"
				,	CurrencyName	VARCHAR(50) PATH "$.CurrencyName"
				,	CreatedDate 	DATETIME PATH "$.CreatedDate"								 
				)
				) AS  tmpCustomerInfo;
    
    #=====================================================   
    
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
	
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
	### PERFORMANCE
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
END$$

DELIMITER ;

