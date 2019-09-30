DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_UpdateIPRangeLocation $$

CREATE DEFINER=`fps`@`%` PROCEDURE `FPS_DC_UpdateIPRangeLocation`(IN ip_UpdatedDate DATETIME)
BEGIN
	/*
		Created: 20190730@Terry.Nguyen
		Task :	Insert Ip Range
		DB:		FPS_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/
    
	SELECT Min(tip.FromIP) , Max(tip.FromIP) INTO @minFromIp, @maxFromIp FROM FPS_DataCenter.IPRangeLocation_Initial AS tip;	

	DELETE tip
    FROM 		FPS_DataCenter.IPRangeLocation_Initial tip
	INNER JOIN	(SELECT IPRangeLocationCode FROM FPS_DataCenter.IPRangeLocation ip WHERE ip.FromIp Between @minFromIp and @maxFromIp) ip
				ON tip.IPRangeLocationCode = ip.IPRangeLocationCode;                
	
	# Insert New IPRangeLocation
    INSERT INTO FPS_DataCenter.IPRangeLocation
	(		
			IPRangeLocationCode
			, FromIP
            , ToIP
            , CountryCode
            , CountryName
            , Region
            , City
            , ISPName
            , Status
            , CreatedDate
	)
	SELECT	
			tip.IPRangeLocationCode
			, tip.FromIP
            , tip.ToIP
            , tip.CountryCode
            , tip.CountryName
            , tip.Region
            , tip.City
            , tip.ISPName
			, 1 AS Status 
            , ip_UpdatedDate AS CreatedDate
	FROM	FPS_DataCenter.IPRangeLocation_Initial tip
    ON DUPLICATE KEY UPDATE 
		IPRangeLocationCode = tip.IPRangeLocationCode		
		, CountryCode= tip.CountryCode
		, CountryName= tip.CountryName
		, Region= tip.Region
		, City= tip.City
		, ISPName= tip.ISPName           
		, CreatedDate = ip_UpdatedDate;

	TRUNCATE TABLE FPS_DataCenter.IPRangeLocation_Initial;
END