/*
1) Create a folder on Grafana named "SQLServer". This name is case sensitive.
2) Then import all the dashboards using *.json files into The SQLServer folder created above.
3) Select appropriate Data Source

https://grafana.com/docs/grafana/v9.0/variables/variable-types/global-variables/
https://grafana.com/docs/grafana/v9.0/variables/advanced-variable-format-options/
https://grafana.com/docs/grafana/v9.0/variables/syntax/

d/distributed_live_dashboard?var-server=${__data.fields.srv_name}
d/wait_stats?var-server=${server}
*/

Grafana Variables
--------------------

$__dashboard
$__timeFrom()
$__timeTo()
$__name
$__timeFilter(collection_time_utc)
collection_time_utc between $__timeFrom() and $__timeTo()

set @start_time_utc = dateadd(second,$sqlserver_start_time_utc/1000,'1970-01-01 00:00:00');

use DBA
go

select top 1 *
from dbo.vw_performance_counters
go

