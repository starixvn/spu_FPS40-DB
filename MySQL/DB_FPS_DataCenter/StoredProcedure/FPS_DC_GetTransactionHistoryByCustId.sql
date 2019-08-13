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
		,	 t.DeviceCode AS `DeviceCode`
        ,	 'long' AS `RobotTracking`
        ,	 ar.ActionResultKey AS `Action`
        ,	 'long' AS `ActionResult`
        ,	 'long' AS `DeviceType`
        ,	 'long' AS `Browser`
        ,	 'long' AS `Domain`
        ,	 'long' AS `IP`
        ,	 'long' AS `Country`
        ,	 'long' AS `Region`
        ,	 'long' AS `City`
        ,	 'long' AS `ServiceProvider`
	FROM FPS_DataCenter.Transaction AS t
		INNER JOIN FPS_DataCenter.ActionResult AS ar ON t.ActionResultID = ar.ActionResultID
	WHERE t.TransDate > @rptStartDate AND t.TransDate < @rptEndDate;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

