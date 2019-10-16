/*
Creator: 20190521@Casey.Huynh
Task:    Data Center - Initial Data
Server:  
DBName:	FPS_DataCenter

Reviewer: 
*/

USE FPS_DataCenter;

INSERT INTO FPS_DataCenter.ActionResult(ActionResultID, ActionResultKey, ActionStatus, CreatedDate)
VALUES (0,'',1,'2011-01-01')
		, (1521261242,'login -> successfully',1,'2011-01-01')
        , (1862328242,'success',1,'2011-01-01')
        , (3686301690,'successfully',1,'2011-01-01')
        , (2250713929,'fail',1,'2011-01-01');

INSERT INTO FPS_DataCenter.OS(OSName, CreatedDate)
SELECT		'' AS 'OSName'
            , '2011-01-01';

INSERT INTO FPS_DataCenter.Browser(BrowserName, CreatedDate)
SELECT		'' AS 'BrowserName'
            , '2011-01-01';

INSERT INTO FPS_DataCenter.UserAgent(UserAgentID, UserAgent, BrowserID, OSID, OS, Browser, CreatedDate)
SELECT		0			AS UserAgentID
			, ''		AS UserAgent
            , 1			AS BrowserID
            , 1			AS OSID
            , ''		AS OS
            , ''		AS Browser
            , '2011-01-01' AS CreatedDate;

INSERT INTO FPS_DataCenter.Device(DeviceID, FirstDeviceCode, UserAgentID, FirstStagingTransID, CreatedDate, DeviceStatus, InsertTime)
SELECT		0 				AS DeviceID
			, ''			AS FirstDeviceCode
            , 0				AS	UserAgentID
            , 0				AS	FirstStagingTransID
            , '2011-01-01'	AS	CreatedDate
            , 0				AS	DeviceStatus
            , '2011-01-01'	AS InsertTime;

INSERT INTO FPS_DataCenter.TransStatus(TransStatusName, StatusValue, Notes, IsTransformed, CreatedDate)
Values('Valid Transaction', b'0','', 1,CURRENT_DATE())
			,('Invalid Subscriber', b'1', 'Handle At SP FPS_DC_TransformData_UnhandleSubscriberAction', 0, CURRENT_DATE())
			,( 'Invalid Action Result', b'10', 'Handle At SP FPS_DC_TransformData_UnhandleSubscriberAction', 1,CURRENT_DATE())
            ,('Invalid Devicode_Empty', b'100', 'Handle At Web', 1,CURRENT_DATE())
            ,('Invalid Login Name', b'1000', 'Handle At Web', 0,CURRENT_DATE())
            ,('Invalid DI', b'10000', 'Handle At Web', 1,CURRENT_DATE());

