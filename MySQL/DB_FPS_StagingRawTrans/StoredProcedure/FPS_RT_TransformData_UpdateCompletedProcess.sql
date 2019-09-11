DELIMITER $$

USE FPS_RawTransaction$$

DROP PROCEDURE IF EXISTS FPS_RawTransaction.FPS_RT_TransformData_UpdateCompletedProcess$$
CREATE PROCEDURE FPS_RawTransaction.FPS_RT_TransformData_UpdateCompletedProcess(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task : Mark Completed from Raw Transaction
	DB: FPS_RawTransaction(Staging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/

	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_RT_TransformData_UpdateCompletedProcess' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);
    
	UPDATE 	FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	FPS_DataCenter.Transaction AS ts
				ON ts.StagingTransID = rt.StagingTransID
	SET		rt.IsProcessed = 1
    WHERE	rt.IsProcessed = 0
			AND rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID;           
	    
    ### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE     
END$$
DELIMITER ;
