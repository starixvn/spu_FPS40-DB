/*
	Created: 20190620@Harvey
	Task : Get evidence for customer
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

USE `FPS_DataCenter`;
DROP PROCEDURE IF EXISTS `FPS_DC_GetEvidencesByCustIds`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_GetEvidencesByCustIds` (in custIds LONGTEXT, in evidences LONGTEXT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS tmp_CustId;
	CREATE TEMPORARY TABLE tmp_CustId( custId INT );
	SET @sql = CONCAT("INSERT INTO tmp_CustId (custId) VALUES ('", REPLACE(custIds, ",", "'),('"),"');");
	PREPARE stmt1 from @sql;
	EXECUTE stmt1;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_EviCodes;
	CREATE TEMPORARY TABLE tmp_EviCodes( evicode VARCHAR(50));
	SET @sql = CONCAT("INSERT INTO tmp_EviCodes (evicode) VALUES ('", REPLACE(evidences, ",", "'),('"),"');");
	PREPARE stmt2 from @sql;
	EXECUTE stmt2;
        
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
	
    IF evidences = '' then
		SELECT evi.TargetID, evi.EvidenceCode, eviType.EvidenceTypeName
		FROM FPS_DataCenter.TargetEvidence evi
			INNER JOIN tmp_CustId tmpCust ON tmpCust.custId = evi.TargetID
            INNER JOIN FPS_DataCenter.EvidenceType eviType ON evi.EvidenceTypeID = eviType.EvidenceTypeID
		WHERE evi.TargetType = 0 AND evi.IsActive = 1;
	ELSE
		SELECT evi.TargetID, evi.EvidenceCode, eviType.EvidenceTypeName
		FROM FPS_DataCenter.TargetEvidence evi
			INNER JOIN tmp_CustId tmpCust ON tmpCust.custId = evi.TargetID
			INNER JOIN tmp_EviCodes tmpEvi ON evi.EvidenceCode = tmpEvi.evicode
			INNER JOIN FPS_DataCenter.EvidenceType eviType ON evi.EvidenceTypeID = eviType.EvidenceTypeID
		WHERE evi.TargetType = 0 AND evi.IsActive = 1;
	END IF ;
  
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;


-- CALL `FPS_DataCenter`.`FPS_DC_GetEvidencesByCustomers`('1234','');

