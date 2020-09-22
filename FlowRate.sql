Select distinct(Facility) as Facility, max(RecordTime) as RecordTime
into #LinePressSolo
FROM [ODSSQL].[CygNet].[dbo].[FLOW_RATE] with (nolock)
group by Facility 


Select a.Facility,a.RecordTime,b.Value into #Combo from #LinePressSolo a
left outer join [ODSSQL].[CygNet].[dbo].[FLOW_RATE] b
on a.Facility = b.Facility and a.RecordTime = b.RecordTime
order by Facility

select distinct(Facility),max(RecordTime) as RecordTime ,max(Value) as Value into #LPSites from #Combo group by Facility

select ROW_NUMBER() OVER(ORDER BY Facility  ASC) as OBJECTID
,C.Facility
,C.RecordTime
,C.Value
,AGS.WELL_SHORT_NAME
,AGS.SHAPE
INTO #Spatial
from #LPSites C
LEFT OUTER JOIN [ArcGis_Master].[dbo].[CYGNET_NAMES] AGS
ON C.Facility = AGS.CYGNET_NAME


TRUNCATE TABLE [ArcGis_Master].[dbo].[CYGNET_FLOWRATE]
INSERT INTO [ArcGis_Master].[dbo].[CYGNET_FLOWRATE] (OBJECTID, SHAPE,Facility,RecordTime,Value,Well_Short_Name,Type)
select ROW_NUMBER() OVER(ORDER BY Facility  ASC) as OBJECTID
,Shape as SHAPE
,Facility
,RecordTime
,Value
,Well_Short_Name
,CASE WHEN Facility LIKE ('%CDP%') THEN 'CDP'
WHEN Facility LIKE ('%FG%') THEN 'Fuel Gas'
ELSE 'Well Head'
END AS Type
from #Spatial

drop table #LinePressSolo
drop table #Combo
drop table #LPSites
drop table #Spatial


