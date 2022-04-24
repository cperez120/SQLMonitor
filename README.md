# SqlServer-Baselining-Grafana
 
If you are a developer, or DBA who manages Microsoft SQL Servers, it becames important to understand current load vs usual load when SQL Server is slow. This repository contains scripts that will help you to setup baseline on individual SQL Server instances, and then visualize the collected data using Grafana through one Inventory server with Linked Server for individual SQL Server instances.

Navigation
 - Sample Live Grafana Dashboards
   - [Live Dashboard - Basic Metrics](#live-dashboard---basic-metrics)
   - [Live Dashboard - Perfmon Counters - Quest Softwares](#live-dashboard---perfmon-counters---quest-softwares)
 - [Portal Credentials](#portal-credentials)
 - [How to Setup](#how-to-setup)
   - [Part 01 - Setup Baselining of SqlServer](#part-01---setup-baselining-of-sqlserver)
   - [Part 02 - Configure Grafana for Visualization on baselined data](#part-02---configure-grafana-for-visualization-on-baselined-data)

## Live Dashboard - Basic Metrics
You can visit [http://ajaydwivedi.ddns.net:3000](http://ajaydwivedi.ddns.net:3000/d/Fg8Q_wSMz/monitoring-live?orgId=1&refresh=30s&from=now-30m&to=now) for live dashboard for basic real time monitoring.<br><br>

![](https://github.com/imajaydwivedi/Images/blob/33429d24f7ebca45bf0aa1052896462a50ada85e/SqlServer-Baselining-Grafana/Live-Dashboards-All.gif) <br>


## Live Dashboard - Perfmon Counters - Quest Softwares
Visit [http://ajaydwivedi.ddns.net:3000](http://ajaydwivedi.ddns.net:3000/d/_dioLINMk/monitoring-perfmon-counters-quest-softwares?orgId=1&refresh=1m) for live dashboard of all Perfmon counters suggested in [SQL Server Perfmon Counters of Interest - Quest Software](https://drive.google.com/file/d/1LB7Joo6055T1FfPcholXByazOX55e5b8/view?usp=sharing).<br><br>

![](https://github.com/imajaydwivedi/Images/blob/33429d24f7ebca45bf0aa1052896462a50ada85e/SqlServer-Baselining-Grafana/Quest-Dashboards-All.gif) <br>

### Portal Credentials
Database/Grafana Portal | User Name | Password
------------ | --------- | ---------
http://ajaydwivedi.ddns.net:3000/ | guest | ajaydwivedi-guest
Sql Instance -> ajaydwivedi.ddns.net:1433 | grafana | grafana

## How to Setup
Setup of baselining & visualization is divided into 2 parts:-
- [Part 01 - Setup Baselining of SqlServer](#part-01---setup-baselining-of-sqlserver)
- [Part 02 - Configure Grafana for Visualization on baselined data](#part-02---configure-grafana-for-visualization-on-baselined-data)

### Part 01 - Setup Baselining of SqlServer. 
Execute all below steps on server to be baselined unless specified otherwise.
1. Ensure your server to be baselined has a **mail profile set as default & public**.
	> * [DDLs/DatabaseMail_Using_GMail.sql](DDLs/DatabaseMail_Using_GMail.sql)<br>
	 
2. Create following modified version of `sp_WhoIsActive` in `[master]` database. 
	> * [sp_WhoIsActive_V12_00(Modified)](https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution/blob/ae2541e37c28ea5b50887de993666bc81f29eba5/BlitzQueries/SCH-sp_WhoIsActive_v12_00(Modified).sql)
	
3. Install [Brent Ozar's First Responder Kit](https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/dev/Install-All-Scripts.sql) in `[master]` database.
	> * [DDLs/DatabaseMail_Using_GMail.sql](DDLs/FirstResponderKit-Install-All-Scripts.sql)<br>

4. Install PowerShell modules using below code
```
Update-Module -Force -ErrorAction Continue -Verbose
Update-Help -Force -ErrorAction Continue -Verbose
Install-Module dbatools, enhancedhtml2, sqlserver, poshrsjob -Scope AllUsers -Force -ErrorAction Continue -Verbose
```

5. Create required database objects in your preferred `[DBA]` database using [DDLs\SCH-Create-All-Objects.sql](DDLs\SCH-Create-All-Objects.sql). This will create partition function, scheme, few tables & views.
	> * [DDLs/SCH-Create-All-Objects.sql](DDLs/SCH-Create-All-Objects.sql)<br>
	
6.  Execute the below scripts to create respective SQL Agent jobs -
	* [DDLs/SCH-Job-\[*(dba) Collect-PerfmonData*\]](DDLs/SCH-Job-%5B(dba)%20Collect-PerfmonData%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Collect-WaitStats*\]](DDLs/SCH-Job-%5B(dba)%20Collect-WaitStats%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Partitions-Maintenance*\]](DDLs/SCH-Job-%5B(dba)%20Partitions-Maintenance%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Purge-DbaMetrics - Daily*\]](DDLs/SCH-Job-%5B(dba)%20Purge-DbaMetrics%20-%20Daily%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Run First-Responder-Kit*\]](DDLs/SCH-Job-%5B(dba)%20Run%20First-Responder-Kit%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Run-WhoIsActive*\]](DDLs/SCH-Job-%5B(dba)%20Run-WhoIsActive%5D.sql)
	
7.    script Download/Copy below files from path [NonSql-Files](NonSql-Files) to local directory where perfmon data collector files will be generated. Say, **E:\Perfmon\\** on SQL Server box. *This directory should have at least 4 gb of size*.<br>
   > * DBA_PerfMon_NonSQL_Collector_Template.xml
	 > * perfmon-collector-logman.ps1
	 > * perfmon-collector-push-to-sqlserver.ps1
	 > * perfmon-remove-imported-files.ps1

3. Create required objects in *sequential order* of scripts as mentioned below:-
	 > 1. [DDLs/SCH-tables-views.sql](DDLs/SCH-tables-views.sql)
	 > 2. [DDLs/SCH-create-functions.sql](DDLs/SCH-create-functions.sql)
	 > 3. [DDLs/SCH-usp_collect_performance_metrics.sql](DDLs/SCH-usp_collect_performance_metrics.sql)

4. Create [WhoIsActive](http://whoisactive.com/docs/) capturing using below script. Avoid running commented code that creates agent job.
	 > * [DDLs/SCH-Job-[(dba) Collect Metrics - WhoIsActive].sql](DDLs/SCH-Job-%5B(dba)%20Collect%20Metrics%20-%20WhoIsActive%5D.sql)

5. Prepare perfmon data collection:-<br>
	1. Setup Perfmon data collector using downloaded script **perfmon-collector-logman.ps1**. Make sure to open script and change value for variable **$collector_root_directory**  as per Step 2). Save it.
	```Powershell
	# Original line in script
	$collector_root_directory = 'D:\MSSQL15.MSSQLSERVER\MSSQL\Perfmon';
	# Update line as per need
	$collector_root_directory = 'E:\Perfmon';
	```
	2. Create ODBC Data Source for SqlInstance. This should be done only once for each Windows Server box. In case of multiple SQL Server instances, choose one instance as ODBC destination.
	```
	# create dsn for Sql Server instance 'localhost' with windows authentication and default to [DBA] database
	Add-OdbcDsn -Name "LocalSqlServer" -DriverName "SQL Server" -DsnType "System" -SetPropertyValue @("Server=localhost", "Trusted_Connection=Yes", "Database=DBA")
	```
	3. Push Perform data collector data to SqlServer using relog & dsn.
	> * [NonSql-Files/perfmon-collector-push-to-sqlserver.ps1](NonSql-Files/perfmon-collector-push-to-sqlserver.ps1)
	
6. Setup Default Mail profile
	1. Make sure a public profile is set as **'Default profile'** in **Database Mail** using **Profile Security**.<br><br>
	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Default-Public-Database-Mail-Profile.JPG) <br>
	2. Make sure Mail profile is set for **SQL Server Agent** under *Mail session*.<br><br>
	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/SqlAgent-Default-Database-Mail-Profile.JPG) <br>
	
7. Create database login/user **[grafana]** for executing queries from Grafana portal. This user needs **[db_datareader]** on \[DBA\], and **VIEW SERVER STATE** permissions.
	> * [Permissions/SCH-grafana-login.sql](Permissions/SCH-grafana-login.sql)
	
8. **IMPORTANT:** In case of multiple SqlInstances installed on *same server*, Perfmon collector data should be imported into one instance only.<br>
	
	For example, on SQL Server box 'SQL-A.Lab.com', I have one *named instance* **'SQL-A\V17'** installed along side with default instance **'SQL-A'**. So I import the Perfmon collector data into default instance 'SQL-A', and **read same data on named instance using views created with help of Linked server of default instance**. 
	
	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Linked-Server-4-Default-Instance-on-Named-Instance.png) <br>
	
	Execute below script on NAMED instance to create these views required to read data:-
	> * [DDLs/SCH-tables-views-Named-Instance.sql](DDLs/SCH-tables-views-Named-Instance.sql)
	
	NOTE:- Make sure to create linked server for main instance in named instance, and replace the linked server name in above script code before executing.
	
9. Execute below script to **Create Sql Agent jobs that Collect/Purge performance data**. Jobs have default **schedule of every 10 seconds**.
	> * [DDLs/SCH-Jobs-All-[(dba) Collect Metrics].sql](DDLs/SCH-Jobs-All-%5B(dba)%20Collect%20Metrics%5D.sql)	
	
	This will create sql agent jobs with name like '(dba) Collect Metrics - ******'<br>
	
	Make sure jobs \[(dba) Collect Metrics - NonSqlServer Perfmon Counters] & \[(dba) Collect Metrics - Purge Perfmon Files] execute successfully. These jobs may require script path change to point to directory set in step 2, & 5.a.<br>
	
	This completes part 01 of setting up baselining for SQL Server

### Part 02 - Configure Grafana for Visualization on baselined data

For Grafana, I am using one SqlInstance as my **Inventory** (central) server. What this mean is, on this server, I'll create linked servers for all the server that required monitoring using Grafana.

1. **Setup Inventory server**. Select one server as Inventory. Create linked Server for each instance that require monitoring through Grafana on your central server using 'Microsoft OLEDB Provider for SQL Server'. Here make sure to utilize readonly sql authenticated login \[grafana\] we created in [part 01 step 7](#).

	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Inventory-Server-Linked-Servers.JPG) <br>
	
2. On grafana portal, create *data source* named **'Inventory'** with details of above step, and **\[grafana\]** login.

	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Grafana-Inventory-DataSource.JPG) <br>
	
3. Finally, Create dashboards by importing below *.json files

	> * [NonSql-Files/Grafana - Monitoring - Live - External Share.json](NonSql-Files/Grafana%20-%20Monitoring%20-%20Live%20-%20External%20Share.json)
	> * [NonSql-Files/Grafana - Monitoring - Perfmon Counters - Quest Softwares - External Share.json](NonSql-Files/Grafana%20-%20Monitoring%20-%20Perfmon%20Counters%20-%20Quest%20Softwares%20-%20External%20Share.json)
	
	This should create the grafana dashboard according to settings of above json files.
	
	Thanks :smiley:. Subscribe for updates :thumbsup:
