/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	FPS_StagingRawTrans

Revisions: 
Reviewer: 
*/

CREATE DATABASE IF NOT EXISTS FPSS_RawTransaction;

CREATE TABLE FPS_RawTransaction.RawTransaction(	
	LoginName					VARCHAR(50)						NOT NULL
	, SubscriberName			VARCHAR(50) 					NOT NULL
	, TransDate					TIMESTAMP(4) 					NOT NULL
	, CreatedDate				DATETIME						NOT NULL	COMMENT 'Date Only'
	, DeviceCode				VARCHAR(32) 					NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
	, FingerprintCode			VARCHAR(640)					NULL		COMMENT 'Device Fingerprint Codes, the hashcode bases on the set attributes'
	, FingerprintMoreInfo		TEXT		 					NULL
	, UserAgent					TEXT 							NULL
	, IP						VARCHAR(50) 					NULL
	, PluginID					BIGINT 							NULL
	, URL						VARCHAR(250) 					NULL
	, ActionResult				VARCHAR(100) 					NULL
    
    , IsProcessed		TINYINT							NOT NULL	DEFAULT '0'
    , StagingTransID	BIGINT		AUTO_INCREMENT		NOT NULL	

	, PRIMARY KEY PK_RawTransaction_StaingTransID(StagingTransID)
	, INDEX IX_RawTransaction_IsProcessed(IsProcessed)
	, INDEX IX_RawTransaction_CreatedDate(CreatedDate, SubscriberName)
	, INDEX IX_RawTransaction_SubscriberName(SubscriberName)
    
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
