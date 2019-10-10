/*
Creator: 20190521@Casey.Huynh
Task:    Create Schema FPS4.0 - Data Center
Server:  
DBName:	FPS_DataCenter

Reviewer: 
*/

CREATE DATABASE IF NOT EXISTS FPS_DataCenter;
CREATE TABLE FPS_DataCenter.Device(		
        ID					BIGINT			AUTO_INCREMENT
        , DeviceID				BIGINT 			NOT NULL
		, FirstDeviceCode		VARCHAR(32)		NULL
        , UserAgentID			BIGINT			NULL
        , FirstStagingTransID	BIGINT			NULL
        , CreatedDate			DATETIME		NULL
        , DeviceStatus			TINYINT			NULL
        , InsertTime			TIMESTAMP(4)	NULL
        
        , PRIMARY KEY	PK_Device_DeviceID(DeviceID)
        , INDEX			IX_Device_CreatedDate(CreatedDate)
        , UNIQUE KEY	UK_Device_ID(ID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ======Device=============================================
	CREATE TABLE FPS_DataCenter.DeviceCode(
		ID					BIGINT			AUTO_INCREMENT
		, DeviceCodeID			BIGINT			NOT NULL
		, DeviceCode			VARCHAR(32) 	NOT NULL
        , DeviceID				BIGINT			NULL
        , CreatedDate			DATETIME		NULL
        , FirstDeviceCode		VARCHAR(32)		NULL				COMMENT 'DeviceCode Of Device. Defferent with DeviceCode Field'
        , LastStatus			TINYINT			NULL
		, FirstStagingTransID	BIGINT			NULL
        , FirstStatus			TINYINT			NULL
        , InsertTime			TIMESTAMP(4)	NULL
        
        , PRIMARY KEY	PK_DeviceCode_DeviceCode(DeviceCodeID)
        , INDEX			IX_DeviceCode_CreatedDate(CreatedDate)
        , INDEX			IX_DeviceCode_DeviceID(DeviceID)
        , UNIQUE KEY	UK_DeviceCode_ID(ID)
        
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
     
# ======DeviceDetail=============================================
	CREATE TABLE FPS_DataCenter.DeviceFingerprint(
		ID						BIGINT			AUTO_INCREMENT
		, FingerprintID			BIGINT 			UNSIGNED NOT NULL
        , FingerprintCode		VARCHAR(620)	NOT NULL
		, FingerprintMoreInfo	TEXT			NULL
        , UserAgentID			BIGINT			NULL
		, PluginID				BIGINT			NULL
        , DeviceID				BIGINT			NULL
        , CreatedDate			DATETIME		NULL
        , InsertTime			TIMESTAMP(4)	NULL
        
        , PRIMARY KEY	PK_Fingerprint_FingerprintID(FingerprintID)
		, UNIQUE KEY	UK_DeviceFingerprint_ID(ID)
        , INDEX			IX_Fingerprint_FingerprintCode(DeviceID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
    
# =======Association============================================
	CREATE TABLE FPS_DataCenter.Association(
		ID					BIGINT		AUTO_INCREMENT					
		, AssociationID		BIGINT 		NOT NULL
		, DeviceID			BIGINT		NOT NULL
		, AccountID			BIGINT		NOT NULL
		, SubscriberID		INT			NOT NULL
		, CreatedDate		DATETIME	NOT NULL
		, SyncGraphDB		TINYINT		NOT NULL	COMMENT '0: NOT SENT TO GraphDB, 1: SENT'
        , InsertTime		TIMESTAMP(4)	NULL
        
        , PRIMARY KEY	PK_Association_AssociationID(AssociationID)
        , UNIQUE KEY	UK_Association_ID(ID)
        , INDEX	IX_Association_SubscriberID_AccountID_DeviceID(SubscriberID, AccountID, DeviceID)
        , INDEX IX_Association_SyncGraphDB(SyncGraphDB)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======Account============================================
	CREATE TABLE FPS_DataCenter.`Account`(
		AccountID			BIGINT		UNSIGNED	AUTO_INCREMENT	NOT NULL
        , FirstLoginName	VARCHAR(50)							NOT NULL
        , SubscriberID		INT									NOT NULL
        , IsDeposit			TINYINT								NULL
        , CustID			BIGINT								NULL
		, Username			VARCHAR(50)							NULL
		, Username2			VARCHAR(50)							NULL
		, RoleID			TINYINT								NULL
		, CurrencyID		SMALLINT							NULL
		, CurrencyName		VARCHAR(50)							NULL				
		, CreatedDate		DATETIME							NULL
        , LastArchivedDate	DATETIME							NULL
        , FirstLoginNameID	BIGINT								NULL			
        , UserNameID		BIGINT								NULL
        , UserName2ID		BIGINT								NULL
        , InsertTime		TIMESTAMP(4)						NULL
        
        , PRIMARY KEY	PK_Account_AccountID(AccountID)        
        , INDEX			IX_Account_CustID(CustID)
        , INDEX			IX_Account_SubscriberID_Username(SubscriberID, Username)
        , INDEX			IX_Account_SubscriberID_Username2(SubscriberID, Username2)
        , INDEX			IX_Account_SubscriberID_FirstLoginNameID_UserNameID_Username2ID(SubscriberID, FirstLoginNameID, UserNameID, UserName2ID)
        , UNIQUE KEY	UK_Account_FirstLoginNameID_UserNameID_Username2ID(FirstLoginNameID, UserNameID, UserName2ID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======Transactions============================================
	CREATE TABLE FPS_DataCenter.`Transaction`(
		ID					BIGINT								AUTO_INCREMENT
		, StagingTransID		BIGINT	UNSIGNED					NOT NULL
		, LoginName			VARCHAR(50)							NOT NULL
        , TransDate			TIMESTAMP(4)						NOT	NULL
        , CreatedDate		DATETIME							NULL		COMMENT 'Date Only'	NOT	NULL        
        , SubscriberID		INT									NULL
        , SubURLID			VARCHAR(32)							NULL
        , AccountID			BIGINT								NULL        
        , DeviceCode		VARCHAR(32)							NULL
		, DeviceCodeID		BIGINT								NULL
        , DeviceID			BIGINT			UNSIGNED			NULL		COMMENT 'Current Device Status'
        , FirstDeviceCode	VARCHAR(32)							NULL
        , DeviceStatus		TINYINT								NULL
        , FingerprintCodeID	BIGINT			UNSIGNED			NULL
        , UserAgentID		BIGINT								NULL
        , IP				VARCHAR(50)							NULL
        , ActionResultID 	BIGINT								NULL
		, Flagged			SMALLINT							NULL		COMMENT 'captcha & browserless'		
        , PluginID					BIGINT 						NULL
		, LoginNameWithPrefixID BIGINT							NULL
        , TransStatus		INT									NULL
        , InsertTime		TIMESTAMP(4)						NULL
        
        , PRIMARY KEY	PK_Transaction_StagingTransID(StagingTransID)
        , UNIQUE KEY	IX_Transaction_ID(ID)
        , INDEX			IX_Transaction_DeviceID(DeviceCode)
        , INDEX			IX_Transaction_SubscriberIDAccountID(SubscriberID,AccountID)
        , INDEX			IX_Transaction_CreatedDate(CreatedDate)        
	 ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	CREATE TABLE FPS_DataCenter.OS(
		OSID			SMALLINT		AUTO_INCREMENT	NOT NULL
		, OSName		VARCHAR(100)					NOT NULL
        , CreatedDate	DATETIME						NOT NULL
        
        , PRIMARY KEY 	PK_OS_ISID(OSID)
        , UNIQUE KEY	UK_OSName(OSName)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
# ===========================================================================
	CREATE TABLE FPS_DataCenter.Browser(
		BrowserID			SMALLINT		AUTO_INCREMENT	NOT NULL
		, BrowserName		VARCHAR(100)					NOT NULL
        , CreatedDate		DATETIME						NOT NULL
        
        , PRIMARY KEY 	PK_Browser_BrowserID(BrowserID)
        , UNIQUE KEY	UK_BrowserName(BrowserName)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	CREATE TABLE FPS_DataCenter.ActionResult(
		ActionResultID			BIGINT		
		, ActionResultKey		VARCHAR(200)	NOT NULL
        , ActionStatus			TINYINT			NOT NULL	COMMENT '0: Inactive; 1: Active; -1: Unhandled(Action has not defined in Intergrated Action List)'
        , CreatedDate			DATETIME		NOT NULL	COMMENT 'Date Only'
        
        , PRIMARY KEY 	PK_ActionResult_ActionResultID(ActionResultID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===========================================================================
	
    CREATE TABLE FPS_DataCenter.SubscriberURL(
		SubscriberURLID			BIGINT							NOT NULL
		, URL					VARCHAR(250)					NULL
        , SubscriberID			INT								NULL
        , CreatedDate			DATETIME						NULL
        
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
        , City					VARCHAR(100)					NULL
        , ISPName				VARCHAR(256)					NULL
        , Status				TINYINT        					NULL COMMENT '0: Inactive; 1: Active'
        , CreatedDate			DATETIME
        
        , PRIMARY KEY	PK_IPRangeLocation_IPRangeLocationID(IPRangeLocationID)
        , UNIQUE KEY	UK_IPRangeLocation_FromIP_ToIP(FromIP,ToIP)
        , INDEX 		IX_IPRangeLocation_IPRangeLocationCode(IPRangeLocationCode)
        
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;
     
     	CREATE TABLE FPS_DataCenter.IPRangeLocation_Initial(
		IPRangeLocationID		INT				AUTO_INCREMENT	NOT NULL
        , IPRangeLocationCode 	VARCHAR(64)	
		, FromIP				DECIMAL(50,0)					NOT NULL
        , ToIP					DECIMAL(50,0)					NOT NULL
        , CountryCode			VARCHAR(10)						NULL
        , CountryName			VARCHAR(80)						NULL
        , Region				VARCHAR(128)					NULL
        , City					VARCHAR(100)					NULL
        , ISPName				VARCHAR(256)					NULL
        , Status				TINYINT        					NULL COMMENT '0: Inactive; 1: Active'
        , CreatedDate			DATETIME
        
        , PRIMARY KEY	PK_IPRangeLocationInit_IPRangeLocationID(IPRangeLocationID)
        , INDEX			IX_IPRangeLocationInit_FromIP_ToIP(FromIP,ToIP)
        , INDEX 		IX_IPRangeLocationInit_IPRangeLocationCode(IPRangeLocationCode)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


# =======UserAgent============================================
	CREATE TABLE FPS_DataCenter.UserAgent(
		UserAgentID		BIGINT							NOT NULL
		, UserAgent		TEXT							NOT NULL	
        , BrowserID		SMALLINT						NULL
        , OSID			SMALLINT						NULL
        , OS			VARCHAR(100)					NULL
        , Browser		VARCHAR(100)					NULL
        , CreatedDate	DATETIME						NULL
        
        , UNIQUE KEY	UK_UserAgent_UserAgentID(UserAgentID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ======EvidenceGroup=============================================
	CREATE TABLE FPS_DataCenter.EvidenceGroup(
		EvidenceGroupID			TINYINT			AUTO_INCREMENT		NOT NULL
		, EvidenceGroupName		VARCHAR(50)							NOT NULL
		, EvidenceGroupDesc		VARCHAR(200)	CHARACTER SET UTF8MB4	NULL
		, OrderNo				SMALLINT							NULL
		, CreatedDate			DATETIME							NOT NULL
		, CreatedBy				INT									NOT NULL
		, IsActive				TINYINT						NOT NULL
        
        , PRIMARY KEY	PK_EvidenceGroup_EvidenceGroupID(EvidenceGroupID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========EvidenceType===========================================
	CREATE TABLE FPS_DataCenter.EvidenceType(
		EvidenceTypeID		SMALLINT		AUTO_INCREMENT		NOT NULL
		, EvidenceGroupID	TINYINT								NOT NULL
		, EvidenceTypeCode	VARCHAR(10)							NOT NULL
		, EvidenceTypeName	VARCHAR(50)							NOT NULL
		, EvidenceTypeDesc	VARCHAR(200)	CHARACTER SET UTF8MB4	NULL
		, OrderNo			SMALLINT							NOT NULL
		, CreatedDate		DATETIME							NOT NULL
		, CreatedBy			INT									NOT NULL
		, IsActive			TINYINT						NOT NULL
        
        , PRIMARY KEY	PK_EvidenceType_EvidenceTypeID(EvidenceTypeID)
        , UNIQUE INDEX	UIX_EvidenceType_EvidenceGroupID_EvidenceTypeCode(EvidenceGroupID, EvidenceTypeCode)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# =======TargetEvidence============================================
	CREATE TABLE FPS_DataCenter.TargetEvidence(
		TargetEvidenceID	BIGINT			AUTO_INCREMENT		NOT NULL
		, EvidenceTypeID	SMALLINT							NOT NULL
		, EvidenceGroupID	TINYINT								NOT NULL
		, EvidenceCode		VARCHAR(10)							NOT NULL
		, Remark			VARCHAR(500)	CHARACTER SET UTF8MB4	NULL
		, TargetID			BIGINT								NOT NULL
		, TargetType		TINYINT								NOT NULL
		, TargetLevel		TINYINT								NOT NULL
		, CentralPointID	BIGINT								NOT NULL
		, CentralPointType  INT									NOT NULL
		, SubscriberID		INT									NOT NULL
		, CreatedDate		DATETIME							NOT NULL
		, CreatedBy			INT									NOT NULL
		, IsCreatedByMaster	TINYINT						NOT NULL
		, IsActive			TINYINT						NOT NULL
        
        , PRIMARY KEY	PK_TargetEvidence_TargetEvidenceID(TargetEvidenceID)
        , INDEX			IX_TargetEvidence(SubscriberID, TargetID, TargetType)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========Exceptions===========================================
	CREATE TABLE FPS_DataCenter.Exception(
		ExceptionID		INT				AUTO_INCREMENT		NOT NULL		
		, FromAccountID	BIGINT								NOT NULL
		, ToAccountID	BIGINT								NOT NULL
		, SubscriberID	INT									NOT NULL
		, Remark		VARCHAR(200)	CHARACTER SET UTF8MB4	NULL
		, CreatedDate	DATETIME							NOT NULL
		, CreatedBy		INT									NOT NULL
		, IsActive		TINYINT						NOT NULL
        
        , PRIMARY KEY	PK_Exceptions_ExceptionID(ExceptionID)
        , UNIQUE INDEX	UIX_Exceptions_FromAccountID_ToAccountID(FromAccountID,ToAccountID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========LogType===========================================
	CREATE TABLE FPS_DataCenter.LogType(
		LogTypeID				SMALLINT		AUTO_INCREMENT		NOT NULL
		, LogTypeName			VARCHAR(50)							NULL
		, LogTypeDescription	VARCHAR(200)	CHARACTER SET UTF8MB4	NULL
        
        , PRIMARY KEY	PK_LogType_LogTypeID(LogTypeID)
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ========UserLog===========================================
	CREATE TABLE FPS_DataCenter.UserLog(
		LogTypeID		SMALLINT								NOT NULL
		, SPName		VARCHAR(100)							NULL
		, SubscriberID	INT										NULL
		, LogInfo		VARCHAR(500)	CHARACTER SET UTF8MB4	NULL
		, CreatedDate	DATETIME								NULL
		, CreatedBy		INT										NULL
     ) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

# ===================================================

CREATE TABLE FPS_DataCenter.IPTableLog(
	IPTableLogID			INT 		AUTO_INCREMENT
	, UpdatedDate			DATETIME	#DECIMAL(20,10)
	, IsNewUpdate			TINYINT						COMMENT	'0: old, 1: New'
	
    , PRIMARY KEY	PK_IPTableLog_IPTableLogID(IPTableLogID)
	, INDEX IX_IPTableLog_IPType_Flag (IsNewUpdate)
);

# ===================================================
CREATE TABLE zzTracePerformance (
	ID			BIGINT			AUTO_INCREMENT
    , ExecKey		BIGINT			NOT NULL
    , StepID		INT				NOT NULL
    , SPName		VARCHAR(200)	NOT NULL    
    , Notes			VARCHAR(200)	NULL
    , StartTime		TIMESTAMP(4)	NULL
    , EndTime		TIMESTAMP(4)	NULL
    , TotalRecord	INT				NULL
    , FromID		BIGINT			NULL
    , ToID			BIGINT			NULL
    , Duration		BIGINT			NULL
    
	, PRIMARY KEY PK_zzTracePerformance_ID(ID)
	, INDEX IX_zzTracePerformance_ExecKey_StepID(ExecKey,StepID)
) ENGINE=InnoDB ;