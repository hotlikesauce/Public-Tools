CREATE TABLE #SpacingSJ ( 
ID varchar(255) null
,Well_Count int null
,Well_Max int null
,Remaining int null
--,GEOM geometry null

)

CREATE TABLE #SpacingSJCalcs ( 
ID varchar(255) null
,Remaining int null

)


Select *
into #Wells
FROM [db].[sch].[tb]

SELECT * 
INTO #SpacingTable from [db].[sch].[tb]

SELECT * 
INTO #SpacingQQs from [db].[sch].[tb]

SELECT * 
INTO #StandardSpacing FROM [db].[sch].[tb]
------------------------------

ALTER TABLE #Wells ADD  CONSTRAINT [LFC] PRIMARY KEY CLUSTERED 
(
       OBJECTID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]

CREATE SPATIAL INDEX [AGS] ON #Wells
(
       [Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

------------------------------

ALTER TABLE #SpacingTable ADD  CONSTRAINT [XYZ] PRIMARY KEY CLUSTERED 
(
       OBJECTID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]

CREATE SPATIAL INDEX [ABC] ON #SpacingTable
(
       [Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

------------------------------

ALTER TABLE #StandardSpacing ADD  CONSTRAINT [ZSD] PRIMARY KEY CLUSTERED 
(
       OBJECTID_1 ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]

CREATE SPATIAL INDEX [ERS] ON #StandardSpacing
(
       [Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

------------------------------

ALTER TABLE #SpacingQQs ADD  CONSTRAINT [AAA] PRIMARY KEY CLUSTERED 
(
       OBJECTID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]

CREATE SPATIAL INDEX [TTT] ON #SpacingQQs
(
       [Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

------------------------------

SELECT #Wells.WSN, #Wells.API, #Wells.WELL_NAME,
CASE
WHEN #Wells.WELL_SHORT_NAME NOT LIKE ('%H') THEN REPLACE(REPLACE(#Wells.WELL_SHORT_NAME,' 0',' '),'-0','-')
ELSE #Wells.Well_SHORT_NAME
END AS WELL_SHORT_NAME, #Wells.LATITUDE, #Wells.LONGITUDE, #Wells.TvB, #Wells.FIRST_PRODUCTION_DATE, #SpacingTable.Spacing_Type, #SpacingTable.Well_Maximum, #Wells.Shape INTO #JonahWells
FROM #Wells, #SpacingTable
where #Wells.Shape.STIntersects(#SpacingTable.Shape) = 1


UPDATE #JonahWells
SET Spacing_Type = CASE
						 WHEN WELL_NAME LIKE ('%2##-#%') THEN 'Boundary Line'
						 WHEN WELL_NAME LIKE ('%H') and WELL_NAME not LIKE ('%FKA%') THEN 'Horizontal'
						 --THE NEXT FEW ARE HARD CODED BECAUSE I COULDN'T QUERY THEM OUT, DUE TO MY OWN INEPTITUDE PROBABLY
						 WHEN WELL_SHORT_NAME IN ('SHB 113-16','SHB 122-9','SHB 126-4') THEN 'Exception'
						 WHEN FIRST_PRODUCTION_DATE <'1/1/2011' AND Spacing_Type = 'Boundary Line' THEN 'Exception'
						 else Spacing_Type
						 end

UPDATE ST
			SET ST.Spacing_Type = ST2.Spacing_Type 
			FROM #JonahWells ST
			INNER JOIN #JonahWells ST2 ON ST.WSN = ST2.WSN 
			WHERE ST2.TvB = 'BH'


INSERT INTO #SpacingSJ			
SELECT #SpacingQQs.ID as ID
,Count(*) as Well_Count
,#SpacingQQs.FIRST_Well_Maximum as Well_Max
,null as Remaining
FROM #JonahWells
JOIN #SpacingQQs
ON #SpacingQQs.Shape.STContains(#JonahWells.Shape) = 1
where #JonahWells.Spacing_Type IN ('Standard','Exception') and #JonahWells.TvB = 'BH'
GROUP BY #SpacingQQs.ID,#SpacingQQs.FIRST_Well_Maximum

insert into #SpacingSJCalcs
SELECT ID,
SUM(Well_Max + -Well_Count) as Remaining
from #SpacingSJ
group by #SpacingSJ.ID

--HERE IS THE FINAL SELECTION FOR THE SPACING SETBACKS
TRUNCATE TABLE [ArcGis_Master].[dbo].[Vertical_Spacing_Counts]
INSERT INTO [ArcGis_Master].[dbo].[Vertical_Spacing_Counts] (OBJECTID,ID,Well_Count,Well_Max,Wells_Remaining,SHAPE)
select ROW_NUMBER() OVER(ORDER BY #StandardSpacing.ID  ASC) as OBJECTID
,#StandardSpacing.ID as ID
,#StandardSpacing.Well_Maximum as Well_Max
,CASE 
WHEN #SpacingSJ.Well_Count IS NULL THEN 0 
ELSE #SpacingSJ.Well_Count
end as Well_Count
,CASE
 WHEN #SpacingSJCalcs.Remaining IS NULL THEN #StandardSpacing.Well_Maximum
 else #SpacingSJCalcs.Remaining
 end as Remaining
 ,#StandardSpacing.Shape as SHAPE

from #StandardSpacing
left join #SpacingSJ on #StandardSpacing.ID = #SpacingSJ.ID
left join #SpacingSJCalcs on #StandardSpacing.ID = #SpacingSJCalcs.ID
--The below query-outs are for Ultra sections
where #StandardSpacing.ID  is not null
--AND #StandardSpacing.ID  NOT LIKE ('%2910823%')
--AND #StandardSpacing.ID  NOT LIKE ('%2910824%')
--AND #StandardSpacing.ID  NOT LIKE ('%2910821%')
--AND #StandardSpacing.ID  NOT LIKE ('%2910814SWSW%')



drop table #Wells
drop table #SpacingTable
drop table #SpacingQQs
drop table #SpacingSJ
drop table #SpacingSJCalcs
drop table #StandardSpacing
drop table #JonahWells



