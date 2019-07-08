/*
	Created: 20190627@Casey.Huynh
	Task : Get New Update of Table [IPTableLog]
	DB: FPS_RawTrans
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$
USE FPS_DataCenter$$

CREATE PROCEDURE FPS_DataCenter.DC_IPTableLog_GetLatestUpdatedDate()
BEGIN

	SELECT	il.UpdatedDate 
	FROM	FPS_DataCenter.IPTableLog AS il
	WHERE	il.IsNewUpdate = 1
	LIMIT	1;
    
END$$
DELIMITER ;
