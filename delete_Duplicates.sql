--This script will delete duplicates of records
--define which field you want to iterate over (A)... or multiple rows like (A,B)
--set the row count of the fields you define as RN
--Delete all records which have a row count >1 

WITH CTE AS(
   SELECT A 
       RN = ROW_NUMBER()OVER(PARTITION BY A ORDER BY A)
	   FROM [database].[schema].[table]
	)
	delete FROM CTE WHERE RN > 1

--Can be done with multiple fields
WITH CTE AS(
   SELECT A,B
       RN = ROW_NUMBER()OVER(PARTITION BY A,B ORDER BY A,B)
	   FROM [database].[schema].[table]
	)
	delete FROM CTE WHERE RN > 1