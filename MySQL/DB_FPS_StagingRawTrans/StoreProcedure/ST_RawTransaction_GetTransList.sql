/*
	Created: 20190610@Casey.Huynh
	Task : Get Transaction List has not transferred (processed) to FPS_DataCenter DB
	DB: FPS_StagingRawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
CREATE PROCEDURE FPS_StagingRawTrans.ST_RawTransaction_GetTransactionList(IN ip_IsProcessed TINYINT(1))
BEGIN
  
    # RETURN Transaction List
    SELECT	st.StagingTransID	
			, st.st.DeviceCode
			, st.st.LoginName
			, st.SubscriberName
			, st.TransDate
			, st.CreatedDate
			, st.IP
			, st.PluginID
			, st.DeviceStatus
			, st.URL
			, st.ActionResult
			, st.UserAgent
			, st.CapturedData
	FROM 	FPS_StagingRawTrans.RawTransaction AS st
	WHERE	st.IsProcessed = ip_IsProcessed;

END$$
DELIMITER ;
