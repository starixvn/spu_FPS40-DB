/*
	Created: 20190610@Casey.Huynh
	Task : Merge List A and List B. 
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
USE `FPS_DataCenter`$$

DROP FUNCTION IF EXISTS `FPS_DC_MergeLists`$$


CREATE FUNCTION FPS_DC_MergeLists (ip_seperator VARCHAR(5), ip_List01 NVARCHAR(5000), ip_List02 NVARCHAR(5000))

RETURNS NVARCHAR(5000)

DETERMINISTIC

BEGIN
	DECLARE i 		INT;
	DECLARE str 	NVARCHAR(5000);
	DECLARE result 	NVARCHAR(5000);
	
    DROP TEMPORARY TABLE IF EXISTS temp_Table01;
	DROP TEMPORARY TABLE IF EXISTS temp_Table02;
	
	CREATE TEMPORARY TABLE temp_Table01(
		item NVARCHAR(500)
	);
	#----------------------------------------

	CREATE TEMPORARY TABLE temp_Table02(
		item VARCHAR(5000)
	);
 #------------------------------------------
	IF ip_List01 IS NULL THEN 
		SET ip_List01 = '';
    END IF;
	
	SET i = 0;
    
	SET ip_List01 = CONCAT(ip_List01,ip_seperator);
    
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = FPS_DC_SPLITSTRING(ip_List01,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
	
		INSERT INTO temp_Table01 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
 
 #-----------------------------------
	IF ip_List02 IS NULL THEN 
		SET ip_List02 = '';
    END IF;
	SET i = 0;
    SET ip_List02 = CONCAT(ip_List02,ip_seperator);
    
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = FPS_DC_SPLITSTRING(ip_List02,ip_seperator,i);
		IF str = '' THEN
		LEAVE SIMPLE_LOOP;
		END IF;

		#Do Inserts into temp table here with str going into the row
		
		INSERT INTO temp_Table02 VALUES (str);
 
	END LOOP SIMPLE_LOOP;
    
	SET result = REPLACE((	SELECT GROUP_CONCAT(t.Item ) AS Item
					FROM (SELECT 	t1.Item AS Item
							FROM	temp_Table01 t1
                            UNION DISTINCT
                            SELECT	t2.Item
                            FROM	temp_Table02 t2
                            ) AS t
					), ',',ip_seperator);
	RETURN result;

END$$

DELIMITER ;

