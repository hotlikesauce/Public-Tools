--Select all VGY values. This table will then be used in an inner join later to get the previous day's VGY values
SELECT *
INTO #VGY_Today FROM [ODSSQL].[CygNet].[PBI].[VGY_ADJ_1DAY] WHERE Date >= DATEADD(day,-2, GETDATE()) 

--Add a column to hold the previous day's date
ALTER TABLE #VGY_Today
ADD Date_Previous_Day Date

--Calculate the previous day's date
UPDATE #VGY_Today
SET Date_Previous_Day = DATEADD(Day, -1, DATE)

--Create another table to be used in the inner join
SELECT *
INTO #VGY_Yesterday FROM [ODSSQL].[CygNet].[PBI].[VGY_ADJ_1DAY] WHERE Date >= DATEADD(day,-2, GETDATE())

--Join the same table to itself on the previous day column- this allows for the previous day's VGY values to be shown alongside the current day's VGY value
SELECT a.Facility, a.Date, a.VGY_ADJ_1DAY, a.Date_Previous_Day, b.VGY_ADJ_1DAY as VGY_ADJ_1DAY_Previous_Day
INTO #Results
FROM #VGY_Today a
JOIN
#VGY_Yesterday b
ON
a.Facility = b.Facility AND
a.Date_Previous_Day = b.DATE

--Add a column to contain the difference between the VGY and the previous day's VGY
ALTER TABLE #Results
ADD VGY_Difference Float

--Calculate the difference between the VGY's
UPDATE #Results
SET VGY_Difference = VGY_ADJ_1DAY - VGY_ADJ_1DAY_Previous_Day 

--Join the result set created above to the CYGNET_NAMES table in ArcGis_Master so that the VGY differences can be mapped
Select *
INTO #FinalResults
FROM [ArcGis_Master].[dbo].[CYGNET_NAMES_BHL] a
JOIN
#Results b
ON
a.CYGNET_NAME = b.Facility
WHERE a.CYGNET_NAME NOT LIKE ('%FG%')

--Drop the excess columns as a result of the join above
ALTER TABLE #FinalResults
DROP COLUMN Facility


--CALCULATE VGYs over past 2 weeks
--Get the past two weeks of VGY values and assign a row number by facility
SELECT [Facility]
      ,[DATE]
      ,[VGY_ADJ_1DAY]
      ,ROW_NUMBER() OVER(PARTITION BY Facility ORDER BY DATE ASC) AS RowNum
  INTO #TwoWeeks
  FROM [ODSSQL].[CygNet].[PBI].[VGY_ADJ_1DAY]
  WHERE Date >= DATEADD(Day, -14, GETDATE())


--Get last 2 week's VGY values
SELECT Facility, Date, VGY_ADJ_1DAY, RowNum
INTO #LastWeek
FROM #TwoWeeks


--Average 2 week ago VGY values  
SELECT [Facility]
    ,[DATE]
    ,[VGY_ADJ_1DAY]
    ,AVG([VGY_ADJ_1DAY]) OVER(PARTITION BY Facility ORDER BY DATE ASC) AS VGY_LastWeek_Avg
INTO #ResultsLastWeek
FROM #LastWeek
where RowNum >7

--Average 2 week ago VGY values  
SELECT [Facility]
    ,[DATE]
    ,[VGY_ADJ_1DAY]
    ,AVG([VGY_ADJ_1DAY]) OVER(PARTITION BY Facility ORDER BY DATE ASC) AS VGY_2Weeks_Avg
INTO #Results2Weeks
FROM #LastWeek
where RowNum <=7



--Select only the records from 8 days ago. This is the row that contains the average VGY per facility for days 8-14 from the current date
DECLARE @EightDaysAgo date = DATEADD(Day, -7, GETDATE())
SELECT FACILITY,
VGY_2Weeks_Avg as VGY_2Weeks
INTO #ResultSet_2Weeks
FROM #Results2Weeks
WHERE DATE = @EightDaysAgo AND FACILITY NOT LIKE ('%FG%')
ORDER BY Facility


DECLARE @Today date = GETDATE()
SELECT FACILITY,
VGY_LastWeek_Avg as VGY_LastWeek
INTO #ResultSet_LastWeek
FROM #ResultsLastWeek
WHERE DATE = @Today AND FACILITY NOT LIKE ('%FG%')
ORDER BY Facility


select LW.FACILITY, ROUND(LW.VGY_LastWeek,2) AS VGY_LastWeek,round(TW.VGY_2Weeks,2) as VGY_2Weeks ,round(VGY_LastWeek-VGY_2Weeks,2) as WeeklyVariance  into #WeeklyVGY from #ResultSet_LastWeek LW
join #ResultSet_2Weeks TW
on LW.FACILITY = TW.FACILITY




--APPEND TO MASTER
TRUNCATE TABLE [ArcGis_Master].[dbo].[VGY]
INSERT INTO [ArcGis_Master].[dbo].[VGY] (OBJECTID, WSN,WELL,CYGNET_NAME,DATE,VGY,DATE_PREVIOUS,VGY_PREV_DAY,VARIANCE,VGY_LASTWEEK,VGY_2WEEKS,WEEKLY_VARIANCE,SHAPE)
SELECT ROW_NUMBER() OVER(ORDER BY FR.WSN  ASC) as OBJECTID
,FR.WSN
,FR.WELL_SHORT_NAME AS WELL
,FR.CYGNET_NAME
,FR.DATE
,round(FR.VGY_ADJ_1DAY,2) as VGY
,FR.Date_Previous_Day AS DATE_PREVIOUS
,round(FR.VGY_ADJ_1DAY_Previous_Day,2) as VGY_PREV_DAY
,round(FR.VGY_Difference,2) as VARIANCE
,WV.VGY_LastWeek
,WV.VGY_2Weeks
,WV.WeeklyVariance
,SHAPE
FROM #FinalResults FR
LEFT JOIN #WeeklyVGY WV
ON FR.CYGNET_NAME = WV.FACILITY


DROP TABLE #VGY_Today
DROP TABLE #VGY_Yesterday
DROP TABLE #Results
DROP TABLE #FinalResults

--table drops for past 2 weeks calc
drop table #TwoWeeks, #LastWeek, #ResultsLastWeek, #Results2Weeks, #ResultSet_2Weeks,#ResultSet_LastWeek,#WeeklyVGY

