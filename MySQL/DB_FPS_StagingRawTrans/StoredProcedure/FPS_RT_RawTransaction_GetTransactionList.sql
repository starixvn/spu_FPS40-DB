/*
	Created: 20190610@Casey.Huynh
	Task : Get Transaction List has not transferred (processed) to FPS_DataCenter DB
	DB: FPS_RawTransaction(Staging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_RawTransaction$$

CREATE PROCEDURE FPS_RawTransaction.FPS_RT_RawTransaction_GetTransactionList(IN ip_IsProcessed TINYINT, IN ip_NoOfTickets INT)
BEGIN
  
    # RETURN Transaction List
    SELECT	st.StagingTransID	
			, st.LoginName
            , st.SubscriberName
			, st.TransDate
			, st.CreatedDate
            , st.DeviceCode
			, st.FingerprintCode
			, st.FingerprintMoreInfo
			, st.UserAgent
			, st.IP
			, st.PluginID			
			, st.URL
			, st.ActionResult
			
	FROM 	FPS_RawTransaction.RawTransaction AS st
	WHERE	st.IsProcessed = ip_IsProcessed
    LIMIT	ip_NoOfTickets;

END$$
DELIMITER ;
