DECLARE @json NVARCHAR(MAX) 


set @json = '""" + str(jsonText) + """'



select * into #table1
FROM OPENJSON(@json)
WITH (
COREID	VARCHAR(200) '$.coreId',
TIMESTAMP DATETIME '$.TimeStamp',
SITEID VARCHAR(10) '$.siteId',
COMPANYID VARCHAR(10) '$.companyId',
LOOKUPNAME VARCHAR(10) '$.LookupName',
LATITUDE VARCHAR(200) '$.FixedLatitude',
LONGNITUDE VARCHAR(200) '$.FixedLongitude',
--O3 VARCHAR(200) 'null',
TVOC VARCHAR(200) '$.TVOC.value',
--NO2 VARCHAR(200) 'null',
WINDDIRECTION VARCHAR(200) '$.WindDirection.value',
WINDSPEED VARCHAR(200) '$.WindSpeed.value',
INTERNALTEMPERATURE VARCHAR(200) '$.InternalTemperature.value',
INTERNALHUMIDITY VARCHAR(200) '$.InternalHumidity.value',
SIGNAL VARCHAR(200) '$.Signal.value',
PUBLISHED VARCHAR(200) '$.Published',
RECIVED VARCHAR(200) '$.Received',
POSITION VARCHAR(200) '$.Position',
DISTANCE VARCHAR(200) '$.Distance.value',
BEARING VARCHAR(200) '$.Bearing.value'

)

INSERT INTO [database].[schema].[table]
select COREID
,TIMESTAMP
,SITEID
,COMPANYID
,LOOKUPNAME
,LATITUDE
,LONGNITUDE
,NULL AS O3
,TVOC
,NULL AS NO2
,WINDDIRECTION
,WINDSPEED
,INTERNALTEMPERATURE
,INTERNALHUMIDITY
,SIGNAL
,PUBLISHED
,RECIVED
,POSITION
,DISTANCE
,BEARING
from #table1
DROP TABLE #table1