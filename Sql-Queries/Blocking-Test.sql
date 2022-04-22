use tempdb
go

create table dbo.BlockingTest (name varchar(50), city varchar(100))
go


begin tran
	insert dbo.BlockingTest
	select 'Ajay', 'Rewa'

	waitfor delay '02:00:00'
rollback tran

/*
use tempdb
go

select * from dbo.BlockingTest
*/