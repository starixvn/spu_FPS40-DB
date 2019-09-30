DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Transaction_UpdateDeviceID$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Transaction_UpdateDeviceID(IN ip_DeviceIDJson JSON)
BEGIN
    /*
	Created: 20190730@Casey.Huynh
	Task : Update Transaction DeviceID
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_Transaction_UpdateDeviceID' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	INT ;
    ### PERFORMANCE: END
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
	
    ### PERFORMANCE: START
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
    
	DROP TEMPORARY TABLE IF EXISTS temp_Transaction;    
	CREATE TEMPORARY TABLE temp_Transaction (
		 StagingTransID BIGINT
	);
    
    INSERT INTO temp_Transaction
		(	
			 StagingTransID
		)
	SELECT	tmpAcc.StagingTransID
	FROM 	JSON_TABLE(	ip_DeviceIDJson
						, "$[*]" COLUMNS( StagingTransID BIGINT PATH "$.StagingTransID")        
						) AS tmpAcc;                    
    
	UPDATE 		FPS_DataCenter.Transaction AS ts
    INNER JOIN	temp_Transaction AS tmpAcc
				ON ts.StagingTransID = tmpAcc.StagingTransID
	INNER JOIN	FPS_DataCenter.DeviceCode AS dc
				ON ts.DeviceCode = dc.DeviceCode
	SET			ts.DeviceID = dc.DeviceID;    
    	
    ### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);  

    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
            
END$$
DELIMITER ;
