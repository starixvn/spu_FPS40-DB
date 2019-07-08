DELIMITER $$
USE `FPS_DataCenter`$$

DROP FUNCTION IF EXISTS `DC_SplitString`$$

CREATE DEFINER=`fps`@`%` FUNCTION `DC_SplitString`(
	str VARCHAR(255) ,
	delim VARCHAR(12) ,
	pos INT
) 
RETURNS VARCHAR(255) CHARSET UTF8

DETERMINISTIC

BEGIN

	RETURN REPLACE(
					SUBSTRING(SUBSTRING_INDEX(str , delim , pos),CHAR_LENGTH(SUBSTRING_INDEX(str , delim , pos - 1)) + 1)
                    , delim
                    , '');

END$$

DELIMITER ;

