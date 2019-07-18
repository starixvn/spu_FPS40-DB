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

DROP PROCEDURE IF EXISTS FPS_RawTrans.FPS_RT_RawTrans_InsertByXML$$

CREATE PROCEDURE FPS_RawTrans.FPS_RT_RawTrans_InsertByXML(IN ip_RawTransXml LONGTEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TEMPORARY TABLE IF EXISTS Temp_RawTransaction;
    
	CREATE TEMPORARY TABLE Temp_RawTransaction (
		LoginName					VARCHAR(50) CHARACTER SET utf8	NOT NULL	COMMENT 'NVARCHAR'
		, SubscriberName			VARCHAR(50) 					NOT NULL
		, TransDate					DATETIME 						NOT NULL
		, DeviceCode				VARCHAR(32) 					NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
        , DeviceCodeStatus			TINYINT 						NULL		COMMENT 'Old, New'
		, FingeringCode				VARCHAR(5000)					NULL		COMMENT 'Device Fingering Codes, the hashcode bases on the set attributes'
		, FingeringMoreInfo			TEXT		 				NULL
		, UserAgent					VARCHAR(500) 					NULL
		, IP						VARCHAR(50) 					NULL
		, PluginID					BIGINT 							NULL
		, URL						VARCHAR(250) 					NULL
		, ActionResult				VARCHAR(100) 					NULL
	);
    
	SET RowCount = EXTRACTVALUE(ip_RawTransXml,'count(//root/transaction)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/transaction['
			,   RowIndex
			,   ']');
            
		INSERT INTO Temp_RawTransaction
		(	LoginName
			, SubscriberName
            , TransDate
            , DeviceCode
            , DeviceCodeStatus
            , FingeringCode
            , FingeringMoreInfo
            , UserAgent
            , IP
            , PluginID
            , URL
            , ActionResult
		)
		VALUES
		( 
		 EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::LoginName'))
         , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
         , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::TransDate'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::DeviceCodeStatus'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::FingeringCode'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::FingeringMoreInfo'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::IP'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::PluginID'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::URL'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
		);
		
	END WHILE;
    
    INSERT INTO FPS_RawTrans.RawTransaction
	(	LoginName
		, SubscriberName
		, TransDate
		, CreatedDate
		, DeviceCode
        , DeviceCodeStatus
		, FingeringCode
		, FingeringMoreInfo
		, UserAgent
		, IP
		, PluginID
		, URL
		, ActionResult
	)
	SELECT
		rt.LoginName
		, rt.SubscriberName
		, rt.TransDate
		, DATE(rt.TransDate) AS CreatedDate
		, rt.DeviceCode
        , rt.DeviceCodeStatus
		, rt.FingeringCode
		, rt.FingeringMoreInfo
		, rt.UserAgent
		, rt.IP
		, rt.PluginID
		, rt.URL
		, rt.ActionResult
	FROM	Temp_RawTransaction rt;    
    
END$$
DELIMITER ;
