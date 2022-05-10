use DBA
go

declare @issue_start_time datetime2 = '2022-05-10 23:30:00.000'
declare @issue_end_time datetime2 = sysdatetime()
select	*
from dbo.resource_consumption rc
where 1 = 1
and (  rc.start_time between @issue_start_time and @issue_end_time
	or rc.event_time between @issue_start_time and @issue_end_time
	)
order by start_time

/*
use StackOverflow2013
go

exec usp_RandomQ
go
*/

/*
$sqlInstance= 'Workstation'
$query = 'usp_RandomQ'

Invoke-DbaQuery `
        -SqlInstance $sqlInstance `
        -Query $query `
        -Database StackOverflow2013 `
        -CommandType StoredProcedure

*/