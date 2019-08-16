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
    );

    INSERT INTO Temp_Account (SubscriberID, SubscriberName, SubscriberPrefix, IsDeposit, URL, LoginName, CreatedDate)
    SELECT 		su.SubscriberID
				, su.SubscriberName
                , su.SubscriberPrefix
                , su.IsDeposit
                , rt.URL
                , rt.LoginName
				, MIN(rt.CreatedDate)
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName AND su.Status = 1
    WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
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
    
	SELECT 		ta.LoginName,
				CONCAT(ta.SubscriberPrefix, ta.LoginName) AS LoginNameWithPrefix,
				ta.SubscriberName,
				ta.SubscriberID,
				ta.IsDeposit,
				MIN(ta.CreatedDate) AS CreatedDate
	FROM		Temp_Account AS ta
	LEFT JOIN	FPS_DataCenter.Account AS ac ON ta.SubscriberID = ac.SubscriberID
				AND (ta.LoginName = ac.FirstLoginName
				OR ta.LoginName = ac.UserName
				OR CONCAT(ta.SubScriberPrefix, ta.LoginName) = ac.Username2)
	WHERE		ac.AccountID IS NULL
	GROUP BY	ta.LoginName , ta.SubscriberPrefix , ta.SubscriberName , ta.SubscriberID , ta.IsDeposit;	 
END$$
DELIMITER ;
