#---Step1: Insert Data to RawTrans

CALL RT_RawTrans_InsertByXML(
'<root>
	<transaction LoginName="Player001" SubscriberName="FPS" TransDate="2019-07-01 02:53:16" CreatedDate="2019-07-01"
		DeviceCode="NHFGCBEUFHRMSHFKEJCD" DeviceCodeStatus="0" 
		FingeringCode="e0f49101796e1d1d109cc9122b7bce34df1b435f;174518b467fe195603901fc36eae418f" 
        FingeringMoreInfo="eyJuYSI6Ik4vQSIsImRldmljZUNvZGUiOiJlMGY0OTEwMTc5NmUxZDFkMTA5Y2M5MTIyYjdiY2UzNGRmMWI0MzVmOzE3NDUxOGI0NjdmZTE5NTYwMzkwMWZjMzZlYWU0MThmIiwiYXBwVmVyc2lvbiI6IjUuMCAoV2luZG93cykiLCJ0aW1lWm9uZSI6Ii00ODAiLCJ1c2VyQWdlbnQiOiJNb3ppbGxhLzUuMCAoV2luZG93cyBOVCA2LjE7IFdPVzY0OyBydjo0NS4wKSBHZWNrby8yMDEwMDEwMSBGaXJlZm94LzQ1LjAiLCJzY3JlZW4iOnsid2lkdGgiOjE2MDAsImhlaWdodCI6OTAwLCJjb2xvckRlcHRoIjoyNH0sImRldmljZUlkIjoiZDI0NGZmNGEyZTM2NDA4ZmExYmI3MjRlMGNlNjcyY2QiLCJocmVmIjoiaHR0cDovL3d3dy5tYXhiZXQuY29tL0RlZmF1bHQuYXNweCIsImNhcHR1cmVkRGF0ZSI6IjYzNjIyMDAzMDMxNzMyMzYwOSJ9"
        UserAgent="HDHDHDNDHHKALLKDSLDSJDJSDJSD" IP="172.10.10.128" PluginID="42970728"  URL="https://fpsnew.com" ActionResult="login"
	/>
</root>');

SELECT *
FROM FPS_RawTrans.RawTransaction;