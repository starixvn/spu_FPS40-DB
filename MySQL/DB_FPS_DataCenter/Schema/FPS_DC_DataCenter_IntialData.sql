/*
Creator: 20190521@Casey.Huynh
Task:    Data Center - Initial Data
Server:  
DBName:	FPS_DataCenter

Reviewer: 
*/

USE FPS_DataCenter;

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
            , 1136548044	AS	UserAgentID
            , 0				AS	FirstStagingTransID
            , '2011-01-01'	AS	CreatedDate
            , 0				AS	DeviceStatus
            , '2011-01-01'	AS InsertTime;


