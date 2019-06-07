DELIMITER $$
USE `FPS_Admin`$$

CREATE DEFINER=`fps`@`%` PROCEDURE `RT_StagingRawTransaction_GetProcessedTransList`()
BEGIN
	
    DECLARE MaxStagingTransID BIGINT;
    
    # RETURN Transaction List
    SELECT	StagingTransID	
			, DeviceCode
			, LoginName
			, SubscriberName
			, TransDate
			, CreatedDate
			, IP
			, PluginID
			, DeviceStatus
			, URL
			, ActionResult
			, UserAgent
			, CapturedData
	FROM 	StagingRawTransaction AS st
	WHERE	st.IsProcessed = 0;

END $$
DELIMITER ;