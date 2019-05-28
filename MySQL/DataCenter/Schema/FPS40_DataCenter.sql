/*
Creator: 20190521@Casey.Huynh
Task:    Create Schema FPS4.0 - Data Center
Server:  DataCenter

Reviewer: Billy
*/
USE FPS_DataCenter;

# ======Device=============================================
	CREATE TABLE Device(
		DeviceID			BIGINT 		AUTO_INCREMENT
		, DeviceCode		VARCHAR(32) NOT NULL
		, OS				VARCHAR(20)
		, Browser			VARCHAR(50)
		, UserAgent			VARCHAR(500)
		, PluginID			BIGINT
		, CreatedDate		DATETIME	NOT NULL
		, LastAccessDate	DATETIME	COMMENT 'Date Only'	NOT NULL
        
        , PRIMARY KEY	PK_Device_DeviceID(DeviceID)
        , UNIQUE INDEX	UIX_Device_DeviceCode(DeviceCode)
        , INDEX			IX_Device_LastAccessDate(LastAccessDate)
    );
    
# =======Association============================================
	CREATE TABLE Association(
		DeviceID		BIGINT		NOT NULL
		, AccountID		BIGINT		NOT NULL
		, SubscriberID	SMALLINT	NOT NULL
		, CreatedDate	DATETIME	NOT NULL
        
        , INDEX	IX_Association_SubcriberID_AccountID (SubscriberID, AccountID)
        , INDEX IX_Association_SubcriberID_DeviceID (SubscriberID, DeviceID) 
    );

# =======Account============================================
	CREATE TABLE `Account`(
		AccountID		BIGINT			AUTO_INCREMENT
		, CustID		BIGINT			
		, Username		VARCHAR(50)		CHARACTER SET utf8
		, Username2		VARCHAR(50)		CHARACTER SET utf8
		, SubscriberID	SMALLINT
		, RoleID		TINYINT
		, CurrencyID	TINYINT
		, CurrencyName	VARCHAR(50)		CHARACTER SET utf8
		, IsDeposit		TINYINT(1)				
		, CreatedDate	DATETIME		NOT NULL
        
        , PRIMARY KEY	PK_Account_AccountID (AccountID)        
        , INDEX			IX_Account_CustID (CustID)
        , INDEX			IX_Account_Username(Username)
        , INDEX			IX_Account_Username2(Username2)
    );

# =======Transactions============================================
	CREATE TABLE `Transaction`(
		TransID				BIGINT			AUTO_INCREMENT
		, DeviceID			BIGINT			NOT NULL
		, LoginName			VARCHAR(50)		CHARACTER SET utf8	NOT NULL	
		, AccountID			BIGINT			NOT NULL
		, SubscriberID		SMALLINT		
		, TransDate			DATETIME		NOT	NULL
		, CreatedDate		DATETIME		COMMENT 'Date Only'	NOT	NULL
		, IPAddressID		BIGINT
		, OSID				TINYINT
		, BrowserID			TINYINT
		, PluginID			BIGINT
		, DeviceStatus		TINYINT			COMMENT 'new, old, retrieve'	NOT	NULL
		, Flagged			TINYINT			COMMENT 'captcha & browserless'
		, SubURLID			SMALLINT
		, ActionResultID	TINYINT
		, UserAgentID		INT
        
        , PRIMARY KEY	PK_Transaction_TransID (TransID)        
        , INDEX			IX_Transaction_DeviceID (DeviceID)
        , INDEX			IX_Transaction_SubscriberIDAccountID (SubscriberID,AccountID)
        , INDEX			IX_Transaction_CreatedDate (CreatedDate)
	);

# ===========================================================================
	CREATE TABLE OS(
		OSID			TINYINT			AUTO_INCREMENT
		, OS_Name		VARCHAR(20)
        , CreatedDate	DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_OS_ISID (OSID)
    );


# ===========================================================================
	CREATE TABLE Browser(
		BrowserID			TINYINT			AUTO_INCREMENT
		, BrowserName		VARCHAR(50)	
        , CreatedDate		DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_Browser_BrowserID (BrowserID)
    );

# ===========================================================================
	CREATE TABLE ActionResult(
		ActionResultID			TINYINT			AUTO_INCREMENT
		, ActionResultName		VARCHAR(100)
        , CreatedDate			DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_ActionResult_ActionResultID (ActionResultID)
    );

# ===========================================================================
	CREATE TABLE SubcriberURL(
		SubcriberURLID			SMALLINT		AUTO_INCREMENT
		, URL					VARCHAR(250)
        , SubcriberID			SMALLINT
        , CreatedDate			DATETIME		NOT NULL
        
        , PRIMARY KEY 	PK_SubcriberURL_SubcriberURLID (SubcriberURLID)
    );

# ===========================================================================
	CREATE TABLE LocationIPRange(
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
	CREATE TABLE UserAgent(
		UserAgentID		INT				AUTO_INCREMENT
		, UserAgent		VARCHAR(500)	NOT NULL
		, UserAgentCode	VARCHAR(32)		NOT NULL
        
        , PRIMARY KEY	PK_UserAgent_UserAgentID (UserAgentID)
        , INDEX			IX_UserAgent_UserAgentCode (UserAgentCode)
    );

# ======EvidenceGroup=============================================
	CREATE TABLE EvidenceGroup(
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
	CREATE TABLE EvidenceType(
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
	CREATE TABLE TargetEvidence(
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
	CREATE TABLE Exception(
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
	CREATE TABLE LogType(
		LogTypeID				SMALLINT		AUTO_INCREMENT
		, LogTypeName			VARCHAR(50)
		, LogTypeDescription	VARCHAR(200)	CHARACTER SET utf8
        
        , PRIMARY KEY	PK_LogType_LogTypeID(LogTypeID)
    );

# ========UserLog===========================================
	CREATE TABLE UserLog(
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
