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
Execute all below steps on Sql Instances unless specified otherwise.
1. Ensure SqlInstance has a **mail profile set as default & public**.
	> * [DDLs/DatabaseMail_Using_GMail.sql](DDLs/DatabaseMail_Using_GMail.sql)<br>
	 
2. Create following modified version of `sp_WhoIsActive` in `[master]` database. 
	> * [sp_WhoIsActive_V12_00(Modified)](https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution/blob/ae2541e37c28ea5b50887de993666bc81f29eba5/BlitzQueries/SCH-sp_WhoIsActive_v12_00(Modified).sql)
	
3. Install [Brent Ozar's First Responder Kit](https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/dev/Install-All-Scripts.sql) in `[master]` database.
	> * [DDLs/DatabaseMail_Using_GMail.sql](DDLs/FirstResponderKit-Install-All-Scripts.sql)<br>

4. Install following powershell modules on host/SqlInstance that would have data collection SQL Agent job `(dba) Collect-PerfmonData`-
```
Update-Module -Force -ErrorAction Continue -Verbose
Update-Help -Force -ErrorAction Continue -Verbose
Install-Module dbatools, enhancedhtml2, sqlserver, poshrsjob -Scope AllUsers -Force -ErrorAction Continue -Verbose
```

5. Create required database objects in your preferred `[DBA]` database using [DDLs\SCH-Create-All-Objects.sql](DDLs\SCH-Create-All-Objects.sql). This will create partition function, scheme, few tables & views.
	> * [DDLs/SCH-Create-All-Objects.sql](DDLs/SCH-Create-All-Objects.sql)<br>
	
6. Execute the below scripts to create respective SQL Agent jobs on each SQL Instance -
	* [DDLs/SCH-Job-\[*(dba) Collect-WaitStats*\]](DDLs/SCH-Job-%5B(dba)%20Collect-WaitStats%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Partitions-Maintenance*\]](DDLs/SCH-Job-%5B(dba)%20Partitions-Maintenance%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Purge-DbaMetrics - Daily*\]](DDLs/SCH-Job-%5B(dba)%20Purge-DbaMetrics%20-%20Daily%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Run First-Responder-Kit*\]](DDLs/SCH-Job-%5B(dba)%20Run%20First-Responder-Kit%5D.sql)
	* [DDLs/SCH-Job-\[*(dba) Run-WhoIsActive*\]](DDLs/SCH-Job-%5B(dba)%20Run-WhoIsActive%5D.sql)
	
7. Download folder [Perfmon](Perfmon).
	1. Copy downloaded folder on C:\ drive of host to be baselined. 
	2. RDP the host being baselined, and execute script [Perfmon\perfmon-collector-logman.ps1](Perfmon/perfmon-collector-logman.ps1) from above copied folder. On this host, a perfmon data collector set named `[DBA]` would be created. *This directory should have at least 4 gb of size*.<br>
	3. Copy downloaded folder on C:\ drive of SqlInstance where `(dba) Collect-PerfmonData` agent job should be created. This job connects to host being baselined (in above steps), and imports the perfmon data on destination SqlInstance. This is the same instance select for powershell modules instalation on step 4. In best case scenarios, all the 3 entities (host being baselined, SqlInstance with agent job, and the perfmon data destination SqlInstance).
	4. Execute script [DDLs/SCH-Job-\[*(dba) Collect-PerfmonData*\]](DDLs/SCH-Job-%5B(dba)%20Collect-PerfmonData%5D.sql) copied on above step on SqlInstance where perfmon data processing job named `(dba) Collect-PerfmonData` should be created.
	5. Open above created job `(dba) Collect-PerfmonData`, and set proper value for `-HostName`, `-SqlInstance` and `-Database` parameters.

Here ensure that all the jobs created in step 6 & 7 are executing successfully. As per need, change job schedule & failure notification settings.



### Part 02 - Configure Grafana for Visualization on baselined data

For Grafana, I am using one SqlInstance as my **Inventory** (central) server. What this mean is, on this server, I'll create linked servers for all the SqlInstances that required monitoring using Grafana.

1. Create login `grafana` on all SqlInstance to be monitored including inventory server having `sysadmin` access. [Sql-Queries/grafana-login.sql](Sql-Queries/grafana-login.sql)
	> This high `sysadmin` priviledge for this login would be fixed in future releases.

2. On your **Inventory server**, [create linked Server for each SqlInstance](DDLs/SCH-Linked-Servers-Sample.sql) that require monitoring through Grafana. Make use of `Microsoft OLEDB Provider for SQL Server`.
	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Inventory-Server-Linked-Servers.JPG) <br>
	
3. On grafana portal, create *data source* named **'SqlMonitor'** with details of inventory server, and `grafana` login.
	![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Grafana-Inventory-DataSource.JPG) <br>

4. Create a folder with name `SQLServer'. We will keep/import all our dashboards in this folder.

5. Finally, Create dashboards by importing below *.json files

	> * [Perfmon/Monitoring - Live.json](Perfmon/Monitoring%20-%20Live.json)
	> * [Perfmon/Grafana - Monitoring - Perfmon Counters - Quest Softwares.json](Perfmon/Grafana%20-%20Monitoring%20-%20Perfmon%20Counters%20-%20Quest%20Softwares.json)
	> * [Perfmon/Wait Stats.json](Perfmon/Wait%20Stats.json)

While importing, ensure to select `SqlMonitor` as datasource & `SQLServer` as folder. Both of these were created in above steps 3 & 4.
![](https://github.com/imajaydwivedi/Images/blob/master/SqlServer-Baselining-Grafana/Grafana-Setup-Import-Dashboard.png) <br>
	
This should create the grafana dashboard according to settings of above json files.
	
Thanks :smiley:. Subscribe for updates :thumbsup:
