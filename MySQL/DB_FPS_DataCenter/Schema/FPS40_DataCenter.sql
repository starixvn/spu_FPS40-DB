/*
Creator: 20190521@Casey.Huynh
Task:    Create Schema FPS4.0 - Data Center
Server:  
DBName:	FPS_DataCenter

Reviewer: 
*/

CREATE DATABASE IF NOT EXISTS FPS_DataCenter;
# ======Device============================================
	CREATE TABLE FPS_DataCenter.Device(
		DeviceID				BIGINT 			AUTO_INCREMENT		
		, FirstDeviceCode		VARCHAR(32) 	NULL
        , FirstFingeringCode	VARCHAR(320) 	NULL
        , FirstAccountID		BIGINT			NULL
        , StagingTransID		BIGINT			NULL
        , CreatedDate			DATETIME		NULL
        , DeviceStatus			TINYINT(1)
        
        , PRIMARY KEY	PK_Device_DeviceID(DeviceID)
        , INDEX			IX_Device_CreatedDate(CreatedDate)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ======Device=============================================
	CREATE TABLE FPS_DataCenter.DeviceCode(
		 
		DeviceCode		VARCHAR(32) 		NOT NULL
        , DeviceID			BIGINT
		, CreatedDate		DATETIME		NOT NULL
        
        , PRIMARY KEY	PK_DeviceCode_DeviceCode(DeviceCode)
        , INDEX			IX_DeviceCode_CreatedDate(CreatedDate)
        , INDEX			IX_DeviceCode_DeviceID(DeviceID)
        
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
     
# ======DeviceDetail=============================================
	CREATE TABLE FPS_DataCenter.DeviceFingering(
		DeviceFingeringID	BIGINT 			AUTO_INCREMENT
        , DeviceID			VARCHAR(32) 	NOT NULL
        , FingeringCode		VARCHAR(320)
		, FingeringMoreInfo	TEXT
        , UserAgentID		INT				NULL
		, PluginID			BIGINT			NULL
        , CreatedDate		DATETIME
        
        , PRIMARY KEY	PK_DeviceFingering_DeviceFingeringID(DeviceFingeringID)        
        , INDEX			IX_DeviceFingering_DeviceCode(DeviceID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
    
# =======Association============================================
	CREATE TABLE FPS_DataCenter.Association(
		AssociationID		BIGINT 		AUTO_INCREMENT
		, DeviceID			BIGINT		NOT NULL
		, AccountID			BIGINT		NOT NULL
		, SubscriberID		SMALLINT	NOT NULL
		, CreatedDate		DATETIME		NOT NULL
		, SyncGraphDB		TINYINT(1)	NOT NULL	COMMENT '0: NOT SENT TO GraphDB, 1: SENT'
        
        , PRIMARY KEY	PK_Association_AssociationID(AssociationID)
        , INDEX	IX_Association_SubscriberID_AccountID(SubscriberID, AccountID)
        , INDEX IX_Association_SubscriberID_DeviceID(SubscriberID, DeviceID)
        , INDEX IX_Association_SyncGraphDB(SyncGraphDB)
        
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======Account============================================
	CREATE TABLE FPS_DataCenter.`Account`(
		AccountID			BIGINT			AUTO_INCREMENT		NOT NULL
        , SubscriberID		SMALLINT							NOT NULL
        , IsDeposit			TINYINT(1)							NULL
        , FirstLoginName	VARCHAR(50)		CHARACTER SET utf8	NOT NULL
		, CustID			BIGINT								NULL
		, Username			VARCHAR(50)		CHARACTER SET utf8	NULL
		, Username2			VARCHAR(50)		CHARACTER SET utf8	NULL
		, RoleID			TINYINT(1)							NULL
		, CurrencyID		TINYINT(2)							NULL
		, CurrencyName		VARCHAR(50)		CHARACTER SET utf8	NULL				
		, CreatedDate		DATETIME							NOT NULL      
        
        , PRIMARY KEY	PK_Account_AccountID(AccountID)        
        , INDEX			IX_Account_CustID(CustID)
        , INDEX			IX_Account_Username(SubscriberID, Username)
        , INDEX			IX_Account_Username2(SubscriberID, Username2)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======Transactions============================================
	CREATE TABLE FPS_DataCenter.`Transaction`(
		TransID				BIGINT			AUTO_INCREMENT		NOT NULL
        , DeviceID			BIGINT								NULL
        , DeviceCode		VARCHAR(32)							NULL
		, DeviceFingeringID	BIGINT								NULL
		, LoginName			VARCHAR(50)		CHARACTER SET utf8	NOT NULL	
		, AccountID			BIGINT								NOT NULL
		, SubscriberID		SMALLINT							NULL	
		, TransDate			DATETIME							NOT	NULL
		, CreatedDate		DATETIME							NULL		COMMENT 'Date Only'	NOT	NULL
		, IP				DECIMAL(50,0)						NULL
        , IPRangeLocationID	BIGINT								NULL
		, PluginID			BIGINT								NULL
		, Flagged			TINYINT(2)							NULL		COMMENT 'captcha & browserless'
		, SubURLID			SMALLINT							NULL
		, ActionResultID	TINYINT(2)							NULL
		, UserAgentID		INT									NULL
        , StagingTransID	BIGINT			UNIQUE				NOT NULL
        
        , PRIMARY KEY	PK_Transaction_TransID(TransID)        
        , INDEX			IX_Transaction_DeviceID(DeviceID)
        , INDEX			IX_Transaction_SubscriberIDAccountID(SubscriberID,AccountID)
        , INDEX			IX_Transaction_CreatedDate(CreatedDate)
	 ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	CREATE TABLE FPS_DataCenter.OS(
		OSID			TINYINT(2)			AUTO_INCREMENT			NOT NULL
		, OSName		VARCHAR(100)								NULL
        , CreatedDate	DATETIME									NOT NULL
        
        , PRIMARY KEY 	PK_OS_ISID(OSID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
# ===========================================================================
	CREATE TABLE FPS_DataCenter.Browser(
		BrowserID			TINYINT(2)			AUTO_INCREMENT	NOT NULL
		, BrowserName		VARCHAR(100)						NOT NULL
        , CreatedDate		DATETIME							NOT NULL
        
        , PRIMARY KEY 	PK_Browser_BrowserID(BrowserID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	CREATE TABLE FPS_DataCenter.ActionResult(
		ActionResultID			TINYINT(2)			AUTO_INCREMENT
		, ActionResultKey		VARCHAR(100)		CHARACTER SET utf8	NOT NULL
        , ActionStatus			TINYINT(1)						NOT NULL	COMMENT '0: Inactive; 1: Active; 2: Unhandled(Action has not defined in Intergrated Action List)'
        , CreatedDate			DATETIME						NOT NULL	COMMENT 'Date Only'
        
        , PRIMARY KEY 	PK_ActionResult_ActionResultID(ActionResultID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	
    CREATE TABLE FPS_DataCenter.SubscriberURL(
		SubscriberURLID			SMALLINT		AUTO_INCREMENT	NOT NULL
		, URL					VARCHAR(250)					NULL
        , SubscriberID			SMALLINT						NULL
        , CreatedDate			DATETIME						NOT NULL
        
        , PRIMARY KEY 	PK_SubscriberURL_SubscriberURLID(SubscriberURLID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	CREATE TABLE FPS_DataCenter.IPRangeLocation(
		IPRangeLocationID		INT				AUTO_INCREMENT	NOT NULL
        , IPRangeLocationCode 	VARCHAR(64)	
		, FromIP				DECIMAL(50,0)					NOT NULL
        , ToIP					DECIMAL(50,0)					NOT NULL
        , CountryCode			VARCHAR(10)						NULL
        , CountryName			VARCHAR(80)						NULL
        , Region				VARCHAR(128)					NULL
        , City					VARCHAR(50)						NULL
        , ISPName				VARCHAR(256)					NULL
        , Status				TINYINT(1)        				COMMENT '0: Inactive; 1: Active'
        , CreatedDate			DATETIME
        
        , PRIMARY KEY	PK_IPRange_IPRangeID(IPRangeLocationID)
        , INDEX			IX_IPRangeLocation_FromIP_ToIP(FromIP,ToIP)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======UserAgent============================================
	CREATE TABLE FPS_DataCenter.UserAgent(
		UserAgentID		INT				AUTO_INCREMENT	NOT NULL
		, UserAgent		TEXT							NOT NULL
		, UserAgentCode	VARCHAR(64)						NOT NULL
        , BrowserID		TINYINT(2)						NOT NULL
        , OSID			TINYINT(2)						NULL
        
        , PRIMARY KEY	PK_UserAgent_UserAgentID(UserAgentID)
        , INDEX			IX_UserAgent_UserAgentCode(UserAgentCode)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ======EvidenceGroup=============================================
	CREATE TABLE FPS_DataCenter.EvidenceGroup(
		EvidenceGroupID			TINYINT			AUTO_INCREMENT		NOT NULL
		, EvidenceGroupName		VARCHAR(50)							NOT NULL
		, EvidenceGroupDesc		VARCHAR(200)	CHARACTER SET utf8	NULL
		, OrderNo				SMALLINT							NULL
		, CreatedDate			DATETIME							NOT NULL
		, CreatedBy				INT									NOT NULL
		, IsActive				TINYINT(1)							NOT NULL
        
        , PRIMARY KEY	PK_EvidenceGroup_EvidenceGroupID(EvidenceGroupID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========EvidenceType===========================================
	CREATE TABLE FPS_DataCenter.EvidenceType(
		EvidenceTypeID		SMALLINT		AUTO_INCREMENT		NOT NULL
		, EvidenceGroupID	TINYINT								NOT NULL
		, EvidenceTypeCode	VARCHAR(10)							NOT NULL
		, EvidenceTypeName	VARCHAR(50)							NOT NULL
		, EvidenceTypeDesc	VARCHAR(200)	CHARACTER SET utf8	NULL
		, OrderNo			SMALLINT							NOT NULL
		, CreatedDate		DATETIME							NOT NULL
		, CreatedBy			INT									NOT NULL
		, IsActive			TINYINT(1)							NOT NULL
        
        , PRIMARY KEY	PK_EvidenceType_EvidenceTypeID(EvidenceTypeID)
        , UNIQUE INDEX	UIX_EvidenceType_EvidenceGroupID_EvidenceTypeCode(EvidenceGroupID, EvidenceTypeCode)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======TargetEvidence============================================
	CREATE TABLE FPS_DataCenter.TargetEvidence(
		TargetEvidenceID	BIGINT			AUTO_INCREMENT		NOT NULL
		, EvidenceTypeID	SMALLINT							NOT NULL
		, EvidenceGroupID	TINYINT								NOT NULL
		, EvidenceCode		VARCHAR(10)							NOT NULL
		, Remark			VARCHAR(500)	CHARACTER SET utf8	NULL
		, TargetID			BIGINT								NOT NULL
		, TargetType		TINYINT								NOT NULL
		, TargetLevel		TINYINT								NOT NULL
		, CentralPointID	BIGINT								NOT NULL
		, SubscriberID		INT									NOT NULL
		, CreatedDate		DATETIME							NOT NULL
		, CreatedBy			INT									NOT NULL
		, IsCreatedByMaster	TINYINT(1)							NOT NULL
		, IsActive			TINYINT(1)							NOT NULL
        
        , PRIMARY KEY	PK_TargetEvidence_TargetEvidenceID(TargetEvidenceID)
        , INDEX			IX_TargetEvidence(SubscriberID, TargetID, TargetType)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========Exceptions===========================================
	CREATE TABLE FPS_DataCenter.Exception(
		ExceptionID		INT				AUTO_INCREMENT		NOT NULL		
		, DeviceID		BIGINT								NOT NULL
		, AccountID		BIGINT								NOT NULL
		, SubscriberID	SMALLINT							NOT NULL
		, Remark		VARCHAR(200)	CHARACTER SET utf8	NULL
		, CreatedDate	DATETIME							NOT NULL
		, CreatedBy		INT									NOT NULL
		, IsActive		TINYINT(1)							NOT NULL
        
        , PRIMARY KEY	PK_Exceptions_ExceptionID(ExceptionID)
        , UNIQUE INDEX	UIX_Exceptions_AccountID_DeviceID(AccountID, DeviceID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========LogType===========================================
	CREATE TABLE FPS_DataCenter.LogType(
		LogTypeID				SMALLINT		AUTO_INCREMENT		NOT NULL
		, LogTypeName			VARCHAR(50)							NULL
		, LogTypeDescription	VARCHAR(200)	CHARACTER SET utf8	NULL
        
        , PRIMARY KEY	PK_LogType_LogTypeID(LogTypeID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========UserLog===========================================
	CREATE TABLE FPS_DataCenter.UserLog(
		LogTypeID		SMALLINT							NOT NULL
		, SPName		VARCHAR(100)						NULL
		, SubscriberID	INT									NULL
		, LogInfo		VARCHAR(500)	CHARACTER SET utf8	NULL
		, CreatedDate	DATETIME							NULL
		, CreatedBy		INT									NULL
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===================================================

CREATE TABLE FPS_DataCenter.IPTableLog(
	IPTableLogID			INT 		AUTO_INCREMENT
	, UpdatedDate			DATETIME	#DECIMAL(20,10)
	, IsNewUpdate			TINYINT(1)							COMMENT	'0: old, 1: New'
	
    , PRIMARY KEY	PK_IPTableLog_IPTableLogID(IPTableLogID)
	, INDEX IX_IPTableLog_IPType_Flag (IsNewUpdate)
);
# ===================================================


# ===================================================
