/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_DataCenter_Process_Transaction$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_DataCenter_Process_Transaction(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	SET SESSION autocommit = 0;
	START  TRANSACTION;
	INSERT INTO FPS_DataCenter.Transaction(StagingTransID, SubscriberID, SubURLID, ActionResultID,  UserAgentID, AccountID, DeviceID, LoginName 
				,  TransDate, CreatedDate, PluginID, Flagged)                
	SELECT 		rt.StagingTransID
				, su.SubscriberID
				, ur.SubscriberURLID
                , ar.ActionResultID
				, ua.UserAgentID
                , ac.AccountID
				, 2 #as dv.DeviceID
				, rt.LoginName				            
				, rt.TransDate
				, rt.CreatedDate
				#, rt.IP
				, rt.PluginID
				, 0 AS Flagged				
	FROM		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
    INNER JOIN	FPS_DataCenter.SubscriberURL  AS ur
				ON 	su.SubscriberID = ur.SubscriberID
					AND rt.URL = ur.URL
	INNER JOIN	FPS_DataCenter.ActionResult AS ar
				ON rt.ActionResult = ar.ActionResultKey
	INNER JOIN	FPS_DataCenter.UserAgent AS ua
				ON MD5(rt.UserAgent) = ua.UserAgentCode
	INNER JOIN	FPS_DataCenter.Account AS ac
				ON	su.SubscriberID = ac.SubscriberID
				AND	( 	rt.LoginName = ac.FirstLoginName
						OR rt.LoginName = ac.UserName
						OR CONCAT(su.SubScriberPrefix, rt.LoginName) = ac.Username2)
	WHERE		rt.IsProcessed = 0
				AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;
	
	#--===================================================	
    UPDATE 	FPS_RawTransaction.RawTransaction AS rt
	SET		rt.IsProcessed = 1
    WHERE	rt.IsProcessed = 0
			AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;	
	COMMIT;
	SET SESSION autocommit = 1;
            
END$$
DELIMITER ;
