CREATE PROCEDURE [dbo].[GetAllIPv6Location]
AS
/*
	Created: 20190627@CaseyHuynh
	Task : Get All IPv6Location
	DB: IPDB
	Original:

	Revisions:

	Param's Explanation (filtered by):
*/
BEGIN
	SET NOCOUNT ON;	

	SELECT	ip.ip_from			AS FromIP
			, ip.ip_to			AS ToIP
			, ip.country_code	AS CountryCode
			, ip.country_name	AS CountryName
			, ip.region			AS Region
			, ip.city			AS City
			, ip.isp_name		AS ISPName
	FROM	IPv62Location ip WITH(NOLOCK)

END;

GO
/*<info serverAlias="IPDB" executers="bodbAdminNet" isFunction="0" isNested="0"></info>*/