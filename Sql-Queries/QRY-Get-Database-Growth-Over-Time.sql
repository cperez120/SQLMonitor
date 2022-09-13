use DBA
go

declare @object_name varchar(255);
declare @sql nvarchar(max);
declare @databases nvarchar(max);

set @object_name = (case when @@servicename = 'MSSQLSERVER' then 'SQLServer' else 'MSSQL$'+@@servicename end);

if object_id('tempdb..#FileSize') is not null drop table #FileSize;
select [time] = convert(date,pc.collection_time_utc), instance, [counter]
	--,object, counter, instance
	,[size(kb)] = avg(pc.value)
into #FileSize
from dbo.vw_performance_counters pc with (nolock)
where 1=1
--and pc.collection_time_utc between DATEADD(day,-5,getutcdate()) and getutcdate()
and  pc.object = (@object_name+':Databases') 
and pc.counter in ('Log File(s) Size (KB)',--'Log File(s) Used Size (KB)', 'Data File(s) Used Size (KB)',
				'Data File(s) Size (KB)')
group by convert(date,pc.collection_time_utc), instance, [counter];

if object_id('tempdb..#DatabaseSize') is not null drop table #DatabaseSize;
select [Date] = [time], [Database] = instance, 
		[LogSize_gb] = ceiling([Log File(s) Size (KB)]/1024/1024), 
		[DataSize_gb] = ceiling([Data File(s) Size (KB)]/1024/1024),
		[TotalSize_gb] = ceiling(([Log File(s) Size (KB)]+[Data File(s) Size (KB)])/1024/1024)
into #DatabaseSize
from #FileSize up
pivot ( max([size(kb)]) for [counter] in ([log file(s) size (kb)],[Data File(s) Size (KB)]) ) as pvt
order by 1, 2;

select @databases = coalesce(@databases + ', '+ quotename(name), quotename(name)) 
from sys.databases order by name;

set quoted_identifier off;
set @sql = "
select [Query] = 'Db-Size-Over-Time-GB', [Server] = @@servername, [Date], "+@databases+"
from (select [Date], [Database], [TotalSize_gb]   from #DatabaseSize) up
pivot ( max([TotalSize_gb]) for [Database] in ("+@databases+") ) pvt
order by 1"
set quoted_identifier off;

exec sp_ExecuteSql @sql;
go

