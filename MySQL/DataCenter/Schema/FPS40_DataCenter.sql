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
		, LastAccessDate	DATETIME	NOT NULL	#Date Only
        
        , PRIMARY KEY PK_Device_DeviceID(DeviceID)
        , UNIQUE INDEX UIX_Device_DeviceCode(DeviceCode)
        , INDEX	IX_Device_LastAccessDate(LastAccessDate)
    );
    
# =======Association============================================
	CREATE TABLE Association(
		DeviceID		BIGINT		NOT NULL
		, AccountID		BIGINT		NOT NULL
		, SubscriberID	SMALLINT	NOT NULL
		, CreatedDate	DATETIME	NOT NULL
        
        , INDEX IX_Association_SubcriberID_AccountID (SubscriberID, AccountID)
        , INDEX IX_Association_SubcriberID_DeviceID (SubscriberID, DeviceID) 
    );

# =======Account============================================
	CREATE TABLE `Account`(
		AccountID		BIGINT			AUTO_INCREMENT
		, CustID		BIGINT			
		, Username		NVARCHAR(50)
		, Username2		NVARCHAR(50)
		, SubscriberID	SMALLINT
		, RoleID		TINYINT
		, CurrencyID	TINYINT
		, CurrencyName	NVARCHAR(50)
		, IsDeposit		BIT				
		, CreatedDate	DATETIME		NOT NULL
        
        , PRIMARY KEY PK_Account_AccountID (AccountID)
        , INDEX	ID_Account_SubscriberID_Username_Username2(SubscriberID, Username, Username2)
        , INDEX	ID_Account_CustID (CustID)
    );

# =======Transactions============================================
	CREATE TABLE `Transaction`(
		TransID				BIGINT			AUTO_INCREMENT
		, DeviceID			BIGINT			NOT NULL
		, LoginName			NVARCHAR(50)	NOT NULL
		, AccountID			BIGINT			NOT NULL
		, SubscriberID		SMALLINT		
		, SubscriberName	VARCHAR(30)		NOT	NULL
		, TransDate			DATETIME		NOT	NULL
		, CreatedDate		DATETIME		NOT	NULL		#(date only)
		, IP				VARCHAR(20)
		, Country			VARCHAR(50)
		, CountryCode		VARCHAR(5)
		, Region			VARCHAR(50)
		, City				VARCHAR(50)
		, ISP				NVARCHAR(150)
		, OS				VARCHAR(20)
		, Browser			VARCHAR(20)
		, PluginID			BIGINT
		, DeviceStatus		TINYINT			NOT	NULL		#(new, old, retrieve)
		, Flagged			TINYINT							#(captcha & browserless)
		, URL				VARCHAR(150)
		, ActionResult		VARCHAR(20)
		, UserAgentID		INT
        
        , PRIMARY KEY PK_Transaction_TransID (TransID)
        , INDEX IX_Transaction_SubscriberID_AccountID (SubscriberID, AccountID)
        , INDEX IX_Transaction_DeviceID (DeviceID)
        , INDEX IX_Transaction_CreatedDate (CreatedDate)
	);

# =======UserAgent============================================
	CREATE TABLE UserAgent(
		UserAgentID		INT				AUTO_INCREMENT
		, UserAgent		VARCHAR(500)	NOT NULL
		, UserAgentCode	VARCHAR(32)		NOT NULL
        
        , PRIMARY KEY PK_UserAgent_UserAgentID (UserAgentID)
        , INDEX IX_UserAgent_UserAgentCode (UserAgentCode)
    );

# ======EvidenceGroup=============================================
	CREATE TABLE EvidenceGroup(
		EvidenceGroupID			TINYINT			AUTO_INCREMENT
		, EvidenceGroupName		VARCHAR(50)		NOT NULL
		, EvidenceGroupDesc		NVARCHAR(200)
		, OrderNo				SMALLINT
		, CreatedDate			DATETIME		NOT NULL
		, CreatedBy				INT				NOT NULL
		, IsActive				BIT				NOT NULL
        
        , PRIMARY KEY PK_EvidenceGroup_EvidenceGroupID (EvidenceGroupID)
    );

# ========EvidenceType===========================================
	CREATE TABLE EvidenceType(
		EvidenceTypeID		SMALLINT		AUTO_INCREMENT
		, EvidenceGroupID	TINYINT			NOT NULL
		, EvidenceTypeCode	VARCHAR(10)		NOT NULL
		, EvidenceTypeName	VARCHAR(50)		NOT NULL
		, EvidenceTypeDesc	NVARCHAR(200)	
		, OrderNo			SMALLINT
		, CreatedDate		DATETIME		NOT NULL
		, CreatedBy			INT				NOT NULL
		, IsActive			BIT				NOT NULL
        
        , PRIMARY KEY PK_EvidenceType_EvidenceTypeID (EvidenceTypeID)
        , UNIQUE INDEX UIX_EvidenceType_EvidenceGroupID_EvidenceTypeCode (EvidenceGroupID, EvidenceTypeCode)
    );

# =======TargetEvidence============================================
	CREATE TABLE TargetEvidence(
		TargetEvidenceID	BIGINT			AUTO_INCREMENT
		, EvidenceTypeID	SMALLINT		NOT NULL
		, EvidenceGroupID	TINYINT			NOT NULL
		, EvidenceCode		VARCHAR(10)		NOT NULL
		, Remark			NVARCHAR(500)
		, TargetID			BIGINT			NOT NULL
		, TargetType		TINYINT			NOT NULL
		, TargetLevel		TINYINT			NOT NULL
		, CentralPointID	BIGINT			NOT NULL
		, SubscriberID		INT				NOT NULL
		, CreatedDate		DATETIME		NOT NULL
		, CreatedBy			INT				NOT NULL
		, IsCreatedByMaster	BIT				NOT NULL
		, IsActive			BIT				NOT NULL
        
        , PRIMARY KEY PK_TargetEvidence_TargetEvidenceID (TargetEvidenceID)
        , INDEX	IX_TargetEvidence(SubscriberID, TargetID, TargetType)
    );

# ========Exceptions===========================================
	CREATE TABLE Exception(
		ExceptionID		INT				AUTO_INCREMENT
		, DeviceID		BIGINT			NOT NULL
		, AccountID	BIGINT			NOT NULL
		, SubscriberID	SMALLINT		NOT NULL
		, Remark		NVARCHAR(200)
		, CreatedDate	DATETIME		NOT NULL
		, CreatedBy		INT				NOT NULL
		, IsActive		BIT				NOT NULL
        
        , PRIMARY KEY PK_Exceptions_ExceptionID(ExceptionID)
        , UNIQUE INDEX	UIX_Exceptions_AccountID_DeviceID(AccountID, DeviceID)
    );

# ========LogType===========================================
	CREATE TABLE LogType(
		LogTypeID				SMALLINT		AUTO_INCREMENT
		, LogTypeName			VARCHAR(50)
		, LogTypeDescription	NVARCHAR(200)
        
        , PRIMARY KEY PK_LogType_LogTypeID(LogTypeID)
    );

# ========UserLog===========================================
	CREATE TABLE UserLog(
		LogTypeID		SMALLINT
		, SPName		VARCHAR(100)
		, SubscriberID	INT
		, LogInfo		NVARCHAR(500)
		, CreatedDate	DATETIME
		, CreatedBy		INT
    );

# ===================================================


# ===================================================


# ===================================================
