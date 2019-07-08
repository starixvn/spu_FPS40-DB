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

CREATE PROCEDURE FPS_DataCenter.DC_IPRangeLocation_UpdateByXML(IN ip_UpdatedDate DATETIME, IN ip_IPRangeLocationXml LONGTEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
	DECLARE UpdatedDate BIGINT;
    
    SET UpdatedDate = UNIX_TIMESTAMP(ip_UpdatedDate);
        
    DROP TABLE IF EXISTS Temp_IPRangeLocation;    
	CREATE TEMPORARY TABLE Temp_IPRangeLocation (
		IPRangeLocationCode		VARCHAR(64)			NOT NULL
        , IPType				TINYINT				NOT NULL	COMMENT '0: IPV4, 1: IPV6'
		, FromIP				DECIMAL(39,0)		NOT NULL
        , ToIP					DECIMAL(39,0)		NOT NULL
        , CountryCode			VARCHAR(10)			NULL
        , CountryName			VARCHAR(80)			NULL
        , Region				VARCHAR(128)		NULL
        , City					VARCHAR(50)			NULL
        , ISPName				VARCHAR(256)		NULL
        , Status				TINYINT(1)        	COMMENT '0: Inactive; 1: Active'
        , CreatedDate			BIGINT
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
			, IPType
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
		 EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::IPRangeLocationCode'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::IPType'))
         , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::FromIP'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::ToIP'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::CountryCode'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::CountryName'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::Region'))
         , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::City'))
		 , EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::ISPName'))
		);
		
	END WHILE;
	# Remove IPRangeLocation that not change from temp data
    DELETE 	tip
    FROM 		Temp_IPRangeLocation tip
	INNER JOIN	IPRangeLocation ip
				ON tip.IPRangeLocationCode = ip.IPRangeLocationCode;
        
    # Insert New IPRangeLocation
    INSERT INTO FPS_RawTrans.IPRangeLocation
	(		
			IPRangeLocationCode
			, IPType
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
			, tip.IPType
			, tip.FromIP
            , tip.ToIP
            , tip.CountryCode
            , tip.CountryName
            , tip.Region
            , tip.City
            , tip.ISPName
			, 1 AS Status 
            , UpdatedDate AS CreatedDate
	FROM	Temp_IPRangeLocation tip;

	# Update Status=0 (inactive) for IPRange Has Changed
    UPDATE  	IPRangeLocation
	INNER JOIN	Temp_IPRangeLocation tip
				ON 	ip.IPType 	= tip.IPType
                AND ip.FromIP 	= tip.FromIP
                AND ip.ToIP		= tip.ToIP
	SET			Status = 0	
	WHERE		ip.CreatedDate < UpdatedDate
				AND ip.Status = 1;    
    
END$$
DELIMITER ;
