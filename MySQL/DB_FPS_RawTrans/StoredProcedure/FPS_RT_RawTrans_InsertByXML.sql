/*
	Created: 20190610@Casey.Huynh
	Task : Insert to Raw Table by XML file
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

CREATE PROCEDURE FPS_RawTransaction.FPS_RT_RawTrans_InsertByXML(IN ip_RawTransJson LONGTEXT)
BEGIN

    INSERT INTO FPS_RawTransaction.RawTransaction
	(	LoginName
		, SubscriberName
		, TransDate
		, CreatedDate
		, DeviceCode
		, FingerprintCode
		, FingerprintMoreInfo
		, UserAgent
		, IP
		, PluginID
		, URL
		, ActionResult
	)
	SELECT
			rt.LoginName
			, rt.SubscriberName
			, rt.TransDate
			, DATE(rt.TransDate) AS CreatedDate
			, rt.DeviceCode
			, rt.FingerprintCode
			, rt.FingerprintMoreInfo
			, rt.UserAgent
			, rt.IP
			, rt.PluginID
			, rt.URL
			, rt.ActionResult
	FROM	JSON_TABLE(
			ip_RawTransJson,
			 "$[*]" COLUMNS(
							  LoginName				VARCHAR(50) PATH "$.LoginName"       
							, SubscriberName		VARCHAR(50) PATH "$.SubscriberName"   
							, TransDate				TIMESTAMP(4) PATH "$.TransDate"
							, DeviceCode			VARCHAR(32)		PATH "$.DeviceCode"
							, FingerprintCode		VARCHAR(5000)	PATH "$.FingerprintCode"
							, FingerprintMoreInfo	TEXT		 	PATH "$.FingerprintMoreInfo"
							, UserAgent				VARCHAR(500) 	PATH "$.UserAgent"
							, IP					VARCHAR(50) 	PATH "$.IP"
							, PluginID				BIGINT 			PATH "$.PluginID"
							, URL					VARCHAR(250) 	PATH "$.URL"
							, ActionResult			VARCHAR(100) 	PATH "$.ActionResult"
							)
		   ) AS  tmpAcc; 
    
END$$
DELIMITER ;
