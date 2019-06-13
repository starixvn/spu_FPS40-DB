/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	FPS_StagingRawTrans

Revisions: 
Reviewer: 
*/

CREATE DATABASE FPS_StagingRawTrans;

CREATE TABLE FPS_StagingRawTrans.RawTransaction(	
	DeviceCode		VARCHAR(32) 					NOT NULL
	, LoginName			VARCHAR(50) CHARACTER SET utf8	NOT NULL 				COMMENT 'NVARCHAR'
	, SubscriberName	VARCHAR(30)						NOT NULL
	, TransDate			DATETIME 						NOT NULL
	, CreatedDate		DATETIME 						NOT NULL				COMMENT 'Date Only'
	, IP				VARCHAR(50) 					NULL
	, PluginID			BIGINT							NULL
	, DeviceStatus		TINYINT							NOT NULL  				COMMENT 'Old, New or Retrieve'
	, URL				VARCHAR(250)					NULL
	, ActionResult		VARCHAR(100)					NULL
	, UserAgent			VARCHAR(500)					NULL	
	, CapturedData		VARCHAR(5000) 					NULL
    
    , IsProcessed		TINYINT(1)						NOT NULL	DEFAULT '0'
    , StagingTransID	BIGINT		AUTO_INCREMENT		NOT NULL	

	, PRIMARY KEY PK_RawTransaction_StaingTransID(StagingTransID)
	, INDEX IX_RawTransaction_IsProcessed(IsProcessed)
	, INDEX IX_RawTransaction_CreatedDate(CreatedDate)
	, INDEX IX_RawTransaction_SubscriberName(SubscriberName) 
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;