/*
Creator: 20190627@CaseyHuynh
Task:    Create table to track IP Updating
Server:  IPDB

Reviewer: Billy
*/ 

CREATE TABLE dbo.IPTableLog(
	IPTableLogID			INT IDENTITY
	, IPType				TINYINT		--0: Update IPV4 table IP2Location, 1: IPV6 Table IPV6Location
	, UpdatedDate			DATETIME
	, IsNewUpdate			BIT			--0: old, 1: New 
)
CREATE CLUSTERED INDEX IX_IPTableLog_IPType_Flag ON dbo.IPTableLog (
	IPType			ASC
	, IsNewUpdate	ASC
) 