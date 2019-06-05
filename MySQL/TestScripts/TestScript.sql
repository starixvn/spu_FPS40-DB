
truncate table FPS_RawTrans.RawTransaction;
TRUNCATE TABLE FPS_RawTrans.StagingRawTransaction;

CALL RT_RawTrans_InsertByXML(
'<root>
<transaction DeviceCode="DV010001" LoginName="LoginName010001" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010002" LoginName="LoginName010002" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010003" LoginName="LoginName010003" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010004" LoginName="LoginName010004" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010005" LoginName="LoginName010005" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010006" LoginName="LoginName010006" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010007" LoginName="LoginName010007" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010008" LoginName="LoginName010008" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010009" LoginName="LoginName010009" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
<transaction DeviceCode="DV010010" LoginName="LoginName010010" SubscriberName="Subcriber01" TransDate="2019-05-29 00:05:37" IP="127.127.1.1" PluginID="1" DeviceStatus="0" URL="http//bcl.com" ActionResult="Login Successfully" UserAgent="BCL tap n" CapturedData="meo biet lam gi"/>
</root>');

SELECT * FROM FPS_RawTrans.RawTransaction;
SELECT * FROM FPS_RawTrans.StagingRawTransaction;
