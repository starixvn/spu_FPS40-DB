DELIMITER $$
USE `FPS_DataCenter`$$

DROP FUNCTION IF EXISTS `DC_IsListsMatchByItem`$$


CREATE FUNCTION DC_IsListsMatchByItem (ip_seperator VARCHAR(5), ip_List01 NVARCHAR(5000), ip_List02 NVARCHAR(5000))

RETURNS TINYINT(1)

DETERMINISTIC

BEGIN
	DECLARE i 		INT;
	DECLARE str 	NVARCHAR(5000);
	DECLARE result 	TINYINT(1);
	
    DROP TEMPORARY TABLE IF EXISTS temp_Table01;
	DROP TEMPORARY TABLE IF EXISTS temp_Table02;
	
	CREATE TEMPORARY TABLE temp_Table01(
		item NVARCHAR(5000)
	);
	#----------------------------------------

	CREATE TEMPORARY TABLE temp_Table02(
		item VARCHAR(5000)
	);
 #------------------------------------------
	SET i = 0;
	SET ip_List01 = CONCAT(ip_List01,ip_seperator);
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = DC_SplitString(ip_List01,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
	
		INSERT INTO temp_Table01 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
 
 #-----------------------------------
	SET i = 0;
    SET ip_List02 = CONCAT(ip_List02,ip_seperator);
    
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = DC_SplitString(ip_List02,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
		
		INSERT INTO temp_Table02 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
    
	SET result = (SELECT COUNT(1)
					FROM (	SELECT 1
							FROM	temp_Table01 t1
							INNER JOIN	temp_Table02 t2
										ON t1.Item = t2.Item
							LIMIT 1) AS temp_Result);
	RETURN result;

END$$

DELIMITER ;

