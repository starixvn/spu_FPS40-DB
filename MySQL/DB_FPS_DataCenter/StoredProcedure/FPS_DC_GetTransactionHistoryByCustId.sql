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
    
    SELECT 	`TransDate` 		= t.TransDate
		,	`DeviceCode` 		= t.DeviceCode
        ,	`DeviceStatus` 		= d.DeviceStatus 
        ,	`RobotTracking`		= t.Flagged
        ,	`Action` 			= ar.ActionResultKey
        ,	`ActionResult` 		= ar.ActionResultKey
        ,	`DeviceType` 		= t.OS 
        ,	`Browser` 			= t.Browser
        ,	`Domain` 			= url.URL
        ,	`IP` 				= t.IP
        ,	`Country` 			= ipr.CountryName
        ,	`Region` 			= ipr.Region
        ,	`City` 				= ipr.City
        ,	`ServiceProvider` 	= ipr.ISPName
	FROM FPS_DataCenter.Transaction AS t
		INNER JOIN FPS_DataCenter.ActionResult AS ar ON t.ActionResultID = ar.ActionResultID
        INNER JOIN FPS_DataCenter.IPRangeLocation AS ipr ON t.IPRangeLocationID = ipr.IPRangeLocationID
        INNER JOIN FPS_DataCenter.SubscriberURL AS url ON t.SubURLID = url.SubscriberURLID
        INNER JOIN FPS_DataCenter.Device AS d ON t.DeviceID = d.DeviceID
	WHERE t.TransDate > @rptStartDate AND t.TransDate < @rptEndDate;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

