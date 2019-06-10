/*
	Created: 20190610@Casey.Huynh
	Task : Get Transaction List has not transferred (processed) to FPS_DataCenter DB
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DROP PROCEDURE IF EXISTS FPS_RawTrans.RT_StagingRawTransaction_GetProcessedTransList;

DELIMITER $$
USE FPS_RawTrans$$

CREATE PROCEDURE FPS_RawTrans.RT_StagingRawTransaction_GetProcessedTransList()
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