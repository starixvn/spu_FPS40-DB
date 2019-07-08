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
	DECLARE RowIndex 		INT UNSIGNED DEFAULT 0;
	DECLARE RowCount 		INT UNSIGNED;
	DECLARE XpathRow 		VARCHAR(50);
    
    #=========================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
	
	CREATE TEMPORARY TABLE Temp_Transaction
    ( 
		 LoginName			VARCHAR(50) CHARACTER SET UTF8
		, SubscriberName	VARCHAR(30) 
		, TransDate			BIGINT 
		, CreatedDate		BIGINT        
		, DeviceCode		VARCHAR(32)
        , DeviceCodeStatus	TINYINT(1)
        , FingeringCode		VARCHAR(5000)
        , FingeringMoreInfo	VARCHAR(15000)	
		, IP				BIGINT
        , IPType			TINYINT(1)	
		, PluginID			BIGINT		
		, URL				VARCHAR(250)
		, ActionResult		VARCHAR(100)
		, UserAgent			VARCHAR(500)        
        , UserAgentCode		VARCHAR(50)
        , BrowserName		VARCHAR(100)
        , OSName			VARCHAR(100)
		, Flagged			INT
        , StagingTransID	BIGINT
        
        , SubscriberID		INT        
        , IsDeposit			INT
        , SubScriberPrefix	VARCHAR(30)
        , DeviceID			INT
        , AccountID			INT
	);
    
	   
	#========================================================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_NewUserAgent;
	
	CREATE TEMPORARY TABLE Temp_NewUserAgent
    ( 
		UserAgent		VARCHAR(500)
        , UserAgentCode	VARCHAR(32)
        , BrowserName		VARCHAR(100)
        , OSName			VARCHAR(100)
        , CreatedDate		BIGINT		COMMENT 'Date Only'
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
				, IP, IPType, PluginID, URL, ActionResult, UserAgent, UserAgentCode, BrowserName, OSName, Flagged)
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
                , EXTRACTVALUE(ip_TransXml,CONCAT(XpathRow,'/attribute::IPType'))
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
			, FPS_DataCenter.Account AS ac
	SET		ts.AccountID = ac.AccountID
    WHERE	( ts.LoginName 		= ac.FirstLoginName
				OR ts.LoginName = ac.UserName
				OR ts.LoginName = ac.Username2
				OR CONCAT(ts.SubScriberPrefix,ts.LoginName) = ac.Username2
			);			
 	                
	#========PROCESS DEVICEID==============================================
	#========================================================================================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_NotNullDeviceCodeTrans;
	
	CREATE TEMPORARY TABLE Temp_NotNullDeviceCodeTrans
    ( 	
        AccountID			BIGINT
        , FingeringCode		VARCHAR(5000)
        , DeviceCode		VARCHAR(50)
        , MinTransDate		BIGINT
        , DeviceID			BIGINT
	);    
	
    DROP TEMPORARY TABLE IF EXISTS Temp_RecoverDeviceInfo;
	
	CREATE TEMPORARY TABLE Temp_RecoverDeviceInfo
      ( 	
        AccountID				BIGINT
        , FingeringCode			VARCHAR(5000)
        , OldFingeringCode		VARCHAR(5000)
		, MergeFingeringCode	VARCHAR(5000)
        , DeviceCode			VARCHAR(32)
        , RecoverDeviceID		BIGINT
        , DeviceFingeringID		BIGINT
	);    
      
    INSERT INTO Temp_NotNullDeviceCodeTrans (AccountID, FingeringCode, DeviceCode, MinTransDate)
	SELECT DISTINCT	ts.AccountID
					, ts.FingeringCode
					, ts.DeviceCode
                    , MIN(ts.TransDate)
	FROM	Temp_Transaction AS ts
    WHERE	ts.DeviceCode IS NOT NULL
	GROUP BY	ts.AccountID
				, ts.FingeringCode
				, ts.DeviceCode;
	
	SELECT 'Temp_NotNullDeviceCodeTrans', ts.* FROM Temp_NotNullDeviceCodeTrans ts;
    
    INSERT INTO Temp_RecoverDeviceInfo (AccountID, FingeringCode, OldFingeringCode, MergeFingeringCode, DeviceCode, RecoverDeviceID, DeviceFingeringID)
    SELECT 	DISTINCT nd.AccountID
			, nd.FingeringCode
            , dd.FingeringCode AS OldFingeringCode
            , DC_MERGELISTS(',', nd.FingeringCode,dd.FingeringCode) AS MergeFingeringCode # return NULL if dd.FingeringCode not has new FGCode
            , nd.DeviceCode
            , dd.DeviceID
            , dd.DeviceFingeringID
    FROM		Temp_NotNullDeviceCodeTrans AS nd
    INNER JOIN	Association ass
				ON nd.AccountID = ass.AccountID
	INNER JOIN	DeviceFingering dd
				ON	dd.DeviceID = ass.DeviceID
					AND DC_ISLISTSMATCHBYITEM(',',nd.FingeringCode,dd.FingeringCode) = 1;
    
    UPDATE Temp_NotNullDeviceCodeTrans dc
    INNER JOIN Temp_RecoverDeviceInfo rd
				ON dc.DeviceCode = rd.DeviceCode
                AND dc.AccountID = rd.AccountID
    SET dc.DeviceID = rd.RecoverDeviceID;
    
    select  dc.DeviceCode
                    , MIN(dc.MinTransDate)
    FROM	Temp_NotNullDeviceCodeTrans AS dc
    LEFT JOIN Temp_RecoverDeviceInfo AS rd 
				ON dc.AccountID = rd.AccountID
				AND dc.DeviceCode = rd.DeviceCode
	WHERE		rd.DeviceCode IS NULL
    GROUP BY dc.DeviceCode;
    
    INSERT INTO Device (FirstDeviceCode, CreatedDate)
    SELECT dc.DeviceCode
                    , MIN(dc.MinTransDate)
    FROM	Temp_NotNullDeviceCodeTrans AS dc
    LEFT JOIN Temp_RecoverDeviceInfo AS rd 
				ON dc.AccountID = rd.AccountID
				AND dc.DeviceCode = rd.DeviceCode
	LEFT JOIN 	Device dv2
				ON dc.DeviceCode = dv2.FirstDeviceCode
	WHERE		rd.DeviceCode IS NULL
				AND dv2.FirstDeviceCode IS NULL
	GROUP BY dc.DeviceCode;
    
    select '222';
    
    UPDATE Device AS dd
    INNER JOIN Temp_NotNullDeviceCodeTrans AS dc
				ON dd.FirstDeviceCode = dc.DeviceCode
                AND dd.CreatedDate = dc.MinTransDate
	SET dd.FirstFingeringCode = dc.FingeringCode
		, dd.FristAccessAccountID = dc.AccountID;
    #==================Insert New DeviceCode of Device Recover===
                 
    INSERT INTO Device(DeviceID, DeviceCode, DeviceCodeStatus, CreatedDate)
    SELECT 		rd.DeviceID
                , 1 AS DeviceCodeStatus				#======Is recovered
                , MIN(nd.MinTransDate)
    FROM 		Temp_RecoverDeviceInfo AS rd
    INNER JOIN Temp_NotNullDeviceCodeTrans AS nd
				ON rd.DeviceCode = nd.DeviceCode
    LEFT JOIN	Device AS dv
				ON rd.DeviceCode = dv.DeviceCode
	WHERE		dv.DeviceCode IS NULL
    GROUP BY	rd.DeviceID, rd.DeviceCode;
   
    #==================================================================================================
    INSERT INTO DeviceCode(DeviceCode, DeviceID, DeviceCodeStatus, CreatedDate)
	SELECT 		nd.DeviceCode
                , nd.DeviceID
                , nd.MinTransDate
    FROM 		Temp_NotNullDeviceCodeTrans AS nd
    LEFT JOIN	Temp_RecoverDeviceInfo AS dc
				ON nd.DeviceCode = dc.DeviceCode
	WHERE		dc.DeviceCode IS NULL;
    
    UPDATE		Temp_Transaction AS ts
    INNER JOIN	Device AS dv
				ON ts.DeviceCode = dv.DeviceCode
	SET			ts.DeviceID = ts.DeviceID;
        
    #===============Update DeviceFingeringsFingering if MargeFingeringCode Is NOT NULL
    UPDATE DeviceFingering dd
	INNER JOIN Temp_RecoverDeviceInfo rd
				ON dd.DeviceFingeringID = rd.DeviceFingeringID
    SET		dd.FingeringCode = MergeFingeringCode
    WHERE rd.MergeFingeringCode IS NOT NULL;
    
    SELECT 'DeviceFingering', ts.* FROM DeviceFingering ts;
    
    #*****************INSERT INTO DeviceFingering*******************
    INSERT INTO DeviceFingering(DeviceID, CreatedDate, FingeringCode, FingeringMoreInfo, UserAgentID, PlugingID)
    SELECT	DISTINCT ts.FingeringCode
    FROM		Temp_Transaction AS ts
    LEFT JOIN	DeviceFingering AS dd
				ON DC_ISLISTSMATCHBYITEM(',',ts.FingeringCode,dd.FingeringCode) = 1
	INNER JOIN	Device AS dv
				ON ts.DeviceID = dv.DeviceID
	WHERE		dd.DeviceFingeringID IS NULL
	;
    
	#========INSERT: Associations--==========================================================================================    
   INSERT INTO FPS_DataCenter.Association(DeviceID, AccountID, SubscriberID, CreatedDate, SyncGraphDB)
    SELECT		ts.DeviceID
				, ts.AccountID
				, ts.SubscriberID
                , MIN(ts.TransDate)
                , 0 AS SyncGraphDB
    FROM		Temp_Transaction AS ts
	INNER JOIN	Device AS dv
				ON dv.DeviceCode = ts.DeviceCode
    LEFT JOIN	FPS_DataCenter.Association AS ac
				ON	(ts.SubscriberID	= ac.SubscriberID
                AND	ts.AccountID 		= ac.AccountID
                AND	ts.DeviceID			= ac.DeviceID)
	WHERE		ac.AccountID IS NULL
    GROUP BY	ts.DeviceID
				, ts.AccountID
				, ts.SubscriberID;
                
    SELECT 'Association', ts.* FROM Association ts;
    #========================================================================================================    
    INSERT INTO FPS_DataCenter.ActionResult(ActionResultKey, Status, CreatedDate)
	SELECT 		ts.ActionResult              
                , 2 AS Status
                , MIN(ts.TransDate) AS CreatedDate
	FROM		Temp_Transaction AS ts	
	LEFT JOIN	FPS_DataCenter.ActionResult AS ar
				ON ts.ActionResult = ar.ActionResultKey
	WHERE		ar.ActionResultKey IS NULL
    GROUP BY	ts.ActionResult;   
    
    #========INSERT: Transaction===============================================================================================
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID,  SubURLID, UserAgentID, DeviceID, LoginName, AccountID
				,  TransDate, CreatedDate, IP, IPRangeLocationID, PluginID, DeviceStatus, Flagged,ActionResultID)                
	SELECT 		ts.StagingTransID
				, su.SubscriberID
				, su.SubscriberURLID
				, ua.UserAgentID
				, dv.DeviceID
				, ts.LoginName
				, ac.AccountID            
				, ts.TransDate
				, ts.TransDate
				, ts.IP
                , (SELECT IPRangeLocationID FROM IPRangeLocation AS ir WHERE (ts.IP BETWEEN ir.FromIP AND ir.ToIP) AND ir.Status = 1 AND ir.IPType = ts.IPType) AS IPRangeLocationID #===Get IPRangeID which Active(status=1)
				, ts.PluginID
				, ts.DeviceCodeStatus
				, ts.Flagged
				, ar.ActionResultID              
	FROM		Temp_Transaction AS ts
    INNER JOIN	FPS_DataCenter.SubscriberURL AS su
				ON ts.URL = su.URL AND ts.SubscriberID = su.SubscriberID
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
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
	UPDATE 	FPS_StagingRawTrans.RawTransaction AS st
				, Temp_Transaction AS ts
	SET		st.IsProcessed = 1
	WHERE	st.StagingTransID = ts.StagingTransID
			AND st.IsProcessed = 0;	
        
          
END$$
DELIMITER ;


