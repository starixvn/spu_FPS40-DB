/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	 FPS_DataCenter

Reviewer: Billy
*/

CREATE DATABASE FPS_RawTrans;

CREATE TABLE FPS_RawTrans.RawTransaction (
	DeviceCode					VARCHAR(32) 					NULL		COMMENT 'Device Inject Code: 32 characters is auto generated'
    , FingeringCode				VARCHAR(5000)					NULL
	, LoginName					VARCHAR(50) CHARACTER SET utf8	NOT NULL	COMMENT 'NVARCHAR'
	, SubscriberName			VARCHAR(30) 					NOT NULL
	, TransDate					DATETIME 						NOT NULL
	, CreatedDate				DATETIME 						NOT NULL	COMMENT 'Date Only'
	, IP						VARCHAR(50) 					NULL
	, PluginID					BIGINT 							NULL
	, DeviceStatus				TINYINT 						NULL		COMMENT 'Old, New'
	, URL						VARCHAR(250) 					NULL
	, ActionResult				VARCHAR(100) 					NULL
	, UserAgent					VARCHAR(500) 					NULL
	, CapturedData				VARCHAR(5000) 					NULL    

) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

