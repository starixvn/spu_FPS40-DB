/*
	Created: 20190610@Casey.Huynh
	Task : Split String
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DELIMITER $$
USE `FPS_DataCenter`$$

CREATE DEFINER=`fps`@`%` FUNCTION `FPS_DC_SplitString`(
	ip_String 		VARCHAR(255) ,
	ip_seperator	VARCHAR(12) ,
	ip_position 	INT
) 
RETURNS VARCHAR(255) CHARSET UTF8

DETERMINISTIC

BEGIN

	RETURN REPLACE(
					SUBSTRING(SUBSTRING_INDEX(ip_String , ip_seperator , ip_position),CHAR_LENGTH(SUBSTRING_INDEX(ip_String , ip_seperator , ip_position - 1)) + 1)
                    , ip_seperator
                    , '');

END$$

DELIMITER ;

