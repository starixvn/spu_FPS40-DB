/*
	Created: 20190610@Casey.Huynh
	Task : Update IP Range by XML file
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
USE FPS_DataCenter$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_IPRangeLocation_UpdateByXML(IN ip_UpdatedDate DATETIME, IN ip_IPRangeLocationXml LONGTEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);

 # exmp ip_UpdatedDate= '2019-07-15 00:00:00'
        
    DROP TABLE IF EXISTS Temp_IPRangeLocation;    
	CREATE TEMPORARY TABLE Temp_IPRangeLocation (
		IPRangeLocationCode		VARCHAR(64)			NOT NULL
		, FromIP				DECIMAL(39,0)		NOT NULL
        , ToIP					DECIMAL(39,0)		NOT NULL
        , CountryCode			VARCHAR(10)			NULL
        , CountryName			VARCHAR(80)			NULL
        , Region				VARCHAR(128)		NULL
        , City					VARCHAR(50)			NULL
        , ISPName				VARCHAR(256)		NULL
     );
    
	SET RowCount = EXTRACTVALUE(ip_IPRangeLocationXml,'count(//root/ip)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/ip['
			,   RowIndex
			,   ']');
            
		INSERT INTO Temp_IPRangeLocation
		(	  IPRangeLocationCode
			, FromIP
            , ToIP
            , CountryCode
            , CountryName
            , Region
            , City
            , ISPName
		)
		VALUES
		( 
		 EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::IPRangeLocationCode'))
         , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::FromIP'))
		 , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::ToIP'))
		 , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::CountryCode'))
		 , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::CountryName'))
		 , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::Region'))
         , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::City'))
		 , EXTRACTVALUE(ip_IPRangeLocationXml,CONCAT(XpathRow,'/attribute::ISPName'))
		);
		
	END WHILE;
   
	# Remove IPRangeLocation that not change from temp data
    DELETE 	tip
    FROM 		Temp_IPRangeLocation tip
	INNER JOIN	IPRangeLocation ip
				ON tip.IPRangeLocationCode = ip.IPRangeLocationCode;
	# 
	UPDATE  	IPRangeLocation ip
	INNER JOIN	Temp_IPRangeLocation tip
				ON ip.FromIP 	= tip.FromIP
                AND ip.ToIP		= tip.ToIP
	SET			ip.Status = 0
	WHERE  		ip.Status = 1; 
    
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
	FROM	Temp_IPRangeLocation tip;


END$$
DELIMITER ;
