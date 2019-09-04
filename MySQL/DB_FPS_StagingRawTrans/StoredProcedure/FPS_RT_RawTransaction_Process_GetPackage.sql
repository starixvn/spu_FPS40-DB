/*
	Created: 20190610@Casey.Huynh
	Task : Get Transaction List has not transferred (processed) to FPS_DataCenter DB
	DB: FPS_RawTransaction(Staging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

DELIMITER $$

USE FPS_RawTransaction$$
DROP PROCEDURE IF EXISTS FPSA_RawTransaction.FPSA_RT_RawTransaction_Process_GetPackage;
CREATE PROCEDURE FPSA_RawTransaction.FPSA_RT_RawTransaction_Process_GetPackage (IN ip_IsProcessed TINYINT, IN ip_NoOfTickets INT)
BEGIN

	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_RT_RawTransaction_Process_GetPackage' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500) DEFAULT 'GET Package: ';
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    SELECT StartTime;
    ### PERFORMANCE: END
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SELECT	MIN(pk.StagingTransID) 		AS MinStagingTransID
			, MAX(pk.StagingTransID)	AS MaxStagingTransID
	FROM	(
				SELECT	rt.StagingTransID	
				FROM 	FPS_RawTransaction.RawTransaction AS rt
				WHERE	rt.IsProcessed = ip_IsProcessed
				LIMIT	IP_NOOFTICKETS
			) pk;
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;  
    
    ### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(Notes, ip_NoOfTickets);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 

END$$
DELIMITER ;
