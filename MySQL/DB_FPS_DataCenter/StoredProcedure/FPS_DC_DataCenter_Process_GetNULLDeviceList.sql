/*
	Created: 20190730@Casey.Huynh
	Task : Get Package to Process Data (MinrtagingTransID to MaxrtagingTransID)
	DB: FPSA_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPSA_DataCenter$$

DROP PROCEDURE IF EXISTS FPSA_DataCenter.FPS_DC_DataCenter_Process_GetNULLDeviceIDList$$

CREATE PROCEDURE FPSA_DataCenter.FPS_DC_DataCenter_Process_GetNULLDeviceIDList(IN ip_Size INT)
BEGIN
	DECLARE 	FromID	INT;
    DECLARE		ToID	BIGINT;
    
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_DataCenter_Process_GetNULLAccountIDList' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPSA_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
	SELECT		ts.StagingTransID
    FROM		FPSA_DataCenter.Transaction AS ts
    WHERE		ts.DeviceID IS NULL
    LIMIT		ip_Size;
   
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	
    	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);  
    
    INSERT INTO FPSA_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 

    
END$$
DELIMITER ;
