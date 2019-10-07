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
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Transaction_Insert' ;
    DECLARE		vrStepID		INT;
	DECLARE 	vrNotes	 		VARCHAR(500);
	DECLARE 	vrStartTime		TIMESTAMP(4);
	DECLARE		vrEndTime 		TIMESTAMP(4);
	DECLARE		vrDuration 		BIGINT;	
    DECLARE		vrTotalRecord	INT;
    DECLARE		vrFromID		BIGINT;
    DECLARE		vrToID			BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Insert Transaction';		
    SET 	vrStepID = 1;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4);
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, FromID, ToID)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_FromStagingTransID, ip_ToStagingTransID);
	
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
    
	INSERT IGNORE  INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID, SubURLID, ActionResultID, UserAgentID, FingerprintCodeID, DeviceCode, DeviceCodeID, LoginName 
				,  TransDate, CreatedDate, IP, PluginID, Flagged, LoginNameWithPrefixID, TransStatus, InsertTime)                
	SELECT 		rt.StagingTransID
				, su.SubscriberID
				, CRC32(LOWER(rt.URL)) AS SubURLID		#CRC32(MD5(LOWER(rt.URL)))
                , CRC32(LOWER(rt.ActionResult)) ActionResultID
				, CRC32(LOWER(rt.UserAgent)) AS UserAgentID
                , CRC32(rt.FingerprintCode) AS FingerprintCodeID
                , rt.DeviceCode
                , CRC32(rt.DeviceCode) AS DeviceCodeID
				, rt.LoginName				            
				, rt.TransDate
				, rt.CreatedDate
				, rt.IP
				, rt.PluginID
				, 0 AS Flagged
                , CRC32(LOWER(CONCAT(su.SubscriberPrefix, rt.LoginName))) AS LoginNameWithPrefixID
                , rt.TransStatus
                , CURRENT_TIMESTAMP(4) 		AS InsertTime
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON	rt.SubscriberName = su.SubscriberName
	WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;	              
	#===============================================================================================================	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
	### PERFORMANCE
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
    
END$$
DELIMITER ;
