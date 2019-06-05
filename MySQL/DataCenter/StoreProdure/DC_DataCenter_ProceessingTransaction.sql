CREATE DEFINER=`fps`@`%` PROCEDURE `DC_DataCenter_ProceessingTransaction`(inStagingTransXml TEXT)
BEGIN
	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TABLE IF EXISTS Temp_Transaction;
	
	CREATE TEMPORARY TABLE Temp_Transaction( 
		DeviceCode			VARCHAR(32) NOT NULL
		, LoginName			VARCHAR(50) CHARACTER SET utf8 NOT NULL COMMENT 'NVARCHAR'
		, SubscriberName	VARCHAR(30) NOT NULL
		, TransDate			DATETIME NOT NULL
		, IP				VARCHAR(20) NULL
		, Country			VARCHAR(50) NULL
		, CountryCode		VARCHAR(20) NULL
		, Region			VARCHAR(50) NULL
		, City				VARCHAR(50) NULL
		, OS				VARCHAR(20) NULL
		, ISP				VARCHAR(250) CHARACTER SET utf8 DEFAULT NULL COMMENT 'NVARCHAR'
		, Browser			VARCHAR(50) NULL
		, PluginID			BIGINT NULL
		, DeviceStatus		TINYINT NOT NULL  COMMENT 'Old, New or Retrieve'
		, URL				VARCHAR(250) NULL
		, ActionResult		VARCHAR(100) NULL
		, UserAgent			VARCHAR(500) NULL
	);

    
    SET RowCount = extractValue(inRawTransXml,'count(//root/transaction)');
    
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/transaction['
			,   RowIndex
			,   ']');
		
		CALL `FPS_RawTrans`.`RT_RawTrans_Insert`
		( 
		 EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::LoginName'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::TransDate'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::IP'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Country'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::CountryCode'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Region'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::City'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::OS'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::ISP'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Browser'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::PluginID'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DeviceStatus'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::URL'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DI'))
		);
		
		CALL `FPS_RawTrans`.`RT_StagingRawTrans_Insert`
		( 
		 EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::LoginName'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::TransDate'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::IP'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Country'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::CountryCode'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Region'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::City'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::OS'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::ISP'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::Browser'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::PluginID'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DeviceStatus'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::URL'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
		 , EXTRACTVALUE(inRawTransXml,CONCAT(XpathRow,'/attribute::DI'))
		 , 0
		);
    
	END WHILE;	
    
END