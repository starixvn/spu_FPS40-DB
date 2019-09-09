/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_RawTransaction$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Account$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Account(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	
    DECLARE		HandleStatus TINYINT DEFAULT 1;

	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_Account' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500) DEFAULT 'Start Get MinMax';
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    
    ### PERFORMANCE: END

    
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
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 
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
  
	#========INSERT: URL if not Existing============================================================================ 
    INSERT INTO FPS_DataCenter.SubscriberURL (SubscriberID, URL, CreatedDate)
    SELECT 		ta.SubscriberID
				, ta.URL
				, MIN(ta.CreatedDate) AS CreatedDate
    FROM		Temp_Account AS ta
	LEFT JOIN	FPS_DataCenter.SubscriberURL AS ur
				ON ur.SubscriberID = ta.SubscriberID
                AND	ur.URL = ta.URL
	WHERE		ur.URL IS NULL
    GROUP BY	ta.SubscriberID, ta.URL;  
    
	SELECT 		ta.LoginName
				, LOWER(CONCAT(ta.SubscriberPrefix, ta.LoginName)) AS LoginNameWithPrefix
				, ta.SubscriberName
				, ta.SubscriberID
				, ta.IsDeposit
				, MIN(ta.CreatedDate) AS CreatedDate
	FROM		Temp_Account AS ta
	LEFT JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
				ON ta.LoginNameWithPrefixID IN (ac.FirstLoginNameID, ac.UsernameID, ac.Username2ID)
	WHERE		ac.AccountID IS NULL
	GROUP BY	ta.LoginName, ta.SubscriberPrefix, ta.SubscriberName, ta.SubscriberID, ta.IsDeposit;	
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    ### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
    
	#============================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Account;
    #==============================================
	
	### PERFORMANCE 
END$$
DELIMITER ;
