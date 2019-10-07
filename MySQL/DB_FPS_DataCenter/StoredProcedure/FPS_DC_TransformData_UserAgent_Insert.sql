DELIMITER $$

USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_TransformData_UserAgent_Insert$$

CREATE PROCEDURE FPS_DataCenter.FPS_DC_TransformData_UserAgent_Insert(IN ip_FromStagingTransID BIGINT, IN ip_ToStagingTransID BIGINT)
BEGIN
	/*
	Created: 20190730@Casey.Huynh
	Task :	Insert UserAgent
	DB:		FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
    
	### PERFORMANCE: START
    DECLARE		vrExecKey		BIGINT	UNSIGNED;
	DECLARE		vrSPName		VARCHAR(200) DEFAULT 'FPS_DC_TransformData_UserAgent_Insert' ;
    DECLARE		vrStepID		INT;
	DECLARE 	vrNotes	 		VARCHAR(500);
	DECLARE 	vrStartTime		TIMESTAMP(4);
	DECLARE		vrEndTime 		TIMESTAMP(4);
	DECLARE		vrDuration 		BIGINT;	
    DECLARE		vrTotalRecord	INT;
    DECLARE		vrFromID		BIGINT;
    DECLARE		vrToID			BIGINT;

    SET		vrExecKey = CRC32((UUID_Short()));    
    SET		vrNotes = 'Inser UserAgent';		
    SET 	vrStepID = 1;    
	SET 	vrStartTime = CURRENT_TIMESTAMP(4); 
    
    INSERT INTO FPS_DataCenter.zzTracePerformance (ExecKey, StepID, SPName, Notes, StartTime, FromID, ToID)
    VALUES(vrExecKey, vrStepID, vrSPName,  vrNotes, vrStartTime, ip_FromStagingTransID, ip_ToStagingTransID);
	 
	### PERFORMANCE: END  
	
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
    
    DROP TEMPORARY TABLE IF EXISTS Temp_UserAgent;
    CREATE TEMPORARY TABLE Temp_UserAgent 
    (		
		UserAgentID			BIGINT
        , UserAgent			TEXT
        , CreatedDate		DATETIME
    );    
	    
    INSERT INTO Temp_UserAgent (UserAgentID, UserAgent, CreatedDate)
    SELECT		CRC32(LOWER(rt.UserAgent)) AS UserAgentID
				, rt.UserAgent
                , MIN(rt.CreatedDate)
	FROM		FPS_RawTransaction.RawTransaction	AS rt
    #LEFT JOIN	FPS_DataCenter.UserAgent 			AS ua
	#			ON ua.UserAgentID = CRC32(LOWER(rt.UserAgent))
    WHERE		rt.StagingTransID BETWEEN ip_FromStagingTransID AND ip_ToStagingTransID
				AND rt.IsProcessed = 0
               # AND ua.UserAgentID IS NULL
    GROUP BY	rt.UserAgent;  
    
	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
	#========INSERT: Subscriber which are unhandled interagtion=====================================================
	INSERT IGNORE INTO FPS_DataCenter.UserAgent (UserAgentID, UserAgent, CreatedDate )
	SELECT 		tu.UserAgentID
				, tu.UserAgent
                , tu.CreatedDate
    FROM		Temp_UserAgent AS tu;
	
	### PERFORMANCE
	SET	vrEndTime = CURRENT_TIMESTAMP(4);
    
    UPDATE	FPS_DataCenter.zzTracePerformance AS z
    SET		z.EndTime = vrEndTime
			, z.Duration = TIMESTAMPDIFF(MICROSECOND, vrStartTime, vrEndTime)
            , z.TotalRecord = vrTotalRecord
            , z.FromID = vrFromID
            , z.ToID		= vrToID
    WHERE	z.ExecKey = vrExecKey AND z.StepID = z.StepID;
    ### PERFORMANCE: END
    
END$$
DELIMITER ;
