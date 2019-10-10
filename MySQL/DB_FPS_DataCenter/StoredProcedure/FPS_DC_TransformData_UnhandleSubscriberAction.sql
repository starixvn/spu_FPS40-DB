
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
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_UnhandleSubscriberAction' ;
    DECLARE		vrStepID		INT;
	DECLARE 	vrNotes	 		VARCHAR(500);
	DECLARE 	vrStartTime		TIMESTAMP(4);
	DECLARE		vrEndTime 		TIMESTAMP(4);
	DECLARE		vrDuration 		BIGINT;	
    DECLARE		vrTotalRecord	INT;
    DECLARE		vrFromID		BIGINT;
    DECLARE		vrToID			BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Process Unhandle Subscriber and Action';		
    SET 	vrStepID = 1;
    SET 	vrStartTime = CURRENT_TIMESTAMP(4); 
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, FromID, ToID)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_FromStagingTransID, ip_ToStagingTransID);
	
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
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
		, ActionResult			VARCHAR(200)
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
				ON ac.ActionResultID =  CRC32(LOWER(rt.ActionResult)) 
	WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND ac.ActionResultID IS NULL
				AND rt.Isprocessed = 0; 

    #==UNHANDLE SUBSCRIBER================================================================
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	INSERT INTO FPS_Admin.Subscriber (SubscriberName, CreatedDate, Status)
	SELECT 		ts.SubscriberName
				, MIN(ts.CreatedDate) AS CreatedDate
				, UnhandleStatus	AS Status # UnhandleStatus
    FROM		Temp_UnhandleSubscriber AS ts   
    WHERE		ts.Status IS NULL
    GROUP BY	ts.SubscriberName;
    
    UPDATE 		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	Temp_UnhandleSubscriber AS tt 
				ON rt.StagingTransID = tt.StagingTransID                
	SET			rt.IsProcessed = UnhandleStatus; 

    #==UNHANDLE ACTION================================================================
	
    
	INSERT IGNORE INTO FPS_DataCenter.ActionResult (ActionResultID, ActionResultKey, CreatedDate, ActionStatus)
	SELECT 		 CRC32(LOWER(ts.ActionResult)) AS ActionResultID
				, ts.ActionResult
				, MIN(ts.CreatedDate)	AS CreatedDate
				, UnhandleStatus		AS ActionStatus # UnhandleStatus
    FROM		Temp_UnhandleAction AS ts
    GROUP BY	ts.ActionResult;
	
    #===INSERT SUBCRIBERURL    
    INSERT IGNORE INTO FPS_DataCenter.SubscriberURL(SubscriberURLID, URL, SubscriberID, CreatedDate)
    SELECT		CRC32(LOWER(rt.URL)) AS SubscriberURLID
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
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
    
	#=========================================================
    DROP TEMPORARY TABLE IF EXISTS Temp_UnhandleSubscriber;
    #==========================================================
 
END$$
DELIMITER ;
