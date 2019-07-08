USE `FPS_DataCenter`;
DROP FUNCTION IF EXISTS `DC_MergeIfDifferenceLists`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE DEFINER=`fps`@`%` FUNCTION `DC_MergeIfDifferenceLists`(ip_seperator VARCHAR(5), ip_List01 NVARCHAR(5000), ip_List02 NVARCHAR(5000)) RETURNS VARCHAR(5000) CHARSET UTF8
    DETERMINISTIC
BEGIN
	DECLARE i 		INT;
	DECLARE str 	NVARCHAR(5000);
	DECLARE result 	NVARCHAR(5000) DEFAULT NULL;
	DECLARE	CountTable01 INT;
    DECLARE CountTableMerge INT;
    
    
    DROP TEMPORARY TABLE IF EXISTS temp_Table01;
	DROP TEMPORARY TABLE IF EXISTS temp_Table02;
	DROP TEMPORARY TABLE IF EXISTS temp_TableMerge;
    
	CREATE TEMPORARY TABLE temp_Table01(
		item NVARCHAR(5000)
	);
	#----------------------------------------

	CREATE TEMPORARY TABLE temp_Table02(
		item VARCHAR(5000)
	);
    
    CREATE TEMPORARY TABLE temp_TableMerge(
		item NVARCHAR(5000)
	);
 #------------------------------------------
	SET i = 0;
	SET ip_List01 = CONCAT(ip_List01,ip_seperator);
	SIMPLE_LOOP: LOOP

		SET i = i+1;

		-- Split based on " & "
		SET str = DC_SPLITSTRING(ip_List01,ip_seperator,i);
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
		SET str = DC_SPLITSTRING(ip_List02,ip_seperator,i);
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
		SET result = (	SELECT GROUP_CONCAT(m.Item)
						FROM temp_TableMerge m
						);
	END;
    END IF;
	RETURN result;

END$$

DELIMITER ;

