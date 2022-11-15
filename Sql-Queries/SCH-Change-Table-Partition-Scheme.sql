use DBA
go

if exists (select * from sys.indexes i where i.object_id = OBJECT_ID('dbo.disk_space') and i.name = 'pk_disk_space')
begin
	alter table dbo.disk_space drop constraint pk_disk_space;
end
go

exec sp_BlitzIndex @DatabaseName = 'DBA', @TableName = 'disk_space'
go

alter table dbo.disk_space add constraint pk_disk_space primary key ([collection_time_utc],[host_name],[disk_volume]) on ps_dba_datetime2_daily ([collection_time_utc])
go

exec usp_enable_page_compression @verbose = 2, @dry_run = 0;
go
