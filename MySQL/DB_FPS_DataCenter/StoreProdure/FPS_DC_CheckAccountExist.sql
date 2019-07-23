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
    
    DROP TEMPORARY TABLE IF EXISTS temp_Accounts;    
	CREATE TEMPORARY TABLE temp_Accounts (
		 LoginName	VARCHAR(50)
		,SubName	VARCHAR(50)
	);
    
	SET RowCount = EXTRACTVALUE(ip_AccountListXML,'count(//root/account)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/account['
			,   RowIndex
			,   ']');
            
		INSERT INTO temp_Accounts
		(	
			 LoginName
			,SubName
		)
		VALUES
		( 
			 EXTRACTVALUE(ip_AccountListXML,CONCAT(XpathRow,'/attribute::LoginName'))
			,EXTRACTVALUE(ip_AccountListXML,CONCAT(XpathRow,'/attribute::SubName'))
		);
		
	END WHILE;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
    SELECT 	 LoginName
			,SubName 'SubscriberName'
            ,sub.SubscriberID
			,CASE WHEN acc.AccountID IS NULL then 0 ELSE 1 END 'IsExisted'
    FROM temp_Accounts ta 
		INNER JOIN FPS_Admin.Subscriber sub ON sub.SubscriberName = ta.SubName
        LEFT JOIN Account acc ON ta.LoginName = acc.FirstLoginName AND sub.SubscriberID = acc.SubscriberID;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$
DELIMITER ;
