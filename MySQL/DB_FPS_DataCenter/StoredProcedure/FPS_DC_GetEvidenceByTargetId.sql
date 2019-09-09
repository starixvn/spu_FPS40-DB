USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_GetEvidenceByTargetId`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_GetEvidenceByTargetId` (IN targetId BIGINT, IN objType TINYINT, IN subIdList LONGTEXT, IN isMaster TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get evidence by account
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    CALL FPS_DC_GetEvidenceByTargetId (322,1,'6',0);
*/
	DROP TEMPORARY TABLE IF EXISTS tmp_SubId;
	CREATE TEMPORARY TABLE tmp_SubId( subId INT );
    
	SET @sql = CONCAT("INSERT INTO tmp_SubId (subId) VALUES ('", REPLACE(subIdList, ",", "'),('"),"');");
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT te.TargetEvidenceID
		,te.TargetID
		,te.TargetLevel
		,te.TargetType
		,te.CentralPointID
		,te.CentralPointType
		,et.EvidenceTypeCode
		,sub.SubscriberName
		,te.IsCreatedByMaster
	FROM FPS_DataCenter.TargetEvidence te
	INNER JOIN FPS_DataCenter.EvidenceType et ON te.EvidenceTypeID = et.EvidenceTypeID
	INNER JOIN FPS_Admin.Subscriber sub ON te.SubscriberID = sub.SubscriberID
	WHERE te.TargetID = targetId
		AND te.TargetType = objType
		AND (
			te.IsCreatedByMaster = isMaster
			OR sub.SubscriberID IN (SELECT subId FROM tmp_SubId));
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    DROP TABLE tmp_SubId;

END$$

DELIMITER ;
