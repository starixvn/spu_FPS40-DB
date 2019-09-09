USE `FPS_DataCenter`;
DROP PROCEDURE IF EXISTS `FPS_DC_CheckAccountExist`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE FPS_DC_CheckAccountExist(IN ip_AccountListXML LONGTEXT)
BEGIN
	/*
		Created:	20190723@Harvey.Nguyen
		Task :		Check accounts if they are existed in account table
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
	
	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    ### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_CheckAccountExist' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;
    
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe), 0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    ### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS temp_Accounts;    
	CREATE TEMPORARY TABLE temp_Accounts (
		 LoginName	VARCHAR(50)		CHARACTER SET utf8
		, SubName	VARCHAR(50)
	);
    
    
	SET RowCount = EXTRACTVALUE(ip_AccountListXML, 'count(//root/account)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/account['
			,   RowIndex
			,   ']');
            
		INSERT INTO temp_Accounts
		(	
			 LoginName
			, SubName
		)
		VALUES
		( 
			 EXTRACTVALUE(ip_AccountListXML, CONCAT(XpathRow, '/attribute::LoginName'))
			, EXTRACTVALUE(ip_AccountListXML, CONCAT(XpathRow, '/attribute::SubName'))
		);
		
	END WHILE;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
    SELECT 	 ta.LoginName
			, LOWER(CONCAT(sub.SubscriberPrefix, ta.LoginName))  AS LoginNameWithPrefix
			, ta.SubName 'SubscriberName'
            , sub.SubscriberName
            , sub.SubscriberID
            , sub.IsDeposit
            , ac.AccountID
			, CASE WHEN acc.AccountID IS NULL then 0 ELSE 1 END 'IsExisted'
    FROM 		temp_Accounts ta 
	LEFT JOIN	FPS_Admin.Subscriber sub 
				ON sub.SubscriberName = ta.SubName
	LEFT JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID)
			ON  CRC32(LOWER(CONCAT(sub.SubscriberPrefix, ta.LoginName))) IN (ac.FirstLoginNameID, ac.UsernameID, ac.Username2ID);
            
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
    
	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT('NoOfAccount', (SELECT COUNT(1) FROM temp_Accounts));
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond, StartTime, EndTime));
	### PERFORMANCE 
END$$
DELIMITER ;
