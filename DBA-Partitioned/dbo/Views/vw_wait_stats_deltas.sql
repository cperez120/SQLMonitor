-- DROP VIEW [dbo].[vw_wait_stats_deltas];
CREATE VIEW [dbo].[vw_wait_stats_deltas] 
WITH SCHEMABINDING 
AS
WITH RowDates as ( 
	SELECT ROW_NUMBER() OVER (ORDER BY [collection_time_utc]) ID, [collection_time_utc]
	FROM [dbo].[wait_stats] 
	--WHERE [collection_time_utc] between @start_time and @end_time
	GROUP BY [collection_time_utc]
)
, collection_time_utcs as
(	SELECT ThisDate.collection_time_utc, LastDate.collection_time_utc as Previouscollection_time_utc
    FROM RowDates ThisDate
    JOIN RowDates LastDate
    ON ThisDate.ID = LastDate.ID + 1
)
--select * from collection_time_utcs
SELECT w.collection_time_utc, w.wait_type, COALESCE(wc.WaitCategory, 'Other') AS WaitCategory, COALESCE(wc.Ignorable,0) AS Ignorable
, DATEDIFF(ss, wPrior.collection_time_utc, w.collection_time_utc) AS ElapsedSeconds
, (w.wait_time_ms - wPrior.wait_time_ms) AS wait_time_ms_delta
, (w.wait_time_ms - wPrior.wait_time_ms) / 60000.0 AS wait_time_minutes_delta
, (w.wait_time_ms - wPrior.wait_time_ms) / 1000.0 / DATEDIFF(ss, wPrior.collection_time_utc, w.collection_time_utc) AS wait_time_minutes_per_minute
, (w.signal_wait_time_ms - wPrior.signal_wait_time_ms) AS signal_wait_time_ms_delta
, (w.waiting_tasks_count - wPrior.waiting_tasks_count) AS waiting_tasks_count_delta
FROM [dbo].[wait_stats] w
--INNER HASH JOIN collection_time_utcs Dates
INNER JOIN collection_time_utcs Dates
ON Dates.collection_time_utc = w.collection_time_utc
INNER JOIN [dbo].[wait_stats] wPrior ON w.wait_type = wPrior.wait_type AND Dates.Previouscollection_time_utc = wPrior.collection_time_utc
LEFT OUTER JOIN [dbo].[BlitzFirst_WaitStats_Categories] wc ON w.wait_type = wc.WaitType
WHERE [w].[wait_time_ms] >= [wPrior].[wait_time_ms]
--ORDER BY w.collection_time_utc, wait_time_ms_delta desc
