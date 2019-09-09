DELIMITER $$
USE FPSA_DataCenter$$
DROP PROCEDURE IF EXISTS FPSA_DC_CheckOSExist $$

CREATE PROCEDURE FPSA_DC_CheckOSExist(IN ip_OSJson JSON)
BEGIN
	/*
		Created:	20190815@Terry.Nguyen
		Task :		Check accounts if they are existed in OS table
		DB:			FPSA_DataCenter
		Original:

		Revisions:
		Param's Explanation (filtered by):
	*/    
    
    DROP TEMPORARY TABLE IF EXISTS temp_OS;    
	CREATE TEMPORARY TABLE temp_OS (
		 UserAgentCode VARCHAR(32)
         , OSID INT
         , OSName VARCHAR(100)
         , IsExisting INT
	);
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    INSERT INTO temp_OS
		(	
			 UserAgentCode
			, OSID
			, OSName
            , IsExisting
		)
	 SELECT tmpOS.UserAgentCode
			, 0 AS OSID
			, tmpOS.OSName
			, 0  FROM JSON_TABLE(
									ip_OSJson
                                    , "$[*]" COLUMNS(	UserAgentCode VARCHAR(32) PATH "$.UserAgentCode"         
														, OSName VARCHAR(100) PATH "$.OSName"  
													)
								 ) AS tmpOS;
		
   
	UPDATE		temp_OS AS tmp
	INNER JOIN	FPSA_DataCenter.OS AS br 
				ON tmp.OSName = br.OSName
	SET			tmp.OSID = br.OSID
				, tmp.OSName = br.OSName
				, tmp.IsExisting = 1;
   
   SELECT 		UserAgentCode
				, OSID
				, OSName
				, IsExisting 
	FROM		temp_OS;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
END$$

DELIMITER ;