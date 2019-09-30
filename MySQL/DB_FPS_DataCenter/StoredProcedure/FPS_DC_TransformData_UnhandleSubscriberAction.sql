
DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_UnhandleSubscriberAction$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_UnhandleSubscriberAction(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	
    /*
	Created: 20190730@Casey.Huynh
	Task :  Filter Unhandled Subscriber by IsProcessed = -1, Action Result
	DB: FPS_RawTransaction(rtaging)
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/
    
	DECLARE	UnhandleStatus					TINYINT DEFAULT -1;
    
	### PERFORMANCE: START
	DECLARE		SPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_UnhandleSubscriberAction' ;
    DECLARE		GroupID 	INT;
    DECLARE 	Notes	 	VARCHAR(500);
	DECLARE 	StartTime	TIMESTAMP(4);
	DECLARE		EndTime 	TIMESTAMP(4);
	DECLARE		Duration 	BIGINT ;    
   ### PERFORMANCE: END
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;   
	
    ### PERFORMANCE: START
    SET 	GroupID = IFNULL((SELECT MAX(pe.GroupID) FROM  FPS_DataCenter.zzTracePerformance pe),0) + 1;
    SET 	StartTime = CURRENT_TIMESTAMP(4);
    ### PERFORMANCE: END
	
    DROP TEMPORARY TABLE IF EXISTS Temp_UnhandleSubscriber;
    CREATE TEMPORARY TABLE Temp_UnhandleSubscriber 
    (	
		StagingTransID			BIGINT
		, SubscriberName		VARCHAR(30)
        , Status				INT
        , CreatedDate			DATETIME	#	Date Only
    );

    DROP TEMPORARY TABLE IF EXISTS Temp_UnhandleAction;
    CREATE TEMPORARY TABLE Temp_UnhandleAction 
    (	
		StagingTransID			BIGINT
		, ActionResult			VARCHAR(30)
        , CreatedDate			DATETIME	#	Date Only
    );

    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO Temp_UnhandleSubscriber (StagingTransID, SubscriberName, Status, CreatedDate)
    SELECT		rt.StagingTransID
				, rt.SubscriberName
                , su.Status
                , rt.CreatedDate
	FROM		FPS_RawTransaction.RawTransaction AS rt
    LEFT JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
	WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0
				AND (su.SubscriberName IS NULL
					OR su.Status = UnhandleStatus);
                    
	INSERT INTO Temp_UnhandleAction (StagingTransID, ActionResult, CreatedDate)
    SELECT		rt.StagingTransID
				, rt.ActionResult
                , rt.CreatedDate
	FROM		FPS_RawTransaction.RawTransaction AS rt
    LEFT JOIN	FPS_DataCenter.ActionResult AS ac
				ON ac.ActionResultID =  CRC32(MD5(LOWER(rt.ActionResult))) 
	WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND ac.ActionResultID IS NULL
				AND rt.Isprocessed = 0; 

    #==UNHANDLE SUBSCRIBER================================================================
	INSERT INTO FPS_Admin.Subscriber (SubscriberName, CreatedDate, Status)
	SELECT 		ts.SubscriberName
				, MIN(ts.CreatedDate) AS CreatedDate
				, UnhandleStatus	AS Status # UnhandleStatus
    FROM		Temp_UnhandleSubscriber AS ts   
    WHERE		ts.Status IS NULL
    GROUP BY	ts.SubscriberName;
    
    UPDATE FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	Temp_UnhandleSubscriber AS tt 
				ON rt.StagingTransID = tt.StagingTransID                
	SET			rt.IsProcessed = UnhandleStatus; 

    #==UNHANDLE ACTION================================================================

	INSERT IGNORE INTO FPS_DataCenter.ActionResult (ActionResultID, ActionResultKey, CreatedDate, ActionStatus)
	SELECT 		 CRC32(MD5(LOWER(ts.ActionResult))) AS ActionResultID
				, ts.ActionResult
				, MIN(ts.CreatedDate)	AS CreatedDate
				, UnhandleStatus		AS ActionStatus # UnhandleStatus
    FROM		Temp_UnhandleAction AS ts
    GROUP BY	ts.ActionResult;
	
    #===INSERT SUBCRIBERURL    
    INSERT IGNORE INTO FPS_DataCenter.SubscriberURL(SubscriberURLID, URL, SubscriberID, CreatedDate)
    SELECT		CRC32(MD5(LOWER(rt.URL))) AS SubscriberURLID
				, rt.URL
                , su.SubscriberID
                , MIN(rt.CreatedDate)
	FROM		FPS_RawTransaction.RawTransaction AS rt
    LEFT JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
	WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0
	GROUP BY	su.SubscriberID, rt.URL;
    
	### PERFORMANCE
    SET EndTime = CURRENT_TIMESTAMP(4);
   
    SET Notes = CONCAT(CONCAT(ip_FromStagingTransID, '_'), ip_ToStagingTransID);	
    INSERT INTO FPS_DataCenter.zzTracePerformance (SPName, GroupID, StepID, Notes, StartTime, EndTime, Duration)
    VALUES(SPName, GroupID, 0, Notes, StartTime, EndTime, TIMESTAMPDIFF(MICROSECOND,StartTime, EndTime));
	### PERFORMANCE 
    
	#=========================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_UnhandleSubscriber;
    #==========================================================
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$
DELIMITER ;
