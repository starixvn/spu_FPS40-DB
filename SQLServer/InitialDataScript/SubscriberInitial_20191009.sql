/*
Created:	20191009@Casey.Huynh
Task:		Initial Data for Subscriber

Query script(DBFRAUD>FPS_ADMIN.Subscriber):
	SELECT  [SubscriberID] AS [OldSubID]
				,[SubscriberName]
				,[IBCUserName_Prefix]
				,[IntegrationDate]      
				,8 as CreatedBy
				,EnableSysId AS IsDeposit   ---Notice: CN88 should be corrected to 0
				,[IsActive] AS [Status]
				,[IsTest]
	FROM [FPS_ADMIN].[dbo].[Subscribers]
*/

SELECT  [SubscriberID] AS [OldSubID]
      ,[SubscriberName]
      ,[IBCUserName_Prefix]
	  ,[IntegrationDate]      
	  ,8 as CreatedBy
      ,EnableSysId AS IsDeposit   ---Notice: CN88 should be corrected to 0
	  ,[IsActive] AS [Status]
      ,[IsTest]
FROM [FPS_ADMIN].[dbo].[Subscribers]