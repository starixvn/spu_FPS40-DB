#DROP PROCEDURE IF EXISTS FPS_RawTrans.RT_RawTrans_InsertByXML;

DELIMITER $$
USE `FPS_RawTrans`$$


CREATE DEFINER=`fps`@`%` PROCEDURE `RT_RawTrans_InsertByXML`(IN ip_RawTransXml TEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TABLE IF EXISTS Temp_RawTransaction;

	CREATE TEMPORARY TABLE Temp_RawTransaction (
	  DeviceCode 		VARCHAR(32) NOT NULL,
	  LoginName 		VARCHAR(50) CHARACTER SET UTF8 NOT NULL COMMENT 'NVARCHAR',
	  SubscriberName 	VARCHAR(30) NOT NULL,
	  TransDate 		DATETIME NOT NULL,
	  IP 				VARCHAR(20) DEFAULT NULL,
	  PluginID 			BIGINT(20) DEFAULT NULL,
	  DeviceStatus 		TINYINT(4) NOT NULL COMMENT 'Old, New or Retrieve',
	  URL 				VARCHAR(250) DEFAULT NULL,
	  ActionResult 		VARCHAR(100) DEFAULT NULL,
	  UserAgent 		VARCHAR(500) DEFAULT NULL,
	  CapturedData 		VARCHAR(5000) DEFAULT NULL
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
		
		CALL `FPS_RawTrans`.`RT_StagingRawTrans_Insert`
		( 
		 EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
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
		 , 0
		);
    
	END WHILE;
    
    INSERT INTO FPS_RawTrans.RawTransaction
	(	DeviceCode
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
	SELECT
			DeviceCode
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
	FROM	Temp_RawTransaction;
    
    
END$$
DELIMITER ;