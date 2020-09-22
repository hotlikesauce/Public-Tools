

--test
SELECT wells.WSN
                  ,wells.WELL_NAME
                  ,wells.WELL_SHORT_NAME
                  ,wells.CDP_FACILITY
                  ,wells.CYGNET_NAME
                  ,LLs.Latitude
                  ,LLs.Longitude
                  ,LLs.TvB
                     ,geometry::STGeomFromText('POINT('+convert(varchar(20),LLs.Longitude)+' '+convert(varchar(20),LLs.Latitude)+')', 4269) as WellShape
                     
                     INTO #WellKPI
                from (
                SELECT PETRA_WSN as WSN,WELL_NAME
                         ,CASE
                               WHEN WELL_SHORT_NAME IS NULL THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(WELL_NAME,'STUD HORSE BUTTE','SHB'),'YELLOW POINT','YP'),'CABRITO','CAB'),'JONAH FEDERAL','JF'),'CAB UNIT','CAB'),'CORONA','COR'),'ANTELOPE','ANT'),'HACIENDA','HAC'),'SOL UNIT','SOL'),'SAG UNIT','SAG'),'RAINBOW','RB'), 'RBOW', 'RB'), 'CRIM STATE','CRIMSON'),'CAB UNIT','CAB')
                               WHEN (WELL_NAME LIKE ('%STUD%') AND WELL_SHORT_NAME NOT LIKE ('%SHB%')) OR (WELL_NAME LIKE ('%CABRITO%') AND WELL_SHORT_NAME NOT LIKE ('%CAB%')) THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(WELL_NAME,'STUD HORSE BUTTE','SHB'),'YELLOW POINT','YP'),'CABRITO','CAB'),'JONAH FEDERAL','JF'),'CAB UNIT','CAB'),'CORONA','COR')
                                  ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'  ',' '),'CABRITO','CAB'),'HACIENDA','HAC'),'CAB UNIT','CAB'), 'RBOW', 'RB'), 'SAG UNIT','SAG'),'SOL UNIT','SOL'),'COR SHB','SHB')
                               end as WELL_SHORT_NAME
                         ,REPLACE(REPLACE(CDP_FACILITY,'ACDP','CDP'),' ','') AS CDP_FACILITY,WELL_CLASS,
                         CASE
                               WHEN WELL_SHORT_NAME LIKE ('SHB%') and PETRA_WSN NOT IN ('95024','95025','95033','98209','95032','98199') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'SHB','S'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%JF%') THEN REPLACE(REPLACE(WELL_SHORT_NAME,' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%YP%') and WELL_SHORT_NAME not like ('%YP #-%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,' ',''),'-',''),'28109','')
                               WHEN WELL_SHORT_NAME LIKE ('%COR%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'COR ','CO'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%SAG%') THEN REPLACE(REPLACE(WELL_SHORT_NAME,' ',''),'-','')
							   WHEN WELL_SHORT_NAME LIKE ('%SDF%') THEN REPLACE(REPLACE(WELL_SHORT_NAME,' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%ANT%') AND WELL_SHORT_NAME NOT IN ('ANT ENERGY 313-20H') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'ANT ','ANT'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%HF%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'HF ','HF'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%HAC%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'HAC ','HA'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%SOL%') AND WELL_SHORT_NAME NOT LIKE ('%UNIT%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'SOL ','SOL'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('CF%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'CF ','CF'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('SL%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'SL ','SL'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('GK%') AND WELL_SHORT_NAME NOT IN ('GK 01','GK 02') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'GK ','GKFED'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('%GK 0%') THEN REPLACE(WELL_SHORT_NAME,'GK 0','GKFED')
                               WHEN WELL_SHORT_NAME LIKE ('HS%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'HS ','HS'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('SCAR FED%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'SCAR FED ','SC'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('TOT FED%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'TOT FED ','TF'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('TOT UNIT%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'TOT UNIT ','TF'),' ',''),'-','')
                               WHEN WELL_SHORT_NAME LIKE ('WARDELL FED%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'WARDELL FED ','WA'),' ',''),'-','')

                                  
                                  
                                  
                                  
                               WHEN WELL_NAME LIKE ('%ANTELOPE%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,'ANTELOPE ','ANT'),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('%CRIMSON STATE%') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'CRIM STATE ','CS'),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('%STUD HORSE BUTTE%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,'STUD HORSE BUTTE ','S'),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('%CRIMSON UNIT%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,'CRIMSON UNIT ','CU'),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('%CRIMSON UNIT 02-18%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,'CRIMSON UNIT ','CF'),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('TOT UNIT%') THEN (REPLACE(WELL_NAME,'TOT UNIT ','TF'))
                               WHEN WELL_NAME LIKE ('SAG UNIT%') THEN (REPLACE(WELL_NAME,'SAG UNIT ','SAG0'))
                               WHEN WELL_NAME LIKE ('SOL UNI%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,' UNIT ',''),' ',''),'-','')
                               WHEN WELL_NAME LIKE ('%RAINBOW%') THEN REPLACE(REPLACE(REPLACE(WELL_NAME,'RAINBOW ','RB'),' ',''),'-','')
                                  

                                --FORCE BY WSN
                                WHEN WELL_SHORT_NAME LIKE ('CAB%') and PETRA_WSN NOT IN ('42657','30094','42659','72778','74564') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'CAB ','CA'),' ',''),'-','')
                                WHEN WELL_NAME LIKE ('%CABRITO%') and PETRA_WSN NOT IN ('42657','30094','42659','72778','74564') THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'CAB ','CA'),' ',''),'-','')
                                WHEN WELL_SHORT_NAME LIKE ('CUR%') and PETRA_WSN NOT IN ('95024','95025','95033','98209','95032','98199')THEN REPLACE(REPLACE(REPLACE(WELL_SHORT_NAME,'- ','0'),' ',''),'-','')

                                WHEN PETRA_WSN = '42657' THEN 'CA11325'
                                WHEN PETRA_WSN = '30094' THEN 'CA1119'
                                WHEN PETRA_WSN = '42659' THEN 'CA11425'
                                WHEN PETRA_WSN = '72778' THEN 'CA30I2'
                                WHEN PETRA_WSN = '74564' THEN 'CA7413'
                                WHEN PETRA_WSN  like ('80124') THEN 'ANT31320H'

                                --Set up because Curiosity Predrills aren't in completion yet
                                WHEN PETRA_WSN = '95024' THEN 'CUR31202500H'
                                WHEN PETRA_WSN = '95025' THEN 'CUR31302500H'
                                WHEN PETRA_WSN = '95033' THEN 'CUR34402100H'
                                WHEN PETRA_WSN = '98209' THEN 'CUR34402300H'
                                WHEN PETRA_WSN = '95032' THEN 'CUR34402500H'
								WHEN PETRA_WSN = '98199' THEN 'CUR34102500H'


                               end as CYGNET_NAME
                            FROM ODSSQL.ODS.Enerhub.Golden_Record_Well a
                            JOIN ODSSQL.ODS.Enerhub.Golden_Record_Wellbore b
                            ON a.UWI = b.UWI_WELL
                            JOIN ODSSQL.ODS.Enerhub.Golden_Record_Completion c
                            ON b.UWI = c.UWI_WELLBORE
                            JOIN ODSSQL.Aries.afwadmin.AC_PROPERTY d
                            on a.uwi = d.COST_CENTER_NO) as wells

                LEFT JOIN (SELECT * FROM [ODSSQL].[ODS].[GIS].[LatLongInputs]) LLs on wells.WSN = LLs.WSN
                           --where wells.wsn LIKE ('%95024%')

create table #CDPAll (
Shape geometry null
,WSN int null
,Well_Name varchar(120) null
,Latitude float null
,Longitude float null
,TvB varchar(3)
,WELL_SHORT_NAME varchar(55) null
,CYGNET_NAME varchar(55) null
)



INSERT INTO #CDPAll
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CYGNET_NAME
FROM #WellKPI
) A
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('%%') THEN CONCAT(CYGNET_NAME,'CDP')
END AS CYGNET_NAME
FROM #WellKPI
) B
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'FG')
END AS CYGNET_NAME
FROM #WellKPI
) C
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'COMP1FG')
END AS CYGNET_NAME
FROM #WellKPI
) D
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'COMP2FG')
END AS CYGNET_NAME
FROM #WellKPI
) E
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'COMP3FG')
END AS CYGNET_NAME
FROM #WellKPI
) F
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'D')
END AS CYGNET_NAME
FROM #WellKPI
) G
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'ACDP')
END AS CYGNET_NAME
FROM #WellKPI
) H
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'CHILLFG')
END AS CYGNET_NAME
FROM #WellKPI
) I
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'COMPCHILLFG')
END AS CYGNET_NAME
FROM #WellKPI
) J
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'COMPCHILLFG1')
END AS CYGNET_NAME
FROM #WellKPI
) K
--UNION ALL
--SELECT * FROM (
--SELECT 
--WellShape AS SHAPE
--,WSN
--,Well_Name
--,Latitude
--,Longitude
--,TvB
--,WELL_SHORT_NAME
--,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'B')
--END AS CYGNET_NAME
--FROM #WellKPI
--) L
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'X')
END AS CYGNET_NAME
FROM #WellKPI
) M
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'CDP2')
END AS CYGNET_NAME
FROM #WellKPI
) N
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'CDPFG')
END AS CYGNET_NAME
FROM #WellKPI
) O
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'CHK')
END AS CYGNET_NAME
FROM #WellKPI
) P
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'MUFG')
END AS CYGNET_NAME
FROM #WellKPI
) Q
UNION ALL
SELECT * FROM (
SELECT 
WellShape AS SHAPE
,WSN
,Well_Name
,Latitude
,Longitude
,TvB
,WELL_SHORT_NAME
,CASE WHEN WELL_SHORT_NAME LIKE ('% %') THEN CONCAT(CYGNET_NAME,'BCDP')
END AS CYGNET_NAME
FROM #WellKPI
) R




SELECT * 
INTO #WGPTable
FROM ArcGis_Master.DBO.Anadarko_Marketing_NAD83



ALTER TABLE #WGPTable ADD  CONSTRAINT [KDBC] PRIMARY KEY CLUSTERED 
(
       OBJECTID_1 ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]

CREATE SPATIAL INDEX [OSXY] ON #WGPTable
(
       [Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



TRUNCATE TABLE [ArcGis_Master].[dbo].[CYGNET_NAMES_BHL]
INSERT INTO [ArcGis_Master].[dbo].[CYGNET_NAMES_BHL] (OBJECTID, SHAPE, WSN,WELL_NAME,WELL_SHORT_NAME,CYGNET_NAME,LATITUDE,LONGITUDE,TvB,DEDICATION,LIMIT)
select ROW_NUMBER() OVER(ORDER BY WSN,CYGNET_NAME ASC) as OBJECTID
,#CDPAll.Shape
,WSN
,WELL_NAME
,WELL_SHORT_NAME
,CYGNET_NAME
,LATITUDE
,LONGITUDE
,TvB
,CASE WHEN #CDPAll.SHAPE.STIntersects(#WGPTable.Shape) = 1 THEN 'WGP'
WHEN #CDPAll.SHAPE.STIntersects(#WGPTable.Shape) = 0 THEN 'Enterprise'
END AS DEDICATION
,CASE WHEN #CDPAll.SHAPE.STIntersects(#WGPTable.Shape) = 1 THEN '750'
WHEN #CDPAll.SHAPE.STIntersects(#WGPTable.Shape) = 0 THEN '250'
END AS LIMIT
from #CDPAll,#WGPTable 
WHERE TvB = 'BH' --AND CYGNET_NAME LIKE ('%4613%')

ORDER BY WELL_NAME

--ALTER TABLE [ArcGis_Master].[dbo].[CYGNET_NAMES]
--add DEDICATION varchar(50) null
--,LIMIT int null



drop table #WELLKPI
drop table #CDPAll
drop table #WGPTable
--drop table #WSNLIST
