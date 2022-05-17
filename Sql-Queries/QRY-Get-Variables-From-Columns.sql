use tempdb;
go
select c.COLUMN_NAME 
		,case	when c.DATA_TYPE like '%char' then c.DATA_TYPE+' ('+convert(varchar,c.CHARACTER_MAXIMUM_LENGTH)+')' 
							when c.DATA_TYPE = 'decimal' then 'decimal(20,2)'
							else c.DATA_TYPE end as [datatype]
from INFORMATION_SCHEMA.COLUMNS c
where c.TABLE_NAME = 'server_details'