/*
	Created: 20190610@Casey.Huynh
	Task : Process data from raw to data center
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DROP PROCEDURE IF EXISTS FPS_DataCenter.DC_DataCenter_ProcessTransaction;

DELIMITER $$
USE FPS_DataCenter$$

CREATE PROCEDURE FPS_DataCenter.DC_DataCenter_ProcessTransaction(IN ip_TransXml LONGTEXT, OUT op_ErrorCode TINYINT(1), OUT op_ErrorMessage VARCHAR(500))

BEGIN
	DECLARE RowIndex 		INT UNSIGNED DEFAULT 0;
	DECLARE RowCount 		INT UNSIGNED;
	DECLARE XpathRow 		VARCHAR(50);
    
    #=========================================================================================
    DROP TABLE IF EXISTS Temp_Transaction;
	
	CREATE TEMPORARY TABLE Temp_Transaction
    ( 
		StagingTransID			BIGINT
		,	DeviceCode			VARCHAR(32) 
		,	LoginName			VARCHAR(50) CHARACTER SET utf8
		,	SubscriberName		VARCHAR(30) 
		,	TransDate			DATETIME 
		,	CreatedDate			DATETIME
		,	IP					BIGINT
		,	PluginID			BIGINT
		,	DeviceStatus		TINYINT
		,	URL					VARCHAR(250)
		,	ActionResult		VARCHAR(100)
		,	UserAgent			VARCHAR(500)
        ,	UserAgentCode		VARCHAR(32)
        ,	BrowserName			VARCHAR(20)
        ,	OSName				VARCHAR(20)
		,	Flagged				INT
        ,	SubscriberID		INT        
        ,	IsDeposit			INT
        ,	SubScriberPrefix	VARCHAR(30)
        ,	DeviceID			INT
        ,	AccountID			INT
	);
    
	   
	#=======================================================================================
    DROP TABLE IF EXISTS Temp_NewUserAgent;
	
	CREATE TEMPORARY TABLE Temp_NewUserAgent
    ( 
			UserAgent		VARCHAR(500)
        ,	UserAgentCode	VARCHAR(32)
        ,	BrowserName		VARCHAR(20)
        ,	OSName			VARCHAR(20)
        ,   CreatedDate		DATETIME		COMMENT 'Date Only'
	);
	
	SET op_ErrorCode	= 1;
    SET op_ErrorMessage	= 'Start: read xml file';
    
    #========1.GET DATA FROM XML TO TEMP TABLE=================================================================================
    SET RowCount = extractValue(ip_TransXml,'count(//root/transaction)');      
    
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/transaction['
			,   RowIndex
			,   ']');         
            
		
		INSERT INTO Temp_Transaction(StagingTransID, DeviceCode, LoginName, SubscriberName, TransDate, CreatedDate, IP
					, PluginID, DeviceStatus, URL, ActionResult, UserAgent, UserAgentCode, BrowserName, OSName, Flagged)
		SELECT 	EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::StagingTransID'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::LoginName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::TransDate'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::CreatedDate'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::IP'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::PluginID'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::DeviceStatus'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::URL'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::UserAgentCode'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::BrowserName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::OSName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::Flagged')
		);
    
	END WHILE;    
   
    #========INSERT: Subscriber which are unhandled interagtion=============================================================
	SET op_ErrorCode	= 2;
    SET op_ErrorMessage	= 'Start: Insert Subscriber';
    
	INSERT INTO FPS_Admin.Subscriber (SubscriberName, SubscriberPrefix, CreatedDate, CreatedBy, IsDeposit, Status, IsTest)
	SELECT 		ts.SubscriberName
					, NULL AS SubscriberPrefix
					, MIN(ts.CreatedDate) AS CreatedDate
                    , NULL AS CreatedBy
                    , NULL AS IsDeposit
                    , 2 AS Status			#0: Inactive; 1: Active; 2 Unhandled
                    , NULL AS IsTest
    FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_Admin.Subscriber AS sb
				ON ts.SubscriberName = sb.SubscriberName
	WHERE		sb.SubscriberName IS NULL
    GROUP BY	ts.SubscriberName;
    
    UPDATE Temp_Transaction AS ts
			, FPS_Admin.Subscriber AS sb
	SET		ts.SubscriberID 		= sb.SubscriberID
			, ts.IsDeposit 			= sb.IsDeposit
            , ts.SubScriberPrefix 	= sb.SubScriberPrefix
    WHERE	ts.SubscriberName = sb.SubscriberName;    
    
     #========INSERT: SubscriberURL if not Existing=========================================================================
	SET op_ErrorCode	= 3;
    SET op_ErrorMessage	= 'Start: Insert Subscriber';
    
    INSERT INTO FPS_DataCenter.SubscriberURL (URL, SubscriberID, CreatedDate)
    SELECT 		ts.URL
				, ts.SubscriberID
				, MIN(ts.CreatedDate) AS CreatedDate
    FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	WHERE		su.URL IS NULL
    GROUP BY	ts.URL, ts.SubscriberID;  
    
	#========INSERT: Get New Agent to temp table============================================================================== 
	SET op_ErrorCode	= 4;
    SET op_ErrorMessage	= 'Start:  Get New Agent to temp table';
    
    INSERT INTO Temp_NewUserAgent(UserAgentCode, UserAgent, BrowserName, OSName, CreatedDate)
	SELECT		ts.UserAgentCode
				, ts.UserAgent
				, ts.BrowserName
				, ts.OSName
				, MIN(ts.CreatedDate) AS CreatedDate
    FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	WHERE		ua.UserAgentCode IS NULL
    GROUP BY	ts.UserAgentCode, ts.UserAgent, ts.BrowserName, ts.OSName;
    
	#####===INSERT: BROWSER
    SET op_ErrorCode	= 5;
    SET op_ErrorMessage	= 'Start:  Insert Browser';
    
    INSERT INTO FPS_DataCenter.Browser(BrowserName, CreatedDate)
    SELECT 		ts.BrowserName
				, MIN(ts.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS ts
	LEFT JOIN	FPS_DataCenter.Browser AS br
				ON ts.BrowserName = br.BrowserName
	WHERE		br.BrowserName IS NULL
    GROUP BY	ts.BrowserName;    
    
    #####===INSERT: OS============================================================================================================
    SET op_ErrorCode	= 6;
    SET op_ErrorMessage	= 'Start:  Insert OS';
    
	INSERT INTO FPS_DataCenter.OS(OSName, CreatedDate)
    SELECT 		ts.OSName
				, MIN(ts.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS ts
	LEFT JOIN	FPS_DataCenter.OS AS os
				ON ts.OSName = os.OSName
	WHERE		os.OSName IS NULL
    GROUP BY	ts.OSName;
    
    #####===INSERT: UserAgent======================================================================================================
    SET op_ErrorCode	= 7;
    SET op_ErrorMessage	= 'Start:  Insert UserAgent';
    
    INSERT INTO FPS_DataCenter.UserAgent(UserAgent, UserAgentCode, BrowserID, OSID)
    SELECT		ts.UserAgent
				, ts.UserAgentCode
                , br.BrowserID
                , os.OSID
    FROM		Temp_NewUserAgent AS ts
    INNER JOIN	FPS_DataCenter.OS AS os
				ON ts.OSName = os.OSName
	INNER JOIN	FPS_DataCenter.Browser AS br
				ON ts.BrowserName = br.BrowserName;
    
    #======INSERT: DEVICE===========================================================================================================
    SET op_ErrorCode	= 8;
    SET op_ErrorMessage	= 'Start:  Insert Device';
    
    INSERT INTO Device(DeviceCode, UserAgentID, PluginID, CreatedDate, LastAccessDate)    
	SELECT 		ts.DeviceCode
				, MAX(ua.UserAgentID) AS UserAgentID
                , MAX(ts.PluginID)
                , MIN(ts.CreatedDate) AS CreatedDate
                , MAX(ts.CreatedDate) AS LastAccessDate
    FROM		Temp_Transaction AS ts	
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	LEFT JOIN	FPS_DataCenter.Device AS dv
				ON ts.DeviceCode = dv.DeviceCode
	WHERE		dv.DeviceCode IS NULL
    GROUP BY	ts.DeviceCode;    
    
	#======UPDATE: Temp_Transaction.DeviceID==========================================================================================
    SET op_ErrorCode	= 9;
    SET op_ErrorMessage	= 'Start:  Update DeviceID to Temp_Transaction';
    
    UPDATE 	Temp_Transaction AS ts
			, FPS_DataCenter.Device AS dv
	SET		ts.DeviceID		= dv.DeviceID
    WHERE	ts.DeviceCode	= dv.DeviceCode;
    
    #=====INSERT: NEW ACCOUNT==========================================================================================================
	SET op_ErrorCode	= 10;
    SET op_ErrorMessage	= 'Start:  Insert Account';
    
    INSERT INTO FPS_DataCenter.Account
	(
		CustID
		, Username
		, Username2
		, SubscriberID
		, RoleID
		, CurrencyID
		, CurrencyName
		, IsDeposit
		, CreatedDate
		, FirstLoginName
    )
    SELECT
		NULL AS CustID
		, NULL AS Username
		, NULL AS Username2
		, ts.SubscriberID
		, NULL AS RoleID
		, NULL AS CurrencyID
		, NULL AS CurrencyName
		, MIN(ts.IsDeposit)
		, MIN(ts.CreatedDate)
		, ts.LoginName AS FirstLoginName
	FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_DataCenter.Account AS ac
				ON	ts.SubscriberID = ac.SubscriberID
					AND	( 	ts.LoginName = ac.FirstLoginName
							OR ts.LoginName = ac.UserName
                            OR ts.LoginName = ac.Username2
                            OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2
						)
	WHERE		ac.AccountID IS NULL
    GROUP BY	ts.SubscriberID, ts.LoginName;    
    
   #======UPDATE: Temp_Transaction.AccountID======================================================================================== 
   
	SET op_ErrorCode	= 11;
    SET op_ErrorMessage	= 'Start:  Update AccountID to Temp_Transaction';
    
    UPDATE 	Temp_Transaction AS ts
			, FPS_DataCenter.Account AS ac
	SET		ts.AccountID = ac.AccountID
    WHERE	( ts.LoginName 		= ac.FirstLoginName
				OR ts.LoginName = ac.UserName
				OR ts.LoginName = ac.Username2
				OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2
			);	
		
 
	#========INSERT: Associations--========================================================================================================================
    SET op_ErrorCode	= 12;
    SET op_ErrorMessage	= 'Start:  Insert Association';
    
    INSERT INTO FPS_DataCenter.Association(DeviceID, AccountID, SubscriberID, CreatedDate)
    SELECT		ts.DeviceID
				, ts.AccountID
				, ts.SubscriberID
                , MIN(ts.CreatedDate)
    FROM		Temp_Transaction AS ts
    LEFT JOIN	FPS_DataCenter.Association AS ac
				ON	(ts.SubscriberID	= ac.SubscriberID
                AND	ts.AccountID 		= ac.AccountID
                AND	ts.DeviceID			= ac.DeviceID)
	WHERE		ac.AccountID IS NULL
    GROUP BY	ts.DeviceID
				, ts.AccountID
				, ts.SubscriberID;
    
    #========================================================================================================
    SET op_ErrorCode	= 13;
    SET op_ErrorMessage	= 'Start:  Insert ActionResult';
    
    INSERT INTO FPS_DataCenter.ActionResult(ActionResultKey, Status, CreatedDate)
	SELECT 		ts.ActionResult              
                , 2 AS Status
                , MIN(ts.CreatedDate) AS CreatedDate
	FROM		Temp_Transaction AS ts	
	LEFT JOIN	FPS_DataCenter.ActionResult AS ar
				ON ts.ActionResult = ar.ActionResultKey
	WHERE		ar.ActionResultKey IS NULL
    GROUP BY	ts.ActionResult;   
    
    #========INSERT: Transaction===============================================================================================
    SET op_ErrorCode	= 14;
    SET op_ErrorMessage	= 'Start:  Insert Transaction';
    
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, DeviceID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, IPRangeID, PluginID, DeviceStatus, Flagged,ActionResultID)                
	SELECT 		ts.StagingTransID
				, su.SubscriberID
				, su.SubscriberURLID
				, ua.UserAgentID
				, dv.DeviceID
				, ts.LoginName
				, ac.AccountID            
				, ts.TransDate
				, ts.CreatedDate
				, ts.IP
                , (SELECT IPRangeID FROM IPRange AS ir WHERE (ts.IP between ir.FromIP and ir.ToIP) AND ir.Status = 1) AS IPRangeID #===Get IPRangeID which Active(status=1)
				, ts.PluginID
				, ts.DeviceStatus
				, ts.Flagged
				, ar.ActionResultID              
	FROM		Temp_Transaction AS ts
    INNER JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	INNER JOIN	UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	INNER JOIN	FPS_DataCenter.Device AS dv
				ON ts.DeviceCode = dv.DeviceCode
	INNER JOIN	FPS_DataCenter.ActionResult AS ar
				ON ts.ActionResult	= ar.ActionResultKey
	INNER JOIN	FPS_DataCenter.Account AS ac
				ON	ts.SubscriberID = ac.SubscriberID
					AND (ts.LoginName = ac.FirstLoginName
						OR ts.LoginName = ac.UserName
						OR ts.LoginName = ac.Username2
						OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2);
                        
    #==========UPDATE: StagingRawTransaction.IsProcessed = 1================================================================================================================
    SET op_ErrorCode	= 15;
	SET op_ErrorMessage	= 'Start: Update IsProcessed is done for FPS_RawTrans.StagingRawTransaction';  
    SELECT op_ErrorCode;
    # UPDATE IsProcessed = 1
	IF op_ErrorCode = 0 THEN		
		UPDATE 	FPS_RawTrans.StagingRawTransaction AS st
				, Temp_Transaction AS ts
		SET		st.IsProcessed = 1
		WHERE	st.StagingTransID = ts.StagingTransID
				AND st.IsProcessed = 0;
	END IF;
    
	SET op_ErrorCode	= 0;
	SET op_ErrorMessage	= 'Process Successfully';  
         
END$$

DELIMITER ;

