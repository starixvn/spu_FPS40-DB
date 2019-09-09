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
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID, SubURLID, ActionResultCode, UserAgentCode, DeviceCode, FingerprintCode, FingerprintMoreInfo, LoginName 
				,  TransDate, CreatedDate, IP, PluginID, Flagged, LoginNameWithPrefixID)                
	SELECT 		rt.StagingTransID
				, su.SubscriberID
				, MD5(rt.URL)
                , MD5(rt.ActionResult)
				, MD5(rt.UserAgent)
                , rt.DeviceCode
                , rt.FingerprintCode
                , rt.FingerprintMoreInfo
				, rt.LoginName				            
				, rt.TransDate
				, rt.CreatedDate
				, rt.IP
				, rt.PluginID
				, 0 AS Flagged
                , CRC32(LOWER(CONCAT(su.SubscriberPrefix, rt.LoginName))) AS LoginNameWithPrefixID
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON	rt.SubscriberName = su.SubscriberName
	WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
	ON DUPLICATE KEY UPDATE rt.StagingTransID = rt.StagingTransID;                
	#===============================================================================================================	
	 
	### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;          
END$$
DELIMITER ;
