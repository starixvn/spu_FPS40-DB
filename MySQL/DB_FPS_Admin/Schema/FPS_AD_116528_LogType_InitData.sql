USE `FPS_Admin`;
/*
		Created:	20190718@John.Ngo
		Task:		Initial Data for LogType [Redmine ID: 116528]
		DB:			FPS_Admin
		Original:

		Revisions:
		Param's Explanation (filtered by):
*/
LOCK TABLES `LogType` WRITE;

INSERT INTO `LogType` 
VALUES	(1,'Insert UserSubscriber','Insert UserSubscriber')
	,	(2,'Update UserSubscriber','Update UserSubscriber')
    ,	(3,'Delete UserSubscriber','Delete UserSubscriber');

UNLOCK TABLES;