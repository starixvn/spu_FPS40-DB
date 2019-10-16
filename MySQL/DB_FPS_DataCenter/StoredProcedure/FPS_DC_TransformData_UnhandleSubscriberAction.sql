
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
    
	DECLARE	vrUnhandleStatus_Subscriber	 BIT(16) DEFAULT 1;
    DECLARE	vrUnhandleStatus_Action	 BIT(16) DEFAULT 2;
    DECLARE vrUnhandleStatus	TINYINT DEFAULT -1;
    DECLARE vrNotTransformedStatus BIT(16);
    
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
    
	DROP TEMPORARY TABLE IF EXISTS Temp_Transaction;
    CREATE TEMPORARY TABLE Temp_Transaction 
    (	
		StagingTransID			BIGINT
		, SubscriberName		VARCHAR(30)        
        , ActionResult			VARCHAR(200)
        , URL					VARCHAR(250)
        , TransStatus			INT
        , CreatedDate			DATETIME	#	Date Only        
        , SubscriberID			INT
		, SubscriberStatus		TINYINT
        , ActionResultID		BIGINT
        , ActionResultStatus	TINYINT
        , SubscriberURLID		BIGINT
        , IsProcessed			BIT	DEFAULT 0
    );
    
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
    
    INSERT	INTO Temp_Transaction(StagingTransID, SubscriberName, ActionResult, URL, TransStatus, CreatedDate, SubscriberID
								, SubscriberStatus, ActionResultID, ActionResultStatus, SubscriberURLID)
    SELECT 	rt.StagingTransID
			, rt.SubscriberName
            , rt.ActionResult
            , rt.URL
            , rt.TransStatus
            , rt.CreatedDate
            , su.SubscriberID
            , su.Status
            , ac.ActionResultID
            , ac.ActionStatus
            , ur.SubscriberURLID
	FROM	FPS_RawTransaction.RawTransaction AS rt
	LEFT JOIN	FPS_Admin.Subscriber AS su
				ON rt.SubscriberName = su.SubscriberName
	LEFT JOIN	FPS_DataCenter.ActionResult AS ac
				ON ac.ActionResultID =  CRC32(LOWER(rt.ActionResult)) 
	LEFT JOIN   FPS_DataCenter.SubscriberURL AS ur
				ON su.SubscriberID = ur.SubscriberID
					AND CRC32(LOWER(rt.URL)) = ur.SubscriberURLID
    WHERE	rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0;   
                
    #==UNHANDLE SUBSCRIBER================================================================
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	INSERT IGNORE INTO FPS_Admin.Subscriber (SubscriberName, CreatedDate, Status)
	SELECT 		ts.SubscriberName
				, MIN(ts.CreatedDate) AS CreatedDate
				, vrUnhandleStatus	AS Status # vrUnhandleStatus_Subscriber
    FROM		Temp_Transaction AS ts   
    WHERE		ts.SubscriberID IS NULL
    GROUP BY	ts.SubscriberName;

    #==UNHANDLE ACTION================================================================    
	INSERT IGNORE INTO FPS_DataCenter.ActionResult (ActionResultID, ActionResultKey, CreatedDate, ActionStatus)
	SELECT 		 CRC32(LOWER(ts.ActionResult)) AS ActionResultID
				, ts.ActionResult
				, MIN(ts.CreatedDate)	AS CreatedDate
				, vrUnhandleStatus	AS ActionStatus # vrUnhandleStatus_Subscriber
    FROM		Temp_Transaction AS ts
	WHERE		ts.ActionResultID IS NULL
    GROUP BY	ts.ActionResult;
	
    #===INSERT SUBCRIBERURL    
    INSERT IGNORE INTO FPS_DataCenter.SubscriberURL(SubscriberURLID, URL, SubscriberID, CreatedDate)
    SELECT		CRC32(LOWER(ts.URL)) AS SubscriberURLID
				, ts.URL
                , ts.SubscriberID
                , MIN(ts.CreatedDate)
	FROM		Temp_Transaction AS ts
	WHERE		ts.SubscriberURLID IS NULL
	GROUP BY	ts.SubscriberID, ts.URL;    
	
    SET vrNotTransformedStatus = FPS_DC_GetTransStatus_NotTransformed();

    #===Update NOT Transform status for the Invalid Transaction (Invalid Subscriber)
    UPDATE 		Temp_Transaction AS ts
	SET			TransStatus = TransStatus | vrUnhandleStatus_Subscriber
    WHERE		ts.SubscriberID IS NULL
				OR ts.SubscriberStatus = vrUnhandleStatus;
 
	#===Update NOT Transform status for the Invalid Transaction (Invalid Subscriber)
    UPDATE 		Temp_Transaction AS ts
	SET			TransStatus = TransStatus | vrUnhandleStatus_Action
    WHERE		ts.ActionResultID IS NULL
				OR ts.ActionResultStatus = vrUnhandleStatus; 

    #==========================================================================
    UPDATE		FPS_RawTransaction.RawTransaction AS rt
    INNER JOIN	Temp_Transaction AS ts
				ON rt.StagingTransID = ts.StagingTransID
	SET			rt.IsProcessed = CASE WHEN (ts.TransStatus & vrNotTransformedStatus) != 0 THEN vrUnhandleStatus ELSE rt.IsProcessed END 
				, rt.TransStatus = ts.TransStatus;
    
	### PERFORMANCE
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
 
END$$
DELIMITER ;
