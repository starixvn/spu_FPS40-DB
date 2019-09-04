/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Transaction$$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Transaction(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_Transaction' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    ### PERFORMANCE: END
	SET SESSION autocommit = 0;
	START  TRANSACTION;
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID, SubURLID, ActionResultID, UserAgentID, AccountID, DeviceID, DeviceCode, FingerprintCode, FingerprintMoreInfo, LoginName 
				,  TransDate, CreatedDate, IP, PluginID, Flagged)                
	SELECT 		rt.StagingTransID
				, su.SubscriberID
				, ur.SubscriberURLID
                , ar.ActionResultID
				, ua.UserAgentID
                , ac.AccountID
				, dc.DeviceID
                , rt.DeviceCode
                , rt.FingerprintCode
                , rt.FingerprintMoreInfo
				, rt.LoginName				            
				, rt.TransDate
				, rt.CreatedDate
				, rt.IP
				, rt.PluginID
				, 0 AS Flagged				
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
    INNER JOIN	FPS_DataCenter.SubscriberURL  AS ur
				ON 	su.SubscriberID = ur.SubscriberID
					AND rt.URL = ur.URL
	INNER JOIN	FPS_DataCenter.ActionResult AS ar
				ON rt.ActionResult = ar.ActionResultKey
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON MD5(rt.UserAgent) = ua.UserAgentCode
	LEFT JOIN	FPS_DataCenter.DeviceCode AS dc
				ON rt.DeviceCode = dc.DeviceCode
	INNER JOIN	FPS_DataCenter.Account AS ac USE INDEX (IX_Account_SubscriberID_FirstLoginName_UserName_Username2) 
				ON	su.SubscriberID = ac.SubscriberID
				AND	ac.UNUN2 LIKE CONCAT('%;',su.SubScriberPrefix,REPLACE(rt.LoginName,'_','\_'),';%')
	WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;
                
	#===============================================================================================================	
    UPDATE 	FPS_RawTransaction.RawTransaction AS rt
	SET		rt.IsProcessed = 1
    WHERE	rt.IsProcessed = 0
			AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;	
	COMMIT;
	SET SESSION autocommit = 1;
    	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 
            
END$$
DELIMITER ;
