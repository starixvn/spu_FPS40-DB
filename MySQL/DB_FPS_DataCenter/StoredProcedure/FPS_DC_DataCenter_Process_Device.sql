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

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Device$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Device(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	
	DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
    
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
    CREATE TEMPORARY TABLE Temp_Transaction 
    (	
		StagingTransID		BIGINT
		, LoginName			VARCHAR(50)      
        , DeviceCode		VARCHAR(32)
        , FingeringCode		TEXT
        , FingeringMoreInfo	TEXT
        , CreatedDate		DATETIME
        , TransDate			DATETIME
        
        , AccountID			BIGINT
        , SubscriberID		INT
        , IsDeposit			TINYINT
        , DeviceID			INT
        , DeviceCodeID		INT
        , DeviceFingeringID INT
    );
    #==================================================================
	DROP TEMPORARY TABLE IF EXISTS Temp_AccountDevice;
    CREATE TEMPORARY TABLE Temp_AccountDevice 
    (		
		AccountID			BIGINT
        , DeviceID			BIGINT
        , DeviceCode		VARCHAR(32)
        , DeviceFingering	TEXT
        , CreatedDate		DATETIME
    );
    
    #==================================================================
    INSERT INTO Temp_Transaction (StagingTransID, LoginName, DeviceCode, FingeringCode, FingeringMoreInfo
				, CreatedDate, TransDate, AccountID, SubscriberID, IsDeposit)
    SELECT		rt.StagingTransID
				, rt.LoginName
                , rt.DeviceCode
                , rt.FingeringCode
                , rt.FingeringMoreInfo
                , rt.CreatedDate
                , rt.TransDate
                , ac.AccountID
                , su.SubscriberID
                , su.IsDeposit               
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
	INNER JOIN	FPS_DataCenter.Account AS ac
				ON	ac.SubscriberID = su.SubscriberID
	WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND IsProcessed = 0
                AND (rt.LoginName = ac.FirstLoginName
						OR rt.LoginName = ac.UserName
						OR Concat(su.SubscriberPrefix, rt.LoginName) = ac.Username2);  
    
END$$
DELIMITER ;
