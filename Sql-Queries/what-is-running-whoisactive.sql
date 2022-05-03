declare @login nvarchar(125) = suser_name();

exec sp_WhoIsActive --@filter_type = 'login', @filter = @login, @get_plans = 2
go

