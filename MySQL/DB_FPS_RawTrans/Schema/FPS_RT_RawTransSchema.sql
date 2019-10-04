/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	 FPSB_DataCenter

Reviewer: 
*/

CREATE DATABASE IF NOT EXISTS FPS_RawTransaction;

DROP TABLE IF EXISTS FPS_RawTransaction.RawTransaction;
CREATE TABLE FPS_RawTransaction.RawTransaction(
	LoginName					VARCHAR(50) 					 	NOT NULL	
	, SubscriberName			VARCHAR(50) 						NOT NULL
	, TransDate					TIMESTAMP(4)	 					NOT NULL
	, CreatedDate				DATETIME	 						NOT NULL	COMMENT 'Date Only'
	, DeviceCode				VARCHAR(62) 						NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
    , FingerprintCode			VARCHAR(2000)						NULL		COMMENT 'Device Fingerprint Codes, the hashcode bases on the set attributes'    
    , FingerprintMoreInfo		TEXT	CHARACTER SET UTF8MB4		NULL
    , UserAgent					TEXT		 						NULL
	, IP						VARCHAR(50) 						NULL
	, PluginID					BIGINT 								NULL	
	, URL						VARCHAR(500) 						NULL
	, ActionResult				VARCHAR(100) 						NULL
	, InvalidDevice				TEXT	CHARACTER SET UTF8MB4		NULL
    , TransStatus				TINYINT								NULL	  COMMENT 	'1: Valid; -1: InvalidDeviceCode'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


