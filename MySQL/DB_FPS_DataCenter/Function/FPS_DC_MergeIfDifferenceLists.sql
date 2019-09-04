/*
	Created: 20190610@Casey.Huynh
	Task : Merge List A and List B. Return Merge List if A difference B else return NULL
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DELIMITER $$
USE `FPS_DataCenter`$$
DROP FUNCTION IF EXISTS FPS_DC_MergeIfDifferenceLists$$
CREATE DEFINER=`fps`@`%` FUNCTION `FPS_DC_MergeIfDifferenceLists`(ip_seperator VARCHAR(5), ip_List01 VARCHAR(5000), ip_List02 VARCHAR(5000)) RETURNS VARCHAR(5000)
    DETERMINISTIC
BEGIN
	DECLARE i 		INT;
	DECLARE str 	VARCHAR(5000);
	DECLARE result 	VARCHAR(5000) DEFAULT NULL;
	DECLARE	CountTable01 INT;
    DECLARE CountTableMerge INT;
      
    DROP temporary TABLE if exists temp_Table01;
	CREATE TEMPORARY TABLE temp_Table01(
		item VARCHAR(5000)
	);
    
	#----------------------------------------
	DROP temporary TABLE if exists temp_Table02;
	CREATE TEMPORARY TABLE temp_Table02(
		item VARCHAR(5000)
	);
    
    DROP temporary TABLE if exists temp_TableMerge;
    CREATE TEMPORARY TABLE temp_TableMerge(
		item VARCHAR(5000)
	);
 #------------------------------------------
	SET i = 0;
    IF ip_List01 IS NULL THEN 
		SET ip_List01 = '';
    END IF;
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
	SET i = 0;
    IF ip_List02 IS NULL THEN 
		SET ip_List02 = '';
    END IF;
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
    
    INSERT INTO temp_TableMerge(Item)
    SELECT 	t1.Item
	FROM	temp_Table01 t1
	UNION DISTINCT
	SELECT	t2.Item
	FROM	temp_Table02 t2;
    
    SET CountTable01 = (SELECT COUNT(1) FROM temp_Table01);
    SET CountTableMerge = (SELECT COUNT(1) FROM temp_TableMerge);
    
    IF (CountTable01 != CountTableMerge) THEN
    BEGIN    
		SET result =  REPLACE((	SELECT GROUP_CONCAT(m.Item)
						FROM temp_TableMerge m
						), ',',ip_seperator);
	END;
    END IF;
	RETURN result;

END$$

DELIMITER ;

