USE [bodb02]
GO

/****** Object:  StoredProcedure [dbo].[FPS_GetCustomerInfo40]    Script Date: 10/7/2019 4:34:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FPS_GetCustomerInfo40]
						@customerList		VARCHAR(MAX) = NULL -- xml format
AS
/*
	Creator:	20190605@Harvey.Nguyen
	Task:		API for get customer information for FPS 4.0 system - [Redmine: #109114]
	Database:	DBACC.bodb02
	
	Revisions:
		- 20190605@Harvey:	Initial - [Redmine: #109114]
		- 20190915@Harvey:	Edit for FPS40
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	CREATE TABLE #tempAccount (
		AccountID BIGINT
		,SubscriberID SMALLINT
		,SubscriberName NVARCHAR(50)
		,IsDeposit TINYINT
		,FirstLoginName VARCHAR(50)
		,FirstLoginNameWithPrefix VARCHAR(50)
		,CustID BIGINT
		,Username VARCHAR
		,Username2 VARCHAR
		,RoleID TINYINT
		,CurrencyID TINYINT
		,CurrencyName VARCHAR 
		,CreatedDate DATETIME
		,SubAccId BIGINT
		,Site VARCHAR(10)
		,LoginName VARCHAR(50)
		,LoginNameWithPrefix VARCHAR(50))

	DECLARE @idocCustomer INT
	EXEC sp_xml_preparedocument @idocCustomer OUTPUT, @customerList

	INSERT INTO #tempAccount (AccountID, SubscriberID, SubscriberName, FirstLoginName,FirstLoginNameWithPrefix)
	SELECT	Data.AccountID
		,	Data.SubscriberID
		,	Data.SubscriberName
		,	Data.LoginName
		,	Data.LoginNameWithPrefix
	FROM OPENXML(@idocCustomer, '/root/customer', 2) WITH (
			AccountID INT '@AccountID'
		,	SubscriberID INT	'@SubscriberID'
		,	SubscriberName NVARCHAR(50)	'@SubscriberName'
		,	LoginName NVARCHAR(50) '@LoginName'
		,	LoginNameWithPrefix NVARCHAR(50) '@LoginNameWithPrefix'
	) AS Data;	

	-- Select by username --
	SELECT	[custid]				= cst.custid
		,	[subaccid]				= 0
		,	[username]				= cst.username
		,	[username2]				= cst.username2
		,	[roleid]				= cst.roleid
		,	[site]					= upl.site
		,	[isDeposit]				= CASE WHEN dcs.custid IS NULL THEN 0 ELSE 1 END
		,	[currencyId]			= cst.currency
		,	[currencyname]			= exc.currency
		,	[createddate]			= cst.creatdate
		,	[accountid]				= tmp.AccountID
		,	[subscriberid]			= tmp.SubscriberID
		,	[subscribername]		= tmp.SubscriberName
		,	[loginname]				= tmp.FirstLoginName
		,	[loginnamewithprefix]	= tmp.FirstLoginNameWithPrefix
	FROM		#tempAccount AS tmp WITH (NOLOCK)
	INNER JOIN	dbo.Customer AS cst WITH (NOLOCK)
			ON	tmp.FirstLoginName = cst.username
	INNER JOIN	dbo.Customer AS upl WITH (NOLOCK)
			ON	cst.srecommend = upl.custid
	INNER JOIN	dbo.Exchange AS exc WITH (NOLOCK)
			ON	cst.currency = exc.exchangeid
	LEFT JOIN	dbo.Dep_CustSuper AS dcs WITH (NOLOCK)
			ON	cst.srecommend = dcs.custid
	UNION
	-- Select by username2 --
	SELECT	[custid]				= cst.custid
		,	[subaccid]				= 0
		,	[username]				= cst.username
		,	[username2]				= cst.username2
		,	[roleid]				= cst.roleid
		,	[site]					= upl.site
		,	[isDeposit]				= CASE WHEN dcs.custid IS NULL THEN 0 ELSE 1 END
		,	[currencyId]			= cst.currency
		,	[currencyname]			= exc.currency
		,	[createddate]			= cst.creatdate
		,	[accountid]				= tmp.AccountID
		,	[subscriberid]			= tmp.SubscriberID
		,	[subscribername]		= tmp.SubscriberName
		,	[loginname]				= tmp.FirstLoginName
		,	[loginnamewithprefix]	= tmp.FirstLoginNameWithPrefix
	FROM		#tempAccount AS tmp WITH (NOLOCK)
	INNER JOIN	dbo.Customer AS cst WITH (NOLOCK)
			ON	tmp.FirstLoginName = cst.username2
	INNER JOIN	dbo.Customer AS upl WITH (NOLOCK)
			ON	cst.srecommend = upl.custid
	INNER JOIN	dbo.Exchange AS exc WITH (NOLOCK)
			ON	cst.currency = exc.exchangeid
	LEFT JOIN	dbo.Dep_CustSuper AS dcs WITH (NOLOCK)
			ON	cst.srecommend = dcs.custid
	UNION
	-- Select by custsub --
	SELECT	[custid]				= cs.custid
		,	[subaccid]				= cs.subaccid
		,	[username]				= cs.username
		,	[username2]				= NULL
		,	[roleid]				= cst.roleid
		,	[site]					= upl.site
		,	[isDeposit]				= CASE WHEN dcs.custid IS NULL THEN 0 ELSE 1 END
		,	[currencyId]			= cst.currency
		,	[currencyname]			= exc.currency
		,	[createddate]			= cst.creatdate
		,	[accountid]				= tmp.AccountID
		,	[subscriberid]			= tmp.SubscriberID
		,	[subscribername]		= tmp.SubscriberName
		,	[loginname]				= tmp.FirstLoginName
		,	[loginnamewithprefix]	= tmp.FirstLoginNameWithPrefix
	FROM		#tempAccount AS tmp WITH (NOLOCK)
	INNER JOIN	dbo.custSub AS cs WITH (NOLOCK)
			ON	tmp.FirstLoginName = cs.username
	LEFT JOIN	dbo.Customer AS cst WITH (NOLOCK)
			ON	cs.custid = cst.custid
	LEFT JOIN	dbo.Customer AS upl WITH (NOLOCK)
			ON	cst.srecommend = upl.custid
	LEFT JOIN	dbo.Exchange AS exc WITH (NOLOCK)
			ON	cst.currency = exc.exchangeid
	LEFT JOIN	dbo.Dep_CustSuper AS dcs WITH (NOLOCK)
			ON	cst.srecommend = dcs.custid;
END;
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
GO

