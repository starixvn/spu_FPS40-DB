/*
	Created: 20190610@Casey.Huynh
	Task : Insert 1 row data into StagingRawTransaction Table
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DROP PROCEDURE IF EXISTS FPS_RawTrans.RT_StagingRawTrans_Insert;

DELIMITER $$
USE FPS_RawTrans$$

CREATE PROCEDURE FPS_RawTrans.RT_StagingRawTrans_Insert(
	ip_DeviceCode			VARCHAR(32) 
	, ip_LoginName			VARCHAR(50) 
	, ip_SubscriberName		VARCHAR(30) 
	, ip_TransDate			DATETIME
	, ip_IP					VARCHAR(20)
	, ip_PluginID			BIGINT
	, ip_DeviceStatus		TINYINT
	, ip_URL				VARCHAR(250)
	, ip_ActionResult		VARCHAR(100)
	, ip_UserAgent			VARCHAR(500)
    , ip_CapturedData		VARCHAR(1000)
	, ip_IsProcessed		TINYINT(1)
)
BEGIN
	INSERT INTO FPS_RawTrans.StagingRawTransaction
	(
		DeviceCode
		, LoginName
		, SubscriberName
		, TransDate
		, CreatedDate
		, IP
		, PluginID
		, DeviceStatus
		, URL
		, ActionResult
		, UserAgent
		, CapturedData
		, IsProcessed
	)
	VALUES
	(
        ip_DeviceCode
		, ip_LoginName
		, ip_SubscriberName
		, ip_TransDate
		, DATE(ip_TransDate)
		, ip_IP
		, ip_PluginID
		, ip_DeviceStatus
		, ip_URL
		, ip_ActionResult
		, ip_UserAgent
		, ip_CapturedData
		, ip_IsProcessed
	);
END$$

DELIMITER ;
