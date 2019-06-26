/*
	Created: 20190610@Casey.Huynh
	Task : Insert to Raw Table by XML file
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
USE FPS_RawTrans$$

CREATE PROCEDURE FPS_RawTrans.RT_RawTrans_InsertByXML(IN ip_RawTransXml LONGTEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TABLE IF EXISTS Temp_RawTransaction;
    
	CREATE TEMPORARY TABLE Temp_RawTransaction (
	  DeviceCode 		VARCHAR(32) 					NOT NULL
      , FingeringCode	VARCHAR(5000)					NOT NULL
      , LoginName 		VARCHAR(50) CHARACTER SET UTF8	NOT NULL 		COMMENT 'NVARCHAR'
      , SubscriberName 	VARCHAR(30) 					NOT NULL
      , TransDate 		DATETIME						NOT NULL
      , IP 				VARCHAR(50)						NULL
      , PluginID 		BIGINT(20) 						NULL
      , DeviceStatus 	TINYINT(4) 						NULL 			COMMENT 'Old, New or Retrieve'
      , URL 			VARCHAR(250) 					NULL
      , ActionResult 	VARCHAR(100)					NULL
      , UserAgent 		VARCHAR(500)					NULL
      , CapturedData 	VARCHAR(5000)					NULL
	);
    
	SET RowCount = EXTRACTVALUE(ip_RawTransXml,'count(//root/transaction)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/transaction['
			,   RowIndex
			,   ']');
            
		INSERT INTO Temp_RawTransaction
		(	DeviceCode
			, FingeringCode
            , LoginName
            , SubscriberName
            , TransDate
            , IP
            , PluginID
            , DeviceStatus
            , URL
            , ActionResult
            , UserAgent
            , CapturedData
		)
		VALUES
		( 
		 EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
         , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::FingeringCode'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::LoginName'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::TransDate'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::IP'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::PluginID'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::DeviceStatus'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::URL'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::CapturedData'))
		);
		
	END WHILE;
    
    INSERT INTO FPS_RawTrans.RawTransaction
	(	DeviceCode
		, FingeringCode
		, LoginName
		, SubscriberName
		, TransDate
        , CreatedDate
		, IP
		, PluginID
		, DeviceStatus
		, URL
		, ActionResult
		, UserAgent
		, CapturedData
	)
	SELECT
			rt.DeviceCode
            , rt.FingeringCode
			, rt.LoginName
			, rt.SubscriberName
			, rt.TransDate
            , DATE(rt.TransDate) AS CreatedDate
			, rt.IP
			, rt.PluginID
			, rt.DeviceStatus
			, rt.URL
			, rt.ActionResult
			, rt.UserAgent
			, rt.CapturedData
	FROM	Temp_RawTransaction rt;
    
    
END$$
DELIMITER ;
