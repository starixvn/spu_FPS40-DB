DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_Device_GetPackage;

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_Device_GetPackage (IN ip_Size INT)
BEGIN
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_DC_TransformData_Device_GetPackage' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500) DEFAULT 'GET Package: ';
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	INT ;
    DECLARE		Counter		INT UNSIGNED DEFAULT 0;
    DECLARE		IsStop		INT DEFAULT 0; 
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
        
    ### PERFORMANCE: END
    
	SELECT	ts.StagingTransID
			, ts.AccountID
            , ts.SubscriberID
            , ts.UserAgentID
            , ts.DeviceCodeID
	FROM 	FPS_DataCenter.Transaction AS ts
	WHERE	ts.AccountID 	IS NOT NULL
			AND ts.DeviceID IS NULL
	LIMIT   ip_Size;
	
    #SELECT 4616 AS MinStagingTransID, 4715 AS MaxStagingTransID;
    ### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT(Notes, ip_Size);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;  
END$$
DELIMITER ;
