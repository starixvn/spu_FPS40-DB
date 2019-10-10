
DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Account_GetFromRawTransaction$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Account_GetFromRawTransaction(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Get Account List to Process From DrawTransaction
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/

    DECLARE		HandleStatus TINYINT DEFAULT 1;

	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName	VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Account_GetFromRawTransaction' ;
    DECLARE		vrStepID	INT;
	DECLARE 	vrNotes	 	VARCHAR(500);
	DECLARE 	vrStartTime	TIMESTAMP(4);
	DECLARE		vrEndTime 	TIMESTAMP(4);
	DECLARE		vrDuration 	BIGINT;	
    DECLARE		vrFromID	BIGINT;
    DECLARE		vrToID		BIGINT;
    DECLARE		vrBegin		BIGINT;
    DECLARE		vrTotalRecord		INT;
  
    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Get Acount From Raw Trasaction';	
    SET 	vrStepID = 1;
    
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);	
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, FromID, ToID)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_FromStagingTransID, ip_ToStagingTransID);    
    
	### PERFORMANCE: END  
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS Temp_Account;
    CREATE TEMPORARY TABLE Temp_Account 
    (
		SubscriberID		SMALLINT
        , SubscriberName	VARCHAR(30)
        , SubscriberPrefix	VARCHAR(30)
        , IsDeposit			TINYINT
        , URL				VARCHAR(250)
        , ActionResult		VARCHAR(100)
        , LoginName			VARCHAR(50)	
        , CreatedDate		DATETIME
        , LoginNameWithPrefixID	BIGINT
    );	
 
    INSERT INTO Temp_Account (SubscriberID, SubscriberName, SubscriberPrefix, IsDeposit, URL, LoginName, CreatedDate, LoginNameWithPrefixID)
    SELECT 		su.SubscriberID
				, su.SubscriberName
                , su.SubscriberPrefix
                , su.IsDeposit
                , rt.URL
                , rt.LoginName
				, MIN(rt.CreatedDate)
                , CRC32(LOWER(CONCAT(su.SubscriberPrefix, rt.LoginName))) AS LoginNameWithPrefixID
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName AND su.Status = HandleStatus
    WHERE		(rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID)
				AND rt.IsProcessed = 0
    GROUP BY	su.SubscriberID
				, rt.URL
				, rt.LoginName;    
   
	SELECT 		ta.LoginName
				, LOWER(CONCAT(ta.SubscriberPrefix, ta.LoginName)) AS LoginNameWithPrefix
				, ta.SubscriberName
				, ta.SubscriberID
				, ta.IsDeposit
				, MIN(ta.CreatedDate) AS CreatedDate
	FROM		Temp_Account AS ta
	LEFT JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_ACCOUNT_SUBSCRIBERID_FIRSTLOGINNAMEID_USERNAMEID_USERNAME2ID)
				ON  ta.SubscriberID = ac.SubscriberID
					AND ta.LoginNameWithPrefixID IN (ac.FirstLoginNameID, ac.UsernameID, ac.Username2ID)
	WHERE		ac.AccountID IS NULL
	GROUP BY	ta.LoginName, ta.SubscriberPrefix, ta.SubscriberName, ta.SubscriberID, ta.IsDeposit;	 
    
   	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	### PERFORMANCE
    SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END 	
    
	#============================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Account;
    #==============================================
	
END$$
DELIMITER ;
