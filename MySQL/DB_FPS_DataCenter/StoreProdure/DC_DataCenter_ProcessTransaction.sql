/*
	Created: 20190610@Casey.Huynh
	Task : Process data from raw to data center
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.DC_DataCenter_ProcessTransaction$$

CREATE PROCEDURE FPS_DataCenter.DC_DataCenter_ProcessTransaction(IN ip_TransXml LONGTEXT)
BEGIN
	DECLARE RowIndex 			INT UNSIGNED DEFAULT 0;
	DECLARE RowCount 			INT UNSIGNED;
	DECLARE XpathRow 			VARCHAR(50);
    DECLARE	UnhandleStatus			TINYINT DEFAULT 2;
    
    #=========================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
	
	CREATE TEMPORARY TABLE Temp_Transaction
    ( 
		 LoginName			VARCHAR(50) CHARACTER SET UTF8
		, SubscriberName	VARCHAR(30) 
		, TransDate			DATETIME 
		, CreatedDate		DATETIME        
		, DeviceCode		VARCHAR(32)
        , DeviceCodeStatus	TINYINT(1)
        , FingeringCode		VARCHAR(320)
        , FingeringMoreInfo	TEXT	
		, IP				DECIMAL(50,0)
		, PluginID			BIGINT		
		, URL				VARCHAR(250)
		, ActionResult		VARCHAR(100)
		, UserAgent			TEXT        
        , UserAgentCode		VARCHAR(64)
        , BrowserName		VARCHAR(100)
        , OSName			VARCHAR(100)
		, Flagged			INT        
        , StagingTransID	BIGINT        
        , SubscriberID		INT        
        , IsDeposit			INT
        , SubScriberPrefix	VARCHAR(30)       
        , AccountID			BIGINT       
        , SubscriberURLID	BIGINT
        , ActionResultID	BIGINT
        , UserAgentID		BIGINT        
	);
    
	   
	#========================================================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_NewUserAgent;
	
	CREATE TEMPORARY TABLE Temp_NewUserAgent
    ( 
		UserAgent		VARCHAR(500)
        , UserAgentCode	VARCHAR(64)
        , BrowserName		VARCHAR(100)
        , OSName			VARCHAR(100)
        , CreatedDate		DATETIME		COMMENT 'Date Only'
	);
	
   
    #========1.GET DATA FROM XML TO TEMP TABLE=================================================================================
    SET RowCount = EXTRACTVALUE(ip_TransXml,'count(//root/transaction)');      
    
    WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/transaction['
			,   RowIndex
			,   ']');                     
		
		INSERT INTO Temp_Transaction(StagingTransID, DeviceCode, DeviceCodeStatus, FingeringCode, FingeringMoreInfo, LoginName, SubscriberName, TransDate, CreatedDate
				, IP, PluginID, URL, ActionResult, UserAgent, UserAgentCode, BrowserName, OSName, Flagged)
		SELECT 	EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::StagingTransID'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::DeviceCodeStatus'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::FingeringCode'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::FingeringMoreInfo'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::LoginName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::SubscriberName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::TransDate'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::CreatedDate'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::IP'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::PluginID'))				
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::URL'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::ActionResult'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::UserAgent'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::UserAgentCode'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::BrowserName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::OSName'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::Flagged'))
		;
    
	END WHILE;
   
    #========INSERT: Subscriber which are unhandled interagtion=============================================================   
	INSERT INTO FPS_Admin.Subscriber (SubscriberName, SubscriberPrefix, CreatedDate, CreatedBy, IsDeposit, Status, IsTest)
	SELECT 		ts.SubscriberName
					, NULL AS SubscriberPrefix
					, MIN(ts.TransDate) AS CreatedDate
                    , NULL AS CreatedBy
                    , NULL AS IsDeposit
                    , UnhandleStatus AS Status			#0: Inactive; 1: Active; 2 Unhandled
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
   
     #========INSERT: SubscriberURL if not Existing============================================================================   
    INSERT INTO FPS_DataCenter.SubscriberURL (URL, SubscriberID, CreatedDate)
    SELECT 		ts.URL
				, ts.SubscriberID
				, MIN(ts.TransDate) AS CreatedDate
    FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	WHERE		su.URL IS NULL
    GROUP BY	ts.URL, ts.SubscriberID;  
     
	#========INSERT: Get New Agent to temp table================================================================================    
    INSERT INTO Temp_NewUserAgent(UserAgentCode, UserAgent, BrowserName, OSName, CreatedDate)
	SELECT		ts.UserAgentCode
				, ts.UserAgent
				, ts.BrowserName
				, ts.OSName
				, MIN(ts.TransDate) AS CreatedDate
    FROM		Temp_Transaction AS ts
	LEFT JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	WHERE		ua.UserAgentCode IS NULL
    GROUP BY	ts.UserAgentCode, ts.UserAgent, ts.BrowserName, ts.OSName;
    
	#####===INSERT: BROWSER======================================================================================================  
    INSERT INTO FPS_DataCenter.Browser(BrowserName, CreatedDate)
    SELECT 		nu.BrowserName
				, MIN(nu.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS nu
	LEFT JOIN	FPS_DataCenter.Browser AS br
				ON nu.BrowserName = br.BrowserName
	WHERE		br.BrowserName IS NULL
    GROUP BY	nu.BrowserName;    
    
    #####===INSERT: OS=========================================================================================================== 
	INSERT INTO FPS_DataCenter.OS(OSName, CreatedDate)
    SELECT 		nu.OSName
				, MIN(nu.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS nu
	LEFT JOIN	FPS_DataCenter.OS AS os
				ON nu.OSName = os.OSName
	WHERE		os.OSName IS NULL
    GROUP BY	nu.OSName;
    
    #####===INSERT: UserAgent======================================================================================================   
    INSERT INTO FPS_DataCenter.UserAgent(UserAgent, UserAgentCode, BrowserID, OSID)
    SELECT		nu.UserAgent
				, nu.UserAgentCode
                , br.BrowserID
                , os.OSID
    FROM		Temp_NewUserAgent AS nu
    INNER JOIN	FPS_DataCenter.OS AS os
				ON nu.OSName = os.OSName
	INNER JOIN	FPS_DataCenter.Browser AS br
				ON nu.BrowserName = br.BrowserName;
                
	INSERT INTO FPS_DataCenter.ActionResult(ActionResultKey, ActionStatus, CreatedDate)
    SELECT		ts.ActionResult
				, UnhandleStatus AS ActionStatus
				, MIN(ts.CreatedDate) AS CreatedDate
	FROM		Temp_Transaction AS ts
    LEFT JOIN	FPS_DataCenter.ActionResult AS ar
				ON ar.ActionResultKey = ts.ActionResult
    WHERE		ar.ActionResultID IS NULL
    GROUP BY	ts.ActionResult;   
    
    #=====INSERT: NEW ACCOUNT==========================================================================================================    
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
		, MIN(ts.TransDate)
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
    UPDATE 	Temp_Transaction AS ts
	INNER JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	INNER JOIN	FPS_DataCenter.ActionResult AS ar
				ON ts.ActionResult	= ar.ActionResultKey
	INNER JOIN	FPS_DataCenter.Account AS ac
				ON	ts.SubscriberID = ac.SubscriberID
					AND (ts.LoginName = ac.FirstLoginName
						OR ts.LoginName = ac.UserName
						OR ts.LoginName = ac.Username2
						OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2)
	SET		ts.AccountID = ac.AccountID
			, ts.UserAgentID = ua.UserAgentID
            , ts.ActionResultID = ar.ActionResultID
            , ts.SubscriberURLID  = su.SubscriberURLID
    WHERE	( ts.LoginName 		= ac.FirstLoginName
				OR ts.LoginName = ac.UserName
				OR ts.LoginName = ac.Username2
				OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2
			);
	#========PROCESS DEVICE==============================================
	#========================================================================================================================
	#PROCESS DEVICE: INSERT NEW DEVICE IF DeviceCodeStatus IS NULL
    DROP TEMPORARY TABLE IF EXISTS Temp_DeviceTrans;
	
	CREATE TEMPORARY TABLE Temp_DeviceTrans
    ( 
		 LoginName			VARCHAR(50) CHARACTER SET UTF8
		, SubscriberName	VARCHAR(30) 
		, TransDate			DATETIME 
		, CreatedDate		DATETIME        
		, DeviceCode		VARCHAR(32)
        , DeviceCodeStatus	TINYINT(1)
        , FingeringCode		VARCHAR(320)
        , FingeringMoreInfo	TEXT	
		, IP				DECIMAL(50,0)
		, PluginID			BIGINT		
		, URL				VARCHAR(250)
		, ActionResult		VARCHAR(100)
		, UserAgent			TEXT        
        , UserAgentCode		VARCHAR(64)
        , BrowserName		VARCHAR(100)
        , OSName			VARCHAR(100)
		, Flagged			INT
        , StagingTransID	BIGINT        
        , SubscriberID		INT        
        , IsDeposit			INT
        , SubScriberPrefix	VARCHAR(30)        
        , DeviceID			BIGINT
        , AccountID			BIGINT
        , SubscriberURLID	BIGINT        
        , UserAgentID		BIGINT
        , ActionResultID	BIGINT
        , MatchFingeringCode	TINYINT(1)
        , MergeFingeringCode	VARCHAR(320)
        , OldFingeringCode		VARCHAR(320)
        , ExistingDeviceId		BIGINT
        , DeviceFingeringID		BIGINT
	);
	
    DROP TEMPORARY TABLE IF EXISTS Temp_NewDevice;
    CREATE TEMPORARY TABLE Temp_NewDevice(
		DeviceCode				VARCHAR(32)
        , MinStagingTransID		BIGINT
    );  
   
    
    INSERT INTO Temp_DeviceTrans(StagingTransID, DeviceCode, DeviceCodeStatus, FingeringCode, FingeringMoreInfo, LoginName, SubscriberName, TransDate, CreatedDate
				, IP, PluginID, URL, ActionResult, UserAgent, UserAgentCode, BrowserName, OSName, Flagged,	SubscriberID
                , AccountID, SubscriberURLID, UserAgentID , ActionResultID, MatchFingeringCode, MergeFingeringCode, ExistingDeviceId, DeviceFingeringID)
    SELECT 		ts.StagingTransID
				, ts.DeviceCode
                , ts.DeviceCodeStatus
                , ts.FingeringCode
                , ts.FingeringMoreInfo
                , ts.LoginName
                , ts.SubscriberName
                , ts.TransDate
                , ts.CreatedDate
				, ts.IP
                , ts.PluginID
                , ts.URL
                , ts.ActionResult
                , ts.UserAgent
                , ts.UserAgentCode
                , ts.BrowserName
                , ts.OSName
                , ts.Flagged
                , ts.SubscriberID
                , ts.AccountID
                , ts.SubscriberURLID
                , ts.UserAgentID
                , ts.ActionResultID
                , DC_ISLISTSMATCHBYITEM(';',ts.FingeringCode, df.FingeringCode) AS MatchFingeringCode
                , DC_MERGEIFDIFFERENCELISTS(';', ts.FingeringCode, df.FingeringCode) AS MergeFingeringCode
                , dc.DeviceID
                , df.DeviceFingeringID
	FROM		Temp_Transaction AS ts
    LEFT JOIN	FPS_DataCenter.Association AS ac
					ON ts.AccountID = ac.AccountID
	LEFT JOIN	FPS_DataCenter.DeviceFingering AS df
					ON  ac.DeviceID = df.DeviceID
	LEFT JOIN	FPS_DataCenter.DeviceCode AS dc
				ON ts.DeviceCode = dc.DeviceCode
    WHERE		ts.DeviceCode IS NOT NULL; 	    
    
    #SELECT 'Temp_DeviceTrans', t.* FROM Temp_DeviceTrans t;
    
    INSERT INTO Temp_NewDevice(DeviceCode, MinStagingTransID)
    SELECT dt.DeviceCode
			, MIN(dt.StagingTransID)
    FROM   Temp_DeviceTrans AS dt
    WHERE 	dt.MatchFingeringCode = 0 AND dt.ExistingDeviceId IS NULL
    GROUP BY dt.DeviceCode;	
    
    #SELECT 'Temp_NewDevice', t.* FROM Temp_NewDevice t;
    
	INSERT INTO FPS_DataCenter.Device(FirstDeviceCode, FirstFingeringCode, FirstAccountID, StagingTransID, CreatedDate, DeviceStatus)
    SELECT 		dt.DeviceCode
				, dt.FingeringCode
				, dt.AccountID
                , nd.MinStagingTransID 
				, dt.CreatedDate
				, 0 AS DeviceStatus
    FROM		Temp_DeviceTrans AS dt
    INNER JOIN	Temp_NewDevice AS nd
				ON nd.MinStagingTransID = dt.StagingTransID;                
    
    
    #Update Device Status for Existing Device Device Status = 1 
     DROP TEMPORARY TABLE IF EXISTS Temp_ExistingDevice;
    CREATE temporary TABLE Temp_ExistingDevice(
		ExistingDeviceID BIGINT
    );
    
    INSERT INTO Temp_ExistingDevice(ExistingDeviceID)
    SELECT 	dt.ExistingDeviceID
    FROM	Temp_DeviceTrans AS dt
	INNER JOIN	FPS_DataCenter.DeviceCode as dc
    LEFT JOIN	Temp_NewDevice as nd
				ON nd.DeviceCode = dt.DeviceCode
    WHERE		dt.ExistingDeviceID = dc.DeviceID
				AND nd.DeviceCode IS NULL
    GROUP BY	dt.ExistingDeviceID;     
       
    UPDATE FPS_DataCenter.Device dv
    INNER JOIN Temp_ExistingDevice as ed
				on dv.DeviceID = ed.ExistingDeviceID
	SET	dv.DeviceStatus = 1;
    
    #SELECT 'aaa';
	#Update Device Status for Recover Device Device Status = 2
    DROP TEMPORARY TABLE IF EXISTS Temp_RecoverDevice;
	CREATE temporary TABLE Temp_RecoverDevice(
		RecoverDeviceID BIGINT
    );
    
    INSERT INTO Temp_RecoverDevice(RecoverDeviceID)
    SELECT 		dt.ExistingDeviceID
    FROM		Temp_DeviceTrans AS dt
	LEFT JOIN	Temp_ExistingDevice as ed
				ON ed.ExistingDeviceID = dt.ExistingDeviceID
    WHERE		ed.ExistingDeviceID IS NULL ;    
    
    #SELECT 'bbb';
	UPDATE FPS_DataCenter.Device dv
    INNER JOIN Temp_RecoverDevice as ed
				on dv.DeviceID = ed.RecoverDeviceID
	SET	dv.DeviceStatus = 2;
    
   
    #SELECT 'FPS_DataCenter.Device', t.* FROM FPS_DataCenter.Device t;
    
	INSERT INTO FPS_DataCenter.DeviceCode(DeviceCode, DeviceID, CreatedDate)
    SELECT		nd.DeviceCode
				, dv.DeviceID
                , dv.CreatedDate
    FROM 		Temp_NewDevice	 AS nd
    INNER JOIN	FPS_DataCenter.Device AS dv
				ON nd.DeviceCode = dv.FirstDeviceCode;
    
    #SELECT 'FPS_DataCenter.DeviceCode01', t.* FROM FPS_DataCenter.DeviceCode t;
    
    INSERT INTO FPS_DataCenter.DeviceCode(DeviceCode, DeviceID, CreatedDate)
    SELECT		nd.DeviceCode
				, nd.ExistingDeviceID
                , MIN(nd.CreatedDate)
    FROM 		Temp_DeviceTrans AS nd
    LEFT JOIN	FPS_DataCenter.DeviceCode dc
				ON dc.DeviceCode = nd.DeviceCode
	WHERE		nd.ExistingDeviceId IS NOT NULL
				AND dc.DeviceID IS NULL
    GROUP BY	nd.DeviceCode, nd.ExistingDeviceID;
    
	#SELECT 'FPS_DataCenter.DeviceCode02', t.* FROM FPS_DataCenter.DeviceCode t;
     
	INSERT INTO FPS_DataCenter.DeviceFingering(DeviceID, FingeringCode, FingeringMoreInfo, UserAgentID, PluginID, CreatedDate)
    SELECT 		dv.DeviceID
				, dv.FirstFingeringCode
				, dt.FingeringMoreInfo
				, dt.UserAgentID
				, dt.PluginID
				, dt.CreatedDate
    FROM		FPS_DataCenter.Device AS dv
    INNER JOIN	Temp_DeviceTrans AS dt
				ON dt.StagingTransID = dv.StagingTransID
	INNER JOIN	Temp_NewDevice AS nd
				ON nd.MinStagingTransID = dt.StagingTransID;               	
    
	#SELECT 'FPS_DataCenter.DeviceFingering', t.* FROM FPS_DataCenter.DeviceFingering t;
   
	#========INSERT: Associations--==========================================================================================    
   INSERT INTO FPS_DataCenter.Association(DeviceID, AccountID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		dv.DeviceID
				, ts.AccountID
				, ts.SubscriberID
                , MIN(ts.TransDate)
                , 0 AS SyncGraphDB
    FROM		Temp_Transaction AS ts
	INNER JOIN	FPS_DataCenter.Device AS dv
				ON dv.FirstDeviceCode = ts.DeviceCode
    LEFT JOIN	FPS_DataCenter.Association AS ac
				ON	(ts.SubscriberID	= ac.SubscriberID
                AND	ts.AccountID 		= ac.AccountID
                AND	dv.DeviceID			= ac.DeviceID)
	WHERE		ac.AccountID IS NULL
				AND dv.DeviceID IS NOT NULL
    GROUP BY	dv.DeviceID
				, ts.AccountID
				, ts.SubscriberID;
    
    #========INSERT: Transaction: DEVICECODE NULL==============================================================================================='
	#SELECT 	'FPS_DataCenter.Transaction01', t.* FROM FPS_DataCenter.Transaction t;
    INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, IPRangeLocationID, PluginID, DeviceStatus, Flagged,ActionResultID, DeviceCode)                
	SELECT 		ts.StagingTransID
				, ts.SubscriberID
				, ts.SubscriberURLID
				, ts.UserAgentID
				, ts.LoginName
				, ts.AccountID            
				, ts.TransDate
				, ts.CreatedDate
				, ts.IP
                , (SELECT IPRangeLocationID FROM IPRangeLocation AS ir WHERE (ts.IP BETWEEN ir.FromIP AND ir.ToIP) AND ir.Status = 1) AS IPRangeLocationID #===Get IPRangeID which Active(status=1)
				, ts.PluginID
				, ts.DeviceCodeStatus
				, ts.Flagged
				, ts.ActionResultID
				, ts.DeviceCode
	FROM		Temp_Transaction AS ts
    WHERE		ts.DeviceCode IS NULL;

	#SELECT 	'FPS_DataCenter.Transaction02', t.* FROM FPS_DataCenter.Transaction t;
    #========INSERT TRANS: DeviceCODE IS NOT NULL=======================================================
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, DeviceID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, IPRangeLocationID, PluginID, DeviceStatus, Flagged,ActionResultID, DeviceCode, DeviceFingeringID)                
	SELECT 		ts.StagingTransID
				, ts.SubscriberID
				, ts.SubscriberURLID
				, ts.UserAgentID
				, ts.ExistingDeviceID
				, ts.LoginName
				, ts.AccountID            
				, ts.TransDate
				, ts.CreatedDate
				, ts.IP
                , (SELECT IPRangeLocationID FROM IPRangeLocation AS ir WHERE (ts.IP BETWEEN ir.FromIP AND ir.ToIP) AND ir.Status = 1) AS IPRangeLocationID #===Get IPRangeID which Active(status=1)
				, ts.PluginID
				, ts.DeviceCodeStatus
				, ts.Flagged
				, ts.ActionResultID
				, ts.DeviceCode
                , ts.DeviceFingeringID
	FROM		Temp_DeviceTrans AS ts
    WHERE		ts.ExistingDeviceID IS NOT NULL;
    
    #SELECT 	'FPS_DataCenter.Transaction03', t.* FROM FPS_DataCenter.Transaction t;
      
    INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, DeviceID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, IPRangeLocationID, PluginID, DeviceStatus, Flagged,ActionResultID, DeviceCode, DeviceFingeringID)                
	SELECT 		ts.StagingTransID
				, ts.SubscriberID
				, ts.SubscriberURLID
				, ts.UserAgentID
				, dc.DeviceID
				, ts.LoginName
				, ts.AccountID            
				, ts.TransDate
				, ts.CreatedDate
				, ts.IP
                , ir.IPRangeLocationID
				, ts.PluginID
				, ts.DeviceCodeStatus
				, ts.Flagged
				, ts.ActionResultID
				, ts.DeviceCode
                , df.DeviceFingeringID
	FROM		Temp_DeviceTrans AS ts
    LEFT JOIN	FPS_DataCenter.DeviceCode as dc
				on ts.DeviceCode = dc.DeviceCode
	LEFT JOIN 	FPS_DataCenter.DeviceFingering as df
				on dc.DeviceID = df.DeviceID
	LEFT JOIN	IPRangeLocation AS ir
				ON (ts.IP BETWEEN ir.FromIP AND ir.ToIP) AND ir.Status = 1
    WHERE		ts.ExistingDeviceID IS NULL
				AND DC_ISLISTSMATCHBYITEM(';',ts.FingeringCode, df.FingeringCode) = 1;  
                        
    #==========UPDATE: StagingRawTransaction.IsProcessed = 1================================================================================================================
	UPDATE 	FPS_StagingRawTrans.RawTransaction AS st
				, Temp_Transaction AS ts
	SET		st.IsProcessed = 1
	WHERE	st.StagingTransID = ts.StagingTransID
			AND st.IsProcessed = 0;	

END$$
DELIMITER ;


