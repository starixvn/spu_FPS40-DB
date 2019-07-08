/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	 FPS_DataCenter

Reviewer: Billy
*/

CREATE DATABASE IF NOT EXISTS FPS_RawTrans;

DROP TABLE IF EXISTS  FPS_RawTrans.RawTransaction;
CREATE TABLE FPS_RawTrans.RawTransaction (
	LoginName					VARCHAR(50) CHARACTER SET utf8	NOT NULL	COMMENT 'NVARCHAR'
	, SubscriberName			VARCHAR(50) 					NOT NULL
	, TransDate					BIGINT	 						NOT NULL
	, CreatedDate				BIGINT	 						NOT NULL	COMMENT 'Date Only'
	, DeviceCode				VARCHAR(32) 					NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
    , DeviceCodeStatus			TINYINT 						NULL		COMMENT '0: NULL, 1: New, 2: OLD'
    , FingeringCode				VARCHAR(5000)					NULL		COMMENT 'Device Fingering Codes, the hashcode bases on the set attributes'    
    , FingeringMoreInfo			TEXT		 					NULL
    , UserAgent					VARCHAR(500) 					NULL
	, IP						VARCHAR(50) 					NULL
	, PluginID					BIGINT 							NULL	
	, URL						VARCHAR(250) 					NULL
	, ActionResult				VARCHAR(100) 					NULL

) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

