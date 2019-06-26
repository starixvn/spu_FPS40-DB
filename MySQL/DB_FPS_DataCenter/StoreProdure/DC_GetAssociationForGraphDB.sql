/*
	Created: 20190610@Casey.Huynh
	Task : Get Association list by SyncGraphDB status;
	DB: FPS_DataCenter
	Original:

	Revisions:
	Param's Explanation (filtered by):
*/
DROP PROCEDURE IF EXISTS FPS_DataCenter.DC_GetAssociationForGraphDB;

DELIMITER $$
USE FPS_DataCenter$$

CREATE PROCEDURE FPS_DataCenter.DC_GetAssociationForGraphDB(IN ip_SyncGraphDB TINYINT(1), IN ip_Size INT)
BEGIN
	
    #=========================================================================================
    DROP TABLE IF EXISTS Temp_Association;
	
	CREATE TEMPORARY TABLE Temp_Association
    ( 
		AssociationID		BIGINT
		, DeviceID			BIGINT
        , AccountID			BIGINT
        , SubscriberID		INT
        , SubscriberName		VARCHAR(30)		CHARACTER SET utf8	NULL
        , IsDeposit			TINYINT(1)
        , CustID			BIGINT								NULL
		, Username			VARCHAR(50)		CHARACTER SET utf8	NULL
		, Username2			VARCHAR(50)		CHARACTER SET utf8	NULL
		, RoleID			TINYINT(1)							NULL
		, CurrencyID		TINYINT(2)							NULL
		, CurrencyName		VARCHAR(50)		CHARACTER SET utf8	NULL        
	);    
	   
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
    
END$$
DELIMITER ;


