USE [IPDB]
GO

/****** Object:  StoredProcedure [dbo].[GetIPDBVersion]    Script Date: 10/7/2019 4:34:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[GetIPDBVersion]
AS
/*
	Creator:	20190705@Billy
	Task:		Description - [Redmine: #116251]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190705@Billy:	Initial - [Redmine: #116251]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	TOP(1)
			[version] = version_date
	FROM	dbo.IPDBVersion WITH (NOLOCK)
	ORDER BY version_date DESC;
END;
GO

