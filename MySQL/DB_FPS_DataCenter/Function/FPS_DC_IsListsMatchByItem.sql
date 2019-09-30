
DELIMITER $$

USE `FPS_DataCenter`$$
DROP FUNCTION IF EXISTS FPS_DC_IsListsMatchByItem$$
CREATE FUNCTION FPS_DC_IsListsMatchByItem (ip_seperator VARCHAR(5), ip_List01 VARCHAR(5000), ip_List02 VARCHAR(5000))

RETURNS TINYINT

DETERMINISTIC

BEGIN
/*
	Created: 20190610@Casey.Huynh
	Task : Check 2 Lists are match if have any the same item. Return 1 if match else return 0
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

	DECLARE i 		INT;
	DECLARE str 	VARCHAR(5000);
	DECLARE result 	TINYINT DEFAULT 0;
    
    
	IF(ip_List01 = '' OR ISNULL(ip_List01)= 1 OR ip_List02 = '' OR ISNULL(ip_List02)= 1 ) THEN
		
		Return result;
		
	END IF;
	DROP TEMPORARY TABLE IF EXISTS temp_MatchList01;
	DROP TEMPORARY TABLE IF EXISTS temp_MatchList02;
	
	CREATE TEMPORARY TABLE temp_MatchList01(
		item VARCHAR(5000)
	)ENGINE=MEMORY;
	#----------------------------------------

	CREATE TEMPORARY TABLE temp_MatchList02(
		item VARCHAR(5000)
	)ENGINE=MEMORY;
 #------------------------------------------
 
	SET i = 0;
	SET ip_List01 = CONCAT(ip_List01,ip_seperator);
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = FPS_DC_SplitString(ip_List01,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
	
		INSERT INTO temp_MatchList01 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
 
 #-----------------------------------
	SET i = 0;
    SET ip_List02 = CONCAT(ip_List02,ip_seperator);
    
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = FPS_DC_SplitString(ip_List02,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
		
		INSERT INTO temp_MatchList02 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
    
	SET result = (SELECT COUNT(1)
					FROM (	SELECT 1
							FROM	temp_MatchList01 t1
							INNER JOIN	temp_MatchList02 t2
										ON t1.Item = t2.Item
							LIMIT 1) AS temp_Result);

	RETURN result;
	
    DROP TEMPORARY TABLE IF EXISTS temp_MatchList01;
	DROP TEMPORARY TABLE IF EXISTS temp_MatchList02;
END$$

DELIMITER ;

