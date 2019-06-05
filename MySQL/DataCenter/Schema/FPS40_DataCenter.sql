/*
Creator: 20190521@Casey.Huynh
Task:    Create Schema FPS4.0 - Data Center
Server:  DataCenter

Reviewer: Billy
*/

CREATE DATABASE IF NOT EXISTS FPS_DataCenter;

# ======Device=============================================
	CREATE TABLE FPS_DataCenter.Device(
		DeviceID			BIGINT 		AUTO_INCREMENT
		, DeviceCode		VARCHAR(32) NOT NULL
		, UserAgentID		INT
		, PluginID			BIGINT
		, CreatedDate		DATETIME	NOT NULL
		, LastAccessDate	DATETIME									COMMENT 'Date Only'	NOT NULL
        
        , PRIMARY KEY	PK_Device_DeviceID(DeviceID)
        , UNIQUE INDEX	UIX_Device_DeviceCode(DeviceCode)
        , INDEX			IX_Device_LastAccessDate(LastAccessDate)
    );
    
# =======Association============================================
	CREATE TABLE FPS_DataCenter.Association(
		DeviceID		BIGINT		NOT NULL
		, AccountID		BIGINT		NOT NULL
		, SubscriberID	SMALLINT	NOT NULL
		, CreatedDate	DATETIME	NOT NULL
        
        , INDEX	IX_Association_SubscriberID_AccountID (SubscriberID, AccountID)
        , INDEX IX_Association_SubscriberID_DeviceID (SubscriberID, DeviceID) 
    );

# =======Account============================================
	CREATE TABLE FPS_DataCenter.`Account`(
		AccountID			BIGINT			AUTO_INCREMENT
        , SubscriberID		SMALLINT		NOT NULL
        , IsDeposit			TINYINT(1)
        , FirstLoginName	VARCHAR(50)		CHARACTER SET utf8	NOT NULL
		, CustID			BIGINT			
		, Username			VARCHAR(50)		CHARACTER SET utf8
		, Username2			VARCHAR(50)		CHARACTER SET utf8		
		, RoleID			TINYINT
		, CurrencyID		TINYINT
		, CurrencyName		VARCHAR(50)		CHARACTER SET utf8						
		, CreatedDate		DATETIME		NOT NULL      
        
        , PRIMARY KEY	PK_Account_AccountID (AccountID)        
        , INDEX			IX_Account_CustID (CustID)
        , INDEX			IX_Account_Username(SubscriberID, Username)
        , INDEX			IX_Account_Username2(SubscriberID, Username2)
    );

# =======Transactions============================================
	CREATE TABLE FPS_DataCenter.`Transaction`(
		TransID				BIGINT			AUTO_INCREMENT
		, DeviceID			BIGINT			NOT NULL
		, LoginName			VARCHAR(50)		CHARACTER SET utf8	NOT NULL	
		, AccountID			BIGINT			NOT NULL
		, SubscriberID		SMALLINT		
		, TransDate			DATETIME		NOT	NULL
		, CreatedDate		DATETIME								COMMENT 'Date Only'	NOT	NULL
		, IPAddressID		BIGINT
		, PluginID			BIGINT
		, DeviceStatus		TINYINT									COMMENT 'new, old, retrieve'	NOT	NULL
		, Flagged			TINYINT									COMMENT 'captcha & browserless'
		, SubURLID			SMALLINT
		, ActionResultID	TINYINT
		, UserAgentID		INT
        , StagingTransID	BIGINT
        
        , PRIMARY KEY	PK_Transaction_TransID (TransID)        
        , INDEX			IX_Transaction_DeviceID (DeviceID)
        , INDEX			IX_Transaction_SubscriberIDAccountID (SubscriberID,AccountID)
        , INDEX			IX_Transaction_CreatedDate (CreatedDate)
	);

# ===========================================================================
	CREATE TABLE FPS_DataCenter.OS(
		OSID			TINYINT			AUTO_INCREMENT
		, OSName		VARCHAR(20)
        , CreatedDate	DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_OS_ISID (OSID)
    );


# ===========================================================================
	CREATE TABLE FPS_DataCenter.Browser(
		BrowserID			TINYINT			AUTO_INCREMENT
		, BrowserName		VARCHAR(50)	
        , CreatedDate		DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_Browser_BrowserID (BrowserID)
    );

# ===========================================================================
	CREATE TABLE FPS_DataCenter.ActionResult(
		ActionResultID			TINYINT			AUTO_INCREMENT
		, ActionResultName		VARCHAR(100)
        , Status				TINYINT(1)						COMMENT '0: Inactive; 1: Active; 2: Unhandled(Action has not defined in Intergrated Action List)'
        , CreatedDate			DATETIME		NOT NULL		COMMENT 'Date Only'
        
        , PRIMARY KEY 	PK_ActionResult_ActionResultID (ActionResultID)
    );

# ===========================================================================
	
    CREATE TABLE FPS_DataCenter.SubscriberURL(
		SubscriberURLID			SMALLINT		AUTO_INCREMENT
		, URL					VARCHAR(250)
        , SubscriberID			SMALLINT
        , CreatedDate			DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_SubscriberURL_SubscriberURLID (SubscriberURLID)
    );

# ===========================================================================
	CREATE TABLE FPS_DataCenter.LocationIPRange(
		FromIP			BIGINT
        , ToIP			BIGINT
        , CountryCode	BIGINT
        , CountryName	VARCHAR(64)
        , Region		VARCHAR(128)
        , City			VARCHAR(50)
        , ISPName		VARCHAR(256)
        
        , PRIMARY KEY	PK_LocationIPRange_IPRange (FromIP,ToIP)
    );

# =======UserAgent============================================
	CREATE TABLE FPS_DataCenter.UserAgent(
		UserAgentID		INT				AUTO_INCREMENT
		, UserAgent		VARCHAR(500)	NOT NULL
		, UserAgentCode	VARCHAR(32)		NOT NULL
        , BrowserID		TINYINT(1)		NOT NULL
        , OSID			TINYINT(1)
        
        , PRIMARY KEY	PK_UserAgent_UserAgentID (UserAgentID)
        , INDEX			IX_UserAgent_UserAgentCode (UserAgentCode)
    );

# ======EvidenceGroup=============================================
	CREATE TABLE FPS_DataCenter.EvidenceGroup(
		EvidenceGroupID			TINYINT			AUTO_INCREMENT
		, EvidenceGroupName		VARCHAR(50)		NOT NULL
		, EvidenceGroupDesc		VARCHAR(200)	CHARACTER SET utf8
		, OrderNo				SMALLINT
		, CreatedDate			DATETIME		NOT NULL
		, CreatedBy				INT				NOT NULL
		, IsActive				TINYINT(1)				NOT NULL
        
        , PRIMARY KEY	PK_EvidenceGroup_EvidenceGroupID (EvidenceGroupID)
    );

# ========EvidenceType===========================================
	CREATE TABLE FPS_DataCenter.EvidenceType(
		EvidenceTypeID		SMALLINT		AUTO_INCREMENT
		, EvidenceGroupID	TINYINT			NOT NULL
		, EvidenceTypeCode	VARCHAR(10)		NOT NULL
		, EvidenceTypeName	VARCHAR(50)		NOT NULL
		, EvidenceTypeDesc	VARCHAR(200)	CHARACTER SET utf8
		, OrderNo			SMALLINT
		, CreatedDate		DATETIME		NOT NULL
		, CreatedBy			INT				NOT NULL
		, IsActive			TINYINT(1)		NOT NULL
        
        , PRIMARY KEY	PK_EvidenceType_EvidenceTypeID (EvidenceTypeID)
        , UNIQUE INDEX	UIX_EvidenceType_EvidenceGroupID_EvidenceTypeCode (EvidenceGroupID, EvidenceTypeCode)
    );

# =======TargetEvidence============================================
	CREATE TABLE FPS_DataCenter.TargetEvidence(
		TargetEvidenceID	BIGINT			AUTO_INCREMENT
		, EvidenceTypeID	SMALLINT		NOT NULL
		, EvidenceGroupID	TINYINT			NOT NULL
		, EvidenceCode		VARCHAR(10)		NOT NULL
		, Remark			VARCHAR(500)	CHARACTER SET utf8
		, TargetID			BIGINT			NOT NULL
		, TargetType		TINYINT			NOT NULL
		, TargetLevel		TINYINT			NOT NULL
		, CentralPointID	BIGINT			NOT NULL
		, SubscriberID		INT				NOT NULL
		, CreatedDate		DATETIME		NOT NULL
		, CreatedBy			INT				NOT NULL
		, IsCreatedByMaster	TINYINT(1)		NOT NULL
		, IsActive			TINYINT(1)		NOT NULL
        
        , PRIMARY KEY	PK_TargetEvidence_TargetEvidenceID (TargetEvidenceID)
        , INDEX			IX_TargetEvidence(SubscriberID, TargetID, TargetType)
    );

# ========Exceptions===========================================
	CREATE TABLE FPS_DataCenter.Exception(
		ExceptionID		INT				AUTO_INCREMENT
		, DeviceID		BIGINT			NOT NULL
		, AccountID		BIGINT			NOT NULL
		, SubscriberID	SMALLINT		NOT NULL
		, Remark		VARCHAR(200)	CHARACTER SET utf8
		, CreatedDate	DATETIME		NOT NULL
		, CreatedBy		INT				NOT NULL
		, IsActive		TINYINT(1)		NOT NULL
        
        , PRIMARY KEY	PK_Exceptions_ExceptionID(ExceptionID)
        , UNIQUE INDEX	UIX_Exceptions_AccountID_DeviceID(AccountID, DeviceID)
    );

# ========LogType===========================================
	CREATE TABLE FPS_DataCenter.LogType(
		LogTypeID				SMALLINT		AUTO_INCREMENT
		, LogTypeName			VARCHAR(50)
		, LogTypeDescription	VARCHAR(200)	CHARACTER SET utf8
        
        , PRIMARY KEY	PK_LogType_LogTypeID(LogTypeID)
    );

# ========UserLog===========================================
	CREATE TABLE FPS_DataCenter.UserLog(
		LogTypeID		SMALLINT
		, SPName		VARCHAR(100)
		, SubscriberID	INT
		, LogInfo		VARCHAR(500)	CHARACTER SET utf8
		, CreatedDate	DATETIME
		, CreatedBy		INT
    );

# ===================================================


# ===================================================


# ===================================================
