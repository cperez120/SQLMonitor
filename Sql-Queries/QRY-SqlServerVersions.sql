declare @server_product_version varchar(20);
declare @server_major_version_number tinyint;
declare @server_minor_version_number smallint;

SET @server_product_version = CONVERT(varchar,SERVERPROPERTY('ProductVersion'));
SET @server_major_version_number = CONVERT(tinyint, SERVERPROPERTY('ProductMajorVersion'))

declare @server_minor_version_number_intermediate varchar(20);
set @server_minor_version_number_intermediate = REPLACE(@server_product_version,CONVERT(varchar,@server_major_version_number)+'.'+CONVERT(varchar, SERVERPROPERTY('ProductMinorVersion'))+'.','');
set @server_minor_version_number = left(@server_minor_version_number_intermediate,charindex('.',@server_minor_version_number_intermediate)-1);

--SELECT	[@server_product_version] = @server_product_version
--		,[@server_major_version_number] = @server_major_version_number
--		,[@server_minor_version_number] = @server_minor_version_number

;with t_current as
(
	select	top 1 [MajorVersionNumber]
			--,[@server_minor_version_number] = @server_minor_version_number
			,[MinorVersionNumber]
			,[Branch]
			,[Url]
			,[ReleaseDate]
			,[MainstreamSupportEndDate]
			,[ExtendedSupportEndDate]
			,[MajorVersionName]
			,[MinorVersionName]	  
	from [master].[dbo].[SqlServerVersions] as c
	where [MajorVersionNumber] = @server_major_version_number
	and [MinorVersionNumber] <= @server_minor_version_number
	order by [MinorVersionNumber] desc
)
,t_latest as 
(
	select	top 1 [MajorVersionNumber]
			--,[@server_minor_version_number] = @server_minor_version_number
			,[MinorVersionNumber]
			,[Branch]
			,[Url]
			,[ReleaseDate]
			,[MainstreamSupportEndDate]
			,[ExtendedSupportEndDate]
			,[MajorVersionName]
			,[MinorVersionName]	  
	from [master].[dbo].[SqlServerVersions] as c
	where [MajorVersionNumber] = @server_major_version_number
	order by [MinorVersionNumber] desc
)
select	[Product Version] = @server_product_version
		,[Major Version] = @server_major_version_number
		,[Minor Version] = @server_minor_version_number
		,[Patch/Update] = c.Branch ,c.ReleaseDate ,c.MainstreamSupportEndDate --,c.ExtendedSupportEndDate
		,[MS Support State] = case when c.MainstreamSupportEndDate < getdate() then 'UnSupported' else 'Supported' end
		,[Latest_Patch] = l.Branch
		,[Patch_Gap_Days] = datediff(day,c.ReleaseDate,l.ReleaseDate)
		,[Patch_Gap_CUs] = (select count(*) from [master].[dbo].[SqlServerVersions] a 
							where a.[MajorVersionNumber] = @server_major_version_number
							and (a.[MinorVersionNumber] > c.[MinorVersionNumber] and a.[MinorVersionNumber] <= l.[MinorVersionNumber])
							)
		,[Url] = REPLACE(c.[Url],'https://support.microsoft.com/en-us/help/','')
from t_current c, t_latest l


--https://support.microsoft.com/en-us/help/5008996