
DELIMITER $$
USE FPS_DataCenter$$

DROP PROCEDURE IF EXISTS FPS_DataCenter.FPS_DC_GetAssociationForGraphDB;
CREATE PROCEDURE FPS_DataCenter.FPS_DC_GetAssociationForGraphDB(IN ip_SyncGraphDB TINYINT, IN ip_Size INT)
BEGIN
	/*
	Created:	20190610@Casey.Huynh
	Task :		Get Association list by SyncGraphDB status;
	DB:			FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
	*/
    #=========================================================================================
    DROP TABLE IF EXISTS Temp_Association;
	
	CREATE TEMPORARY TABLE Temp_Association
    ( 
		AssociationID		BIGINT
		, DeviceID			BIGINT
        , AccountID			BIGINT
        , SubscriberID		SMALLINT
        , SubscriberName	VARCHAR(30)		CHARACTER SET utf8	NULL
        , IsDeposit			TINYINT
        , CustID			BIGINT								NULL
		, Username			VARCHAR(50)		CHARACTER SET utf8	NULL
		, Username2			VARCHAR(50)		CHARACTER SET utf8	NULL
		, RoleID			TINYINT							NULL
		, CurrencyID		SMALLINT						NULL
		, CurrencyName		VARCHAR(50)		CHARACTER SET utf8	NULL        
	);    
	   
	SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    

	#=======GET Associate List to insert into GraphDB=================================================================================================================	
	INSERT INTO Temp_Association(AssociationID, DeviceID, AccountID, SubscriberID, SubscriberName, IsDeposit, CustID, Username, Username2, RoleID, CurrencyID, CurrencyName)
	SELECT	ass.AssociationID
			, ass.DeviceID
			, ass.AccountID
			, sub.SubscriberID
			, sub.SubscriberName
			, sub.IsDeposit
			, acc.CustID
			, acc.Username
			, acc.Username2
			, acc.RoleID
			, acc.CurrencyID
			, acc.CurrencyName
	FROM		FPS_DataCenter.Association ass
	INNER JOIN	FPS_Admin.Subscriber sub
				ON ass.SubscriberID = sub.SubscriberID
	INNER JOIN	FPS_DataCenter.Account acc
				ON ass.AccountID = acc.AccountID
	WHERE	ass.SyncGraphDB = ip_SyncGraphDB
			AND sub.IsDeposit IS NOT NULL
			AND acc.CustID IS NOT NULL
	LIMIT ip_Size;	
    
    SELECT 	tas.AssociationID
			, tas.DeviceID
			, tas.AccountID
			, tas.SubscriberID
			, tas.SubscriberName
			, tas.IsDeposit
			, tas.CustID
			, tas.Username
			, tas.Username2
			, tas.RoleID
			, tas.CurrencyID
			, tas.CurrencyName
    FROM	Temp_Association tas;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;    
END$$
DELIMITER ;


