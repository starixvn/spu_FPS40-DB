/*
Creator: 20190521@John
Task:	 FPS Reform [Redmine ID: 105252]
Server:  
DBName:	FPS_Admin

Revisions: 
Reviewer:
*/

CREATE DATABASE FPS_Admin;


CREATE TABLE FPS_Admin.Subscriber (
	SubscriberID		INT			NOT NULL	AUTO_INCREMENT
,	SubscriberName		VARCHAR(30) NOT NULL
,	SubScriberPrefix	VARCHAR(30) NULL
,	CreatedDate			DATETIME 	NULL
,	CreatedBy			INT NULL
,	IsDeposit			TINYINT(1)	NULL				
,	Status				TINYINT(1)	NOT NULL					COMMENT '0: Inactive; 1: Active; 2: Unhandle (sub that not integrate, is insert new from transaction)'
,	IsTest				TINYINT(1)	NULL
,	PRIMARY KEY	PK_Subscriber_SubscriberID (SubscriberID)
,	INDEX IX_Subscriber_SubscriberName_SubScriberPrefix (SubscriberName,SubScriberPrefix)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

CREATE TABLE FPS_Admin.UserSubscriber (
	UserID				INT 		NOT NULL
,	SubscriberID		INT			NOT NULL
,	CreatedDate			DATETIME 	NULL
,	CreatedBy			INT			NULL
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE FPS_Admin.LogType (
	LogTypeID			SMALLINT 						NOT NULL	AUTO_INCREMENT
,	LogTypeName			VARCHAR(50) 					NOT NULL
,	LogTypeDescription	VARCHAR(200) CHARACTER SET utf8 NULL 						COMMENT 'NVARCHAR'
,	PRIMARY KEY	PK_LogType_LogTypeID (LogTypeID)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

CREATE TABLE FPS_Admin.UserLog (
	LogTypeID			SMALLINT 						NOT NULL
,	SPName				VARCHAR(100)					NULL
,	LogInfo				VARCHAR(500) CHARACTER SET utf8 NULL COMMENT 'NVARCHAR'
,	CreatedDate			DATETIME NULL
,	CreatedBy			INT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;