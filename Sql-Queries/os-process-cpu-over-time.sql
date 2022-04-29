use DBA
go

select top 5 tl.collection_time_utc, tl.host_name, tl.task_name, cpu_time, memory_kb from dbo.os_task_list tl
--select * from dbo.os_task_list tl where tl.task_name like 'sqlservr.exe'
--select * from dbo.performance_counters where path like '%process%'

-- DROP VIEW [dbo].[vw_os_task_list_cpu_deltas];
CREATE VIEW [dbo].[vw_os_task_list_cpu_deltas] 
WITH SCHEMABINDING 
AS
WITH RowDates as ( 
	SELECT ROW_NUMBER() OVER (ORDER BY [collection_time_utc], [host_name]) ID, [collection_time_utc], [host_name]
	FROM [dbo].[os_task_list] 
	GROUP BY [collection_time_utc], [host_name]
)
, collection_time_utcs as
(	SELECT ThisDate.collection_time_utc, LastDate.collection_time_utc as Previouscollection_time_utc, ThisDate.host_name
    FROM RowDates ThisDate
    JOIN RowDates LastDate
    ON ThisDate.ID = LastDate.ID + 1
	AND ThisDate.host_name = LastDate.host_name
)
, cte_task_list as 
(	SELECT collection_time_utc, host_name, task_name, [cpu_s] = sum(cpu_time_seconds), [counts] = count(*)
	FROM [dbo].[os_task_list]
	GROUP BY collection_time_utc, host_name, task_name
)
-- select * from collection_time_utcs
SELECT	tl.collection_time_utc, tl.host_name, tl.task_name
		,DATEDIFF(ss, wPrior.collection_time_utc, tl.collection_time_utc) AS elapsed_seconds
		,(tl.[cpu_s] - wPrior.[cpu_s]) AS cpu_seconds_delta
		,(tl.[counts] - wPrior.[counts]) AS [counts_delta]
FROM cte_task_list tl
INNER JOIN collection_time_utcs Dates
ON Dates.collection_time_utc = tl.collection_time_utc AND Dates.host_name = tl.host_name
INNER JOIN cte_task_list wPrior ON tl.host_name = wPrior.host_name and tl.task_name = wPrior.task_name AND Dates.Previouscollection_time_utc = wPrior.collection_time_utc
WHERE tl.host_name = wPrior.host_name
--ORDER BY tl.collection_time_utc, tl.host_name, cpu_seconds_delta desc
GO

