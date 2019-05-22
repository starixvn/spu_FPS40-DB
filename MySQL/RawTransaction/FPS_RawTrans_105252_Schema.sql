/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  FPS_RawTrans

Reviewer: Billy
*/

CREATE DATABASE FPS_RawTrans;

CREATE TABLE IF NOT EXISTS FPS_RawTrans.RawTransaction (
	DeviceCode		VARCHAR(32) NOT NULL
,	LoginName		VARCHAR(50) CHARACTER SET utf8 NOT NULL COMMENT 'NVARCHAR'
,	SubscriberName	VARCHAR(30) NOT NULL
,	TransDate		DATETIME NOT NULL
,	IP				VARCHAR(20) NULL
,	Country			VARCHAR(50) NULL
,	CountryCode		VARCHAR(20) NULL
,	Region			VARCHAR(50) NULL
,	City			VARCHAR(50) NULL
,	OS				VARCHAR(20) NULL
,	ISP				VARCHAR(250) CHARACTER SET utf8 DEFAULT NULL COMMENT 'NVARCHAR'
,	Browser			VARCHAR(50) NULL
,	PluginID		BIGINT NULL
,	DeviceStatus	TINYINT NOT NULL  COMMENT 'Old, New or Retrieve'
,	URL				VARCHAR(250) NULL
,	ActionResult	VARCHAR(100) NULL
,	UserAgent		VARCHAR(500) NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS FPS_RawTrans.StagingRawTransaction (
	DeviceCode		VARCHAR(32) NOT NULL
,	LoginName		VARCHAR(50) CHARACTER SET utf8 NOT NULL COMMENT 'NVARCHAR'
,	SubscriberName	VARCHAR(30) NOT NULL
,	TransDate		DATETIME NOT NULL
,	CreatedDate		DATETIME NOT NULL COMMENT 'Date Only'
,	IP				VARCHAR(20) NULL
,	Country			VARCHAR(50) NULL
,	CountryCode		VARCHAR(20) NULL
,	Region			VARCHAR(50) NULL
,	City			VARCHAR(50) NULL
,	OS				VARCHAR(20) NULL
,	ISP				VARCHAR(250) CHARACTER SET utf8 DEFAULT NULL COMMENT 'NVARCHAR'
,	Browser			VARCHAR(50) NULL
,	PluginID		BIGINT NULL
,	DeviceStatus	TINYINT NOT NULL  COMMENT 'Old, New or Retrieve'
,	URL				VARCHAR(250) NULL
,	ActionResult	VARCHAR(100) NULL
,	UserAgent		VARCHAR(500) NULL
,	IsProcessed		TINYINT(1) NOT NULL DEFAULT '0'
,	KEY `NCIX_StagingRawTransaction_IsProcessed` (`IsProcessed`)
,	KEY `NCIX_StagingRawTransaction_CreatedDate` (`CreatedDate`)
,	KEY `NCIX_StagingRawTransaction_SubscriberName` (`SubscriberName`) 
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;