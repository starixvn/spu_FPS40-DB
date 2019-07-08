/*
	Created: 20190627@Casey.Huynh
	Task : Update Table IPTableLog
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
USE FPS_DataCenter$$

CREATE PROCEDURE FPS_DataCenter.DC_IPTableLog_AddNewLog(IN ip_UpdatedDate DATETIME)
BEGIN

	INSERT INTO IPTableLog(IPType, UpdatedDate, IsNewUpdate)
	VALUES(	@IPType
			, ip_UpdatedDate
			, 1
			);
    
    UPDATE IPTableLog
	SET		IsNewUpdate = 0
	WHERE	UpdatedDate < ip_UpdatedDate;
    
END$$
DELIMITER ;
