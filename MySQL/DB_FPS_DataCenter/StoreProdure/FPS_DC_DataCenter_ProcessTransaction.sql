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

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_ProcessTransaction$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_ProcessTransaction(IN ip_TransXml LONGTEXT)
BEGIN
	DECLARE RowIndex 			INT DEFAULT 0;
	DECLARE RowCount 			INT;
	DECLARE XpathRow 			VARCHAR(50);
    DECLARE	UnhandleStatus		TINYINT DEFAULT 2;
    DECLARE DeviceStatusNew			TINYINT DEFAULT 1;			# New Device
    DECLARE DeviceStatusExisting	TINYINT DEFAULT 2;			# Existing Device has not been recover
    DECLARE DeviceStatusRecover		TINYINT DEFAULT 3;			# Recover Device	
    
    ####
    
    DECLARE StartTime			DATETIME;
    DECLARE ENDTime				DATETIME;
    DECLARE SPName				VARCHAR(200) Default 'FPS_DC_DataCenter_ProcessTransaction';
    SET StartTime	= current_timestamp();
    #=========================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
	
	CREATE TEMPORARY TABLE Temp_Transaction
    ( 
		StagingTransID	BIGINT  
        , LoginName			VARCHAR(50) CHARACTER SET UTF8
		, SubscriberName	VARCHAR(30) 
		, TransDate			DATETIME 
		, CreatedDate		DATETIME        
		, DeviceCode		VARCHAR(320)
		, FingeringCode		VARCHAR(1000)
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
		, AccountID			BIGINT
		, CustID			BIGINT
		, Username			VARCHAR(50)
		, Username2			VARCHAR(50)
		, RoleID			TINYINT(1)			
		, CurrencyID		TINYINT(2)
		, CurrencyName		VARCHAR(50)
        , SubscriberID		BIGINT
		      
		, IsDeposit			INT
		, SubScriberPrefix	VARCHAR(30) 
		, SubscriberURLID	BIGINT
		, ActionResultID	BIGINT
		, UserAgentID		BIGINT
        , DeviceID			BIGINT
        
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
		INSERT INTO Temp_Transaction(StagingTransID, DeviceCode, FingeringCode, FingeringMoreInfo, LoginName, SubscriberName, TransDate, CreatedDate
				, IP, PluginID, URL, ActionResult, UserAgent, UserAgentCode, BrowserName, OSName, Flagged, AccountID, IsDeposit,
                CustID, Username, Username2, RoleID, CurrencyID, CurrencyName, SubscriberID)
		SELECT 	EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::StagingTransID'))
				, EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::DeviceCode'))
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
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::AccountID'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::IsDeposit'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::CustID'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::Username'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::Username2'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::RoleID'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::CurrencyID'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::CurrencyName'))
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::SubscriberID'))
		;
    
	END WHILE;
    
	#SELECT 'DEBUG02', ts.* FROM Temp_Transaction as ts;
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,1,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
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
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,2,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    UPDATE 	FPS_RawTransaction.RawTransaction AS st
	INNER JOIN Temp_Transaction AS ts
				ON st.StagingTransID = ts.StagingTransID 
                AND st.IsProcessed = 0 
                AND ts.SubscriberID = 0
	SET		st.IsProcessed = -1;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,3,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/    
    
    #Remove all transaction have SubscriberID  = '0' --Unhandle Subscriber
    DELETE FROM Temp_Transaction
    WHERE SubscriberID = 0;
	
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,5,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
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
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,4,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
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
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,5,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
	#####===INSERT: BROWSER======================================================================================================  
    INSERT INTO FPS_DataCenter.Browser(BrowserName, CreatedDate)
    SELECT 		nu.BrowserName
				, MIN(nu.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS nu
	LEFT JOIN	FPS_DataCenter.Browser AS br
				ON nu.BrowserName = br.BrowserName
	WHERE		br.BrowserName IS NULL
    GROUP BY	nu.BrowserName;    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,6,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    #####===INSERT: OS=========================================================================================================== 
	INSERT INTO FPS_DataCenter.OS(OSName, CreatedDate)
    SELECT 		nu.OSName
				, MIN(nu.CreatedDate) AS CreatedDate
    FROM		Temp_NewUserAgent AS nu
	LEFT JOIN	FPS_DataCenter.OS AS os
				ON nu.OSName = os.OSName
	WHERE		os.OSName IS NULL
    GROUP BY	nu.OSName;
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,7,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
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
     /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,8,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/           
	INSERT INTO FPS_DataCenter.ActionResult(ActionResultKey, ActionStatus, CreatedDate)
    SELECT		ts.ActionResult
				, UnhandleStatus AS ActionStatus
				, MIN(ts.CreatedDate) AS CreatedDate
	FROM		Temp_Transaction AS ts
    LEFT JOIN	FPS_DataCenter.ActionResult AS ar
				ON ar.ActionResultKey = ts.ActionResult
    WHERE		ar.ActionResultID IS NULL
    GROUP BY	ts.ActionResult;   
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,9,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    #=====INSERT: NEW ACCOUNT==========================================================================================================    
    
    DROP TEMPORARY TABLE IF EXISTS Temp_AccountFirstTrans;
    CREATE TEMPORARY TABLE Temp_AccountFirstTrans(
			Username2			VARCHAR(50)
            , SubscriberID			BIGINT
            , IsDeposit				BIGINT
            , MinStagingTransID		BIGINT
            , AccountID				BIGINT
    );
	
    
    #===============Account: Deposit
    INSERT INTO Temp_AccountFirstTrans(Username2, SubscriberID, IsDeposit, AccountID, MinStagingTransID)
    SELECT		CONCAT(sb.SubScriberPrefix,ts.LoginName) AS Username2
				, ts.SubscriberID
				, ts.IsDeposit
                , ts.AccountID
                , Min(ts.StagingTransID) 
    FROM		Temp_Transaction AS ts
    INNER JOIN	FPS_Admin.Subscriber AS sb
				on ts.SubscriberID = sb.SubscriberID
	WHERE		ts.IsDeposit = 1
    GROUP BY	ts.LoginName, ts.SubscriberID, sb.SubScriberPrefix, ts.AccountID;    
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,10,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    #SELECT 'DEBUG03-Deposit', a.* FROM Temp_AccountFirstTrans a;
	#===============Account: Credit
    INSERT INTO Temp_AccountFirstTrans(Username2, SubscriberID, IsDeposit, AccountID, MinStagingTransID)
    SELECT		ts.Username2
				, ts.SubscriberID
                , ts.IsDeposit
                , AccountID
                , Min(ts.StagingTransID)                
    FROM		Temp_Transaction AS ts
    WHERE		ts.IsDeposit = 0
    GROUP BY	ts.Username2, ts.SubscriberID, AccountID; 
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,11,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
	#SELECT 'DEBUG04-Credit', a.* FROM Temp_AccountFirstTrans a;
    INSERT INTO FPS_DataCenter.Account
	(
		CustID
		, Username
		, Username2
		, SubscriberID
        , IsDeposit
		, RoleID
		, CurrencyID
		, CurrencyName
		, CreatedDate
		, FirstLoginName
    )
    SELECT
		ts.CustID
		, ts.Username
		, ts.Username2
		, ts.SubscriberID
        , ts.IsDeposit
		, ts.RoleID
		, ts.CurrencyID
		, ts.CurrencyName
        , ts.CreatedDate
		, ts.LoginName AS FirstLoginName
	FROM		Temp_Transaction AS ts
	INNER JOIN	Temp_AccountFirstTrans AS ta
				ON ts.StagingTransID = ta.MinStagingTransID
	INNER JOIN	FPS_Admin.Subscriber sub
				ON	ta.SubscriberID = sub.SubscriberID AND sub.Status != 2
	LEFT JOIN	FPS_DataCenter.Account ac
			ON	sub.SubscriberID = ac.SubscriberID
				AND	( 	ts.LoginName = ac.FirstLoginName
						OR ts.LoginName = ac.UserName
						OR ts.Username2 = ac.Username2)
	WHERE		ts.AccountID = 0
				AND ac.AccountID IS NULL;
   
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,12,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    # SELECT 'DEBUG05-Account', a.* FROM FPS_DataCenter.Account a;   
     
	#======UPDATE: Temp_Transaction TransInfo========================================================================================      
    UPDATE 	Temp_Transaction AS ts
    INNER JOIN	FPS_Admin.Subscriber AS sub
				ON ts.SubscriberID = sub.SubscriberID
	INNER JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON ts.UserAgentCode = ua.UserAgentCode
	INNER JOIN	FPS_DataCenter.ActionResult AS ar
				ON ts.ActionResult = ar.ActionResultKey
	SET		ts.UserAgentID 			= ua.UserAgentID
            , ts.ActionResultID 	= ar.ActionResultID
            , ts.SubscriberURLID 	= su.SubscriberURLID
            , ts.SubScriberPrefix	= sub.SubScriberPrefix;
     /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,13,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    # SELECT 'DEBUG06-Temp_Transaction', a.* FROM Temp_Transaction a;  
     
	UPDATE 	Temp_Transaction AS ts
    INNER JOIN	FPS_DataCenter.Account AS ac
				ON ac.CustID = ts.CustId
    SET		ts.AccountID = ac.AccountID
	WHERE ts.AccountID = 0;
	
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,14,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    UPDATE 	Temp_Transaction AS ts
    INNER JOIN	FPS_DataCenter.Account AS ac
				ON ac.FirstLoginName = ts.LoginName AND ts.SubscriberID = ac.SubscriberID
    SET		ts.AccountID = ac.AccountID
	WHERE 	ts.AccountID = 0 AND ts.CustID = 0;
    
	# SELECT 'DEBUG07-Temp_Transaction', a.* FROM Temp_Transaction a;  
	
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,15,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
	# GET DEVICEID by Existing DeviceCode
	UPDATE		Temp_Transaction AS ts
	INNER JOIN	FPS_DataCenter.Device AS dv
				ON ts.DeviceCode = dv.DeviceCode
	SET			ts.DeviceID = dv.DeviceID;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,16,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    # Update DeviceID Status Existing
	UPDATE		FPS_DataCenter.Device AS dv
	INNER JOIN	Temp_Transaction AS ts
				ON ts.DeviceID = dv.DeviceID
	SET			dv.DeviceStatus = DeviceStatusExisting;     
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,17,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    # FIRST Trans BY ACCOUNT, FingeringCode
    DROP TEMPORARY TABLE IF EXISTS FirstTransAccountFingering;
    CREATE temporary table FirstTransAccountFingering(
		AccountID			BIGINT
		, FingeringCode		VARCHAR(1000)
        , MinStagingTransID		BIGINT
    );
    
    
     #SELECT 'DEBUG07a-Temp_Transaction', a.deviceID, a.* FROM Temp_Transaction a;  
    
    INSERT INTO FirstTransAccountFingering(AccountID, FingeringCode, MinStagingTransID)
    SELECT	ts.AccountID
			, ts.FingeringCode
            , MIN(StagingTransID)
    FROM		Temp_Transaction AS ts
    WHERE		ts.DeviceID is NULL
    GROUP BY	ts.AccountID, FingeringCode;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,18,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    # GET RECOVER DEVICE INFO
	DROP TEMPORARY TABLE IF EXISTS RecoverTransInfo;
    CREATE temporary table RecoverTransInfo(		
        MinStagingTransID		BIGINT
        , AccountID				BIGINT
		, DeviceID				BIGINT
        , IsMatchFingering		TINYINT(1)
        , MergeFingeringCode	VARCHAR(32)			
    );
    
    #
    INSERT INTO RecoverTransInfo(MinStagingTransID, AccountID, DeviceID, IsMatchFingering, MergeFingeringCode)
    SELECT 		fa.MinStagingTransID
				, fa.AccountID
                , ass.DeviceID
                , FPS_DC_ISLISTSMATCHBYITEM(';',fa.FingeringCode, dv.FingeringCode) AS IsMatchFingering
                , FPS_DC_MERGEIFDIFFERENCELISTS(';', fa.FingeringCode, dv.FingeringCode) AS MergeFingeringCode
    FROM 		FirstTransAccountFingering AS fa
    LEFT JOIN 	FPS_DataCenter.Association AS ass
				ON fa.AccountID = ass.AccountID
	LEFT JOIN	FPS_DataCenter.Device AS dv
				ON	ass.DeviceID = dv.DeviceID;
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,19,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
   # SELECT 'FirstTransAccountFingering',t.* FROM  FirstTransAccountFingering t;
    #    SELECT 'RecoverTransInfo',t.* FROM  RecoverTransInfo t;
    
    # INSERT FirstTransDeviceCode
        # GET RECOVER DEVICE INFO
	DROP TEMPORARY TABLE IF EXISTS FirstTransDeviceCode;
    CREATE temporary table FirstTransDeviceCode(		
        DeviceCode				VARCHAR(320)
        , MinStagingTransID		BIGINT
	);   
    
    INSERT INTO FirstTransDeviceCode(DeviceCode, MinStagingTransID)
    SELECT		ts.DeviceCode
				, MIN(rt.MinStagingTransID)
    FROM		RecoverTransInfo AS rt
    INNER JOIN	Temp_Transaction AS ts
				ON rt.MinStagingTransID = ts.StagingTransID
	WHERE		rt.IsMatchFingering = 0 AND rt.DeviceID IS NULL
    GROUP BY	DeviceCode;
   # SELECT 'DEBUG 09.1 FPS_DataCenter.Device',t.* FROM  FPS_DataCenter.Device t;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,20,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    #------New Device
    INSERT INTO FPS_DataCenter.Device(DeviceCode, FingeringCode, StagingTransID, UserAgentID, PluginID, FirstAccountID, CreatedDate, DeviceStatus)
    SELECT		ts.DeviceCode
				, ts.FingeringCode
                , ts.StagingTransID
                , ts.UserAgentID
                , ts.PluginID
                , ts.AccountID
                , ts.CreatedDate
                , DeviceStatusNew AS DeviceStatus		# New Device
    FROM		FirstTransDeviceCode as ft
    INNER JOIN	Temp_Transaction AS ts
				ON ft.MinStagingTransID = ts.StagingTransID;
                
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,21,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
   # SELECT 'DEBUG 09 FPS_DataCenter.Device';
    # Recover Device
	Update 		 FPS_DataCenter.Device dv
    INNER JOIN		RecoverTransInfo AS rt
					ON dv.DeviceID = rt.DeviceID
	INNER JOIN	Temp_Transaction AS ts
					ON rt.MinStagingTransID = ts.StagingTransID
	SET			 dv.DeviceCode = ts.DeviceCode
				AND dv.FingeringCode = rt.MergeFingeringCode
                AND	dv.UserAgentID = ts.UserAgentID
                AND dv.PluginID = ts.PluginID
                AND dv.DeviceStatus = DeviceStatusRecover			#Recover Status
	WHERE		 rt.IsMatchFingering = 1;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,22,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    
    UPDATE		Temp_Transaction AS ts
	INNER JOIN	FPS_DataCenter.Device AS dv
				on ts.DeviceCode = dv.DeviceCode
	SET			ts.DeviceID = dv.DeviceID;
    
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,23,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    #SELECT 'FPS_DataCenter.Device',t.* FROM  FPS_DataCenter.Device t;
    
    /*==================INSERT Transaction===========================*/
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, DeviceID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, PluginID, Flagged, ActionResultID, DeviceCode, FingeringCode)                
	SELECT 	DISTINCT	ts.StagingTransID
				, ts.SubscriberID
				, ts.SubscriberURLID
				, ts.UserAgentID
				, (SELECT DeviceID FROM FPS_DataCenter.Device AS dv
					WHERE ts.DeviceCode = dv.DeviceCode)
				, ts.LoginName
				, ts.AccountID            
				, ts.TransDate
				, ts.CreatedDate
				, ts.IP
				, ts.PluginID
				, ts.Flagged
				, ts.ActionResultID
				, ts.DeviceCode
                , ts.FingeringCode
	FROM		Temp_Transaction AS ts;
    /*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,24,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/
    #==========UPDATE: StagingRawTransaction.IsProcessed = 1================================================================================================================
	UPDATE 	FPS_RawTransaction.RawTransaction AS st
	INNER JOIN Temp_Transaction AS ts
				ON st.StagingTransID = ts.StagingTransID 
                AND st.IsProcessed = 0
	SET		st.IsProcessed = 1;    
	/*TraceTimePerformance: Start*/
	SET EndTime	= current_timestamp();
    INSERT INTO FPS_DataCenter.zzTracePerformance_01(SPName,Step,StartTime,EndTime,Duration)
    VALUES(SPName,25,StartTime, EndTime,SECOND(TIMEDIFF(EndTime,StartTime)));
	SET StartTime	= current_timestamp();
	/*TraceTimePerformance: END*/

END$$

