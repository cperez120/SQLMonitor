use DBA
go

select *
from [dbo].[resource_consumption] rc
go

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