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

CREATE PROCEDURE FPS_DataCenter.FPS_DC_IPTableLog_AddNewLog(IN ip_UpdatedDate DATETIME)
BEGIN   
    UPDATE 	FPS_DataCenter.IPTableLog
	SET		IsNewUpdate = 0
	WHERE	IsNewUpdate = 1;
    
    INSERT INTO FPS_DataCenter.IPTableLog(UpdatedDate, IsNewUpdate)
	VALUES(	ip_UpdatedDate
			, 1
			);       
END$$
DELIMITER ;
