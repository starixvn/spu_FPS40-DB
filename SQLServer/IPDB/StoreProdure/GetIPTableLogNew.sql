CREATE PROCEDURE [dbo].[GetIPTableLogNewUpdate]
	@IPType TINYINT -- 0: if Update IPV4, 1: If Update IPV6
AS
/*
	Created: 20190627@CaseyHuynh
	Task : Get New Update of IPTableLog
	DB: IPDB
	Original:

	Revisions:

	Param's Explanation (filtered by):
*/
BEGIN
	SET NOCOUNT ON;	

	SELECT	IPType
			, UpdatedDate
			, IsNewUpdate 
	FROM	dbo.IPTableLog il WITH(NOLOCK)
	WHERE	il.IPType = @IPType
			AND il.IsNewUpdate = 1;
			
END;

GO
/*<info serverAlias="IPDB" executers="bodbAdminNet" isFunction="0" isNested="0"></info>*/