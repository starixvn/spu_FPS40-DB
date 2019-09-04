DELIMITER $$
USE FPS_DataCenter$$
DROP PROCEDURE IF EXISTS FPS_DC_GetLocationInfobyIP$$

CREATE PROCEDURE FPS_DC_GetLocationInfobyIP (IN ip_IPRangeLocationID BIGINT)
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
    WHERE ipr.IPRangeLocationID = ip_IPRangeLocationID
		AND ipr.Status = 1;
	
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;

