use DBA
go

select top 10 *
from dbo.disk_space ds
order by collection_time_utc, host_name, disk_volume