/*
	Created: 20190610@Casey.Huynh
	Task : Insert 1 row data to Table Ra
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DROP PROCEDURE IF EXISTS FPS_RawTrans.RT_RawTrans_Insert;

DELIMITER $$
USE FPS_RawTrans$$

CREATE PROCEDURE FPS_RawTrans.RT_RawTrans_Insert(
	ip_DeviceCode		VARCHAR(32) 
	, ip_LoginName		VARCHAR(50) 
	, ip_SubscriberName	VARCHAR(30) 
	, ip_TransDate		DATETIME
	, ip_IP				VARCHAR(20)
	, ip_PluginID		BIGINT
	, ip_DeviceStatus	TINYINT
	, ip_URL			VARCHAR(250)
	, ip_ActionResult	VARCHAR(100)
	, ip_UserAgent		VARCHAR(500)
    , ip_CapturedData	VARCHAR(1000)		
)
BEGIN
	INSERT INTO FPS_RawTrans.RawTransaction
	(
		DeviceCode
        , LoginName
        , SubscriberName
        , TransDate
        , IP
        , PluginID
        , DeviceStatus
        , URL
        , ActionResult
        , UserAgent
        , CapturedData)
		VALUES
		(ip_DeviceCode
        , ip_LoginName
        , ip_SubscriberName
        , ip_TransDate
        , ip_IP
        , ip_PluginID
        , ip_DeviceStatus
        , ip_URL
        , ip_ActionResult
        , ip_UserAgent
        , ip_CapturedData
	);
END$$

DELIMITER ;

