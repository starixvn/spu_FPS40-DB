DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_UpdateUserAgent $$

CREATE PROCEDURE FPS_DC_UpdateUserAgent(IN ip_UserAgentXML LONGTEXT)
BEGIN
	 /*
		Created:	20190815@Terry.Nguyen
		Task :		Update BroserID and OSID into table UserAgent
		DB:			FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/ 
    
	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);    
    
    #=======================
    
    DROP TABLE IF EXISTS Temp_UserAgent;
	
	CREATE TEMPORARY TABLE Temp_UserAgent
    ( 
		UserAgentID 		BIGINT (20) 
	,	BrowserID 		INT 
	,	OSID 		INT	
	);
    
    #=======================
    
    SET RowCount = extractValue(ip_UserAgentXML,'count(//root/useragent)');
    
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/useragent['
			,   RowIndex
			,   ']');            
            
		#========1.GET DATA FROM XML TO TEMP TABLE===============================
		
		INSERT INTO Temp_UserAgent(UserAgentID, BrowserID, OSID)
		SELECT 	EXTRACTVALUE(ip_UserAgentXML,CONCAT(XpathRow,'/attribute::UserAgentID'))
				, EXTRACTVALUE(ip_UserAgentXML,CONCAT(XpathRow,'/attribute::BrowserID'))
				 , EXTRACTVALUE(ip_UserAgentXML,CONCAT(XpathRow,'/attribute::OSID')				
		);    
	END WHILE;
    
     #=======================
     
     UPDATE FPS_DataCenter.UserAgent as us INNER JOIN Temp_UserAgent AS tmp 
     ON us.UserAgentID = tmp.UserAgentID
     SET us.BrowserID = tmp.BrowserID,
		 us.OSID = tmp.OSID	;
   
END$$

DELIMITER ;