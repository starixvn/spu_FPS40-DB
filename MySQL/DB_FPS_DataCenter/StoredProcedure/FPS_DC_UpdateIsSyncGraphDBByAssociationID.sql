DELIMITER $$
DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_UpdateIsSyncGraphDBByAssociationID $$
CREATE PROCEDURE FPS_DataCenter.FPS_DC_UpdateIsSyncGraphDBByAssociationID(IN ip_AssociationJSON JSON)
BEGIN
/*
	Created:	20190610@Casey.Huynh
	Task :		Get Association list by SyncGraphDB status;
	DB:			FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by): 
*/

   
    DROP TEMPORARY TABLE IF EXISTS Temp_Association;
    
	CREATE TEMPORARY TABLE Temp_Association (
	  AssociationID BIGINT
      , SyncGraphDB TINYINT
	);
    
    # ======================================
	   
    INSERT INTO Temp_Association(AssociationID, SyncGraphDB)
	SELECT 	AssociationID
            , SyncGraphDB            
	FROM
	JSON_TABLE(
				ip_AssociationJSON
				, "$[*]" COLUMNS(
								AssociationID BIGINT PATH "$.AssociationId"	
								, SyncGraphDB TINYINT PATH "$.SyncGraphDB"	
								)
				) AS  tmpUA;
                
    # =========================================
    
    
    UPDATE 		FPS_DataCenter.Association ass
    INNER JOIN	Temp_Association tas
				ON ass.AssociationID = tas.AssociationID
    SET			ass.SyncGraphDB = tas.SyncGraphDB;    
    
END$$
DELIMITER ;
