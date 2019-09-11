DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Transaction_Insert$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Transaction_Insert(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
/*
	Created: 20190730@Casey.Huynh
	Task : Insert Transaction
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_DataCenter_Process_Transaction' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	INT ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    
    ### PERFORMANCE: END
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	INSERT IGNORE INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID, SubURLID, ActionResultCode, UserAgentCode, DeviceCode, FingerprintCode, FingerprintMoreInfo, LoginName 
				,  TransDate, CreatedDate, IP, PluginID, Flagged, LoginNameWithPrefixID, DeviceID)                
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
                , (CASE WHEN DeviceCode = '' THEN -1 ELSE NULL END) AS DeviceID
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON	rt.SubscriberName = su.SubscriberName
	WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;
	              
	#===============================================================================================================	
	 
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;          
END$$
DELIMITER ;
