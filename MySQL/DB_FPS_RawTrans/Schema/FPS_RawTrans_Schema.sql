/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	 FPS_DataCenter

Reviewer: Billy
*/

CREATE DATABASE IF NOT EXISTS FPS_RawTransaction;

CREATE TABLE FPS_RawTransaction.RawTransaction (
	LoginName					VARCHAR(50) CHARACTER SET utf8	NOT NULL	COMMENT 'NVARCHAR'
	, SubscriberName			VARCHAR(50) 					NOT NULL
	, TransDate					DATETIME	 					NOT NULL
	, CreatedDate				DATETIME	 					NOT NULL	COMMENT 'Date Only'
	, DeviceCode				VARCHAR(32) 					NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
    , FingeringCode				VARCHAR(5000)					NULL		COMMENT 'Device Fingering Codes, the hashcode bases on the set attributes'    
    , FingeringMoreInfo			TEXT		 					NULL
    , UserAgent					TEXT		 					NULL
	, IP						VARCHAR(50) 					NULL
	, PluginID					BIGINT 							NULL	
	, URL						VARCHAR(250) 					NULL
	, ActionResult				VARCHAR(100) 					NULL

) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


