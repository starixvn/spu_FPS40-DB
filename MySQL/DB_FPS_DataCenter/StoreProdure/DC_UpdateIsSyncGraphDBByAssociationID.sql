DELIMITER $$
CREATE DEFINER=`fps`@`%` PROCEDURE `DC_UpdateIsSyncGraphDBByAssociationID`(IN ip_AssociationXML LONGTEXT)
BEGIN

	DECLARE RowIndex INT UNSIGNED DEFAULT 0;
	DECLARE RowCount INT UNSIGNED;
	DECLARE XpathRow VARCHAR(255);
    
    DROP TABLE IF EXISTS Temp_Association;
    
	CREATE TEMPORARY TABLE Temp_Association (
	  AssociationID BIGINT
      , SyncGraphDB TINYINT(DC_UpdateIsSyncGraphDBByAssociationID1)
	);
    
	SET RowCount = EXTRACTVALUE(ip_RawTransXml,'count(//root/association)');     
    
	WHILE RowIndex < RowCount DO
		SET RowIndex := RowIndex + 1;
		SET XpathRow = CONCAT(
				'//root/association['
			,   RowIndex
			,   ']');
            
		INSERT INTO Temp_Association
		(	
			AssociationID
            , SyncGraphDB
		)
		VALUES
		( 
			EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::AssociationID'))
			, EXTRACTVALUE(ip_RawTransXml,CONCAT(XpathRow,'/attribute::SyncGraphDB'))
		);
		
	END WHILE;
    
    UPDATE 		FPS_DataCenter.Association ass
    INNER JOIN	Temp_Association tas
				ON ass.AssociationID = tas.AssociationID
    SET			ass.SyncGraphDB = tas.SyncGraphDB;    
    
END$$
DELIMITER ;
