DELIMITER $$

USE FPS_RawTransaction$$
DROP PROCEDURE IF EXISTS FPS_RawTransaction.FPS_RT_TransformData_GetPackage;
CREATE PROCEDURE FPS_RawTransaction.FPS_RT_TransformData_GetPackage (IN ip_IsProcessed TINYINT, IN ip_NoOfTickets INT, IN ip_NoOfBatch INT)
BEGIN
	### PERFORMANCE: START
	DECLARE		SPName		varchar(200) DEFAULT 'FPS_RT_TransformData_GetPackage' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	varchar(500) DEFAULT 'GET Package: ';
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	int ;
    DECLARE		Counter		INT UNSIGNED DEFAULT 0;
    DECLARE		IsStop		INT DEFAULT 0; 
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = Current_TimeStamp(4);

    ### PERFORMANCE: END
    
    DROP TEMPORARY TABLE IF EXISTS Temp_StagingTrans;
    CREATE TEMPORARY TABLE Temp_StagingTrans 
    (		
		MinStagingTransId			INT
        , MaxStagingTransId			INT
    ); 
    
	
     loop_label:  LOOP
		
		IF ((SELECT COUNT(1) FROM Temp_StagingTrans) < ip_NoOfBatch AND IsStop != -1)   THEN       
			       
			INSERT INTO Temp_StagingTrans
			SELECT	MIN(pk.StagingTransID) 		AS MinStagingTransID
					, MAX(pk.StagingTransID)	AS MaxStagingTransID
			FROM	(
						SELECT	rt.StagingTransID	
						FROM 	FPS_RawTransaction.RawTransaction AS rt
						WHERE	rt.IsProcessed = ip_IsProcessed
									And StagingTransID > Counter
						LIMIT	 ip_NoOfTickets
					) pk;
                
            SET Counter = (SELECT MAX(MaxStagingTransID) FROM Temp_StagingTrans);
		ELSE
            LEAVE  loop_label;
        END IF;
        
        IF(Counter = IsStop) THEN 
			SET IsStop = -1;
        ELSE 
			Set IsStop = Counter;
        END IF;
        
    END LOOP;
    
    SELECT tmpTT.MinStagingTransId
        , tmpTT.MaxStagingTransId
	FROM  Temp_StagingTrans AS tmpTT;
    
    #SELECT 4616 AS MinStagingTransID, 4715 AS MaxStagingTransID;
    ### PERFORMANCE
    SET EndTime = Current_TimeStamp(4);
   
    SET Notes = CONCAT(Notes, ip_NoOfTickets);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    Values(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(Microsecond,StartTime, EndTime));
	### PERFORMANCE 
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;  
END$$
DELIMITER ;
