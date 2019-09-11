DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_GetLocationInfobyIP$$

CREATE PROCEDURE FPS_DC_GetLocationInfobyIP (IN ip_IP DECIMAL(50,0))
BEGIN
	/*
		Created: 20190904@Long.Luu
		Task : Get Location Information from IP
		DB: FPS_DataCenter
		Original:

		Revisions:
		
		Param's Explanation (filtered by):
	*/
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
            
    SELECT 	ipr.CountryName
		,	ipr.Region
        ,	ipr.City
        ,	ipr.ISPName
    FROM FPS_DataCenter.IPRangeLocation AS ipr
    WHERE ip_IP BETWEEN ipr.FromIP AND ipr.ToIP
		AND ipr.Status = 1;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

