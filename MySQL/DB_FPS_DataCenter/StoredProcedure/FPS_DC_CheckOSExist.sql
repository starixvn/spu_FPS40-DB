DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_CheckOSExist $$

CREATE PROCEDURE FPS_DC_CheckOSExist(IN ip_OSXML LONGTEXT)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Check accounts if they are existed in OS table
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/    
    DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TEMPORARY TABLE IF EXISTS temp_OS;    
	CREATE TEMPORARY TABLE temp_OS (
		 UserAgentID INT,
         OSID INT,
		 OSName	VARCHAR(100),
         IsExisting INT
	);
    
    SET RowCount = EXTRACTVALUE(ip_OSXML,'count(//root/os)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/os['
			,   RowIndex
			,   ']');
            
		INSERT INTO temp_OS
		(	
			 UserAgentID
			,OSID
			,OSName
            ,IsExisting
		)
		VALUES
		( 
			 EXTRACTVALUE(ip_OSXML,CONCAT(XpathRow,'/attribute::UserAgentID'))
			,0
			,EXTRACTVALUE(ip_OSXML,CONCAT(XpathRow,'/attribute::OSName'))
            ,0
		);
		
	END WHILE;
   
    UPDATE temp_OS AS tmp INNER JOIN FPS_DataCenter.OS AS br ON tmp.OSName = br.OSName
   SET 	tmp.OSID = br.OSID
		,tmp.OSName = br.OSName
		,tmp.IsExisting = 1;
   
   SELECT * FROM temp_OS;
   
END$$

DELIMITER ;