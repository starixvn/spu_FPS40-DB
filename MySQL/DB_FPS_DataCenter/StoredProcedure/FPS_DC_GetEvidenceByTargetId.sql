USE `FPS_DataCenter`;
DROP procedure IF EXISTS `FPS_DC_GetEvidenceByTargetId`;

DELIMITER $$
USE `FPS_DataCenter`$$
CREATE PROCEDURE `FPS_DC_GetEvidenceByTargetId` (IN targetId BIGINT, IN targetType TINYINT, IN userId INT, IN isMaster TINYINT)
BEGIN
/*
	Created: 20190909@Harvey
	Task : Get evidence by account
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
    
    call FPS_DataCenter.FPS_DC_GetEvidenceByTargetId(7180, 0, 8, 1);
*/    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF isMaster = 0 THEN
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
			AND te.TargetType = targetType
			AND (te.IsCreatedByMaster = 0
					AND te.SubscriberID IN (SELECT SubscriberID FROM FPS_Admin.UserSubscriber WHERE UserID = userId));
	ELSE
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
			AND te.TargetType = targetType;
    END IF;
        
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

END$$

DELIMITER ;
