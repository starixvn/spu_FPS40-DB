DELIMITER $$
USE FPS_DataCenter $$
DROP PROCEDURE IF EXISTS FPS_DC_GetTransactionHistoryByCustId $$

CREATE PROCEDURE FPS_DC_GetTransactionHistoryByCustId (IN ip_accountId INT, IN ip_historyRange SMALLINT)
BEGIN
	/*
		Created:	20190812@Long.Luu
		Task :		Get Transaction History by CustId
		DB:			FPS_DataCenter
		Original:

		Revisions:
        
		Param's Explanation (filtered by):
			-	ip_historyRange: 1 - last 24 hours; 7 - last 7 days; 30 - last 30 days; 180 - last 180 days
	*/
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
    SET @rptEndDate = CURRENT_TIMESTAMP();
    SET @rptStartDate = DATE_ADD(@rptEndDate, INTERVAL -1 DAY);
    
    IF ip_historyRange <> 1 THEN
		SET @rptStartDate = DATE_ADD(@rptEndDate, INTERVAL -(ip_historyRange) DAY);
    END IF;
    
    SELECT 	t.TransDate AS `TransDate`
		,	t.DeviceCode AS `DeviceCode`
        ,	d.DeviceStatus AS `DeviceStatus`
        ,	ar.ActionResultKey AS `ActionResult` 
        ,	ua.OS AS `DeviceType` 	
        ,	ua.Browser AS `Browser`
        ,	url.URL AS `Domain`
        ,	t.IP AS `IP`
	FROM FPS_DataCenter.Transaction AS t
		INNER JOIN FPS_DataCenter.ActionResult AS ar ON t.ActionResultID = ar.ActionResultID
        INNER JOIN FPS_DataCenter.SubscriberURL AS url ON t.SubURLID = url.SubscriberURLID
        INNER JOIN FPS_DataCenter.Device AS d ON t.DeviceID = d.DeviceID
        INNER JOIN FPS_DataCenter.UserAgent AS ua ON ua.UserAgentID = t.UserAgentID
	WHERE t.AccountID = ip_accountId
		AND t.TransDate > @rptStartDate AND t.TransDate < @rptEndDate
	ORDER BY t.TransDate DESC;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

