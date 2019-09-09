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

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_UpdateAccountID$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_UpdateAccountID(IN ip_AccountIDJson JSON)
BEGIN
    
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_UpdateAccountID' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	DROP TEMPORARY TABLE IF EXISTS temp_Transaction;    
	CREATE TEMPORARY TABLE temp_Transaction (
		 StagingTransID BIGINT
	);
    
    INSERT INTO temp_Transaction
		(	
			 StagingTransID
		)
	SELECT	tmpAcc.StagingTransID
	FROM JSON_TABLE(	ip_AccountIDJson
						, "$[*]" COLUMNS(	StagingTransID 	BIGINT PATH "$.StagingTransID")        
					) AS tmpAcc;
                 
	UPDATE 		FPS_DataCenter.Transaction AS ts
    INNER JOIN	temp_Transaction AS tmpAcc
				ON ts.StagingTransID = tmpAcc.StagingTransID
	INNER JOIN	FPS_DataCenter.Account AS acc USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
				ON ts.LoginNameWithPrefixID IN (acc.FirstLoginNameID, acc.UsernameID, acc.Username2ID)
	SET			ts.AccountID = acc.AccountID;
   
    	
    	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);  

    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
            
            
END$$
DELIMITER ;
