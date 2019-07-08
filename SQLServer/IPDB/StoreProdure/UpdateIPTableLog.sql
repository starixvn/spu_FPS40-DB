ALTER PROCEDURE [dbo].[UpdateIPTableLog]
	@IPType TINYINT -- 0: if Update IPV4, 1: If Update IPV6
AS
/*
	Created: 20190627@CaseyHuynh
	Task : Update [IPTableLog]
	DB: IPDB
	Original:

	Revisions:

	Param's Explanation (filtered by):
*/
BEGIN
	SET NOCOUNT ON;	

	UPDATE dbo.IPTableLog WITH(ROWLOCK)
	SET		IsNewUpdate = 0
	WHERE	IPType = @IPType
			AND IsNewUpdate = 1;

	INSERT INTO IPTableLog(IPType, UpdatedDate, IsNewUpdate)
	VALUES(	@IPType
			, GETDATE()
			, 1
			);
END;

GO
/*<info serverAlias="IPDB" executers="bodbAdminNet" isFunction="0" isNested="0"></info>*/