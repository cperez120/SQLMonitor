# SQLMonitor - Baseline SQL Server with PowerShell & Grafana
 
If you are a developer, or DBA who manages Microsoft SQL Servers, it becames important to understand current load vs usual load when SQL Server is slow. This repository contains scripts that will help you to setup baseline on individual SQL Server instances, and then visualize the collected data using Grafana through one Inventory server with Linked Server for individual SQL Server instances.

Navigation
 - [Why SQLMonitor?](#why-sqlmonitor)
   - [Features](#features)
 - Sample Live Grafana Dashboards
   - [Live Dashboard - Basic Metrics](#live-dashboard---basic-metrics)
   - [Live Dashboard - Perfmon Counters - Quest Softwares](#live-dashboard---perfmon-counters---quest-softwares)
 - [Portal Credentials](#portal-credentials)
 - [How to Setup](#how-to-setup)
   - [Jobs for SQLMonitor](#jobs-for-sqlmonitor)
   - [Download SQLMonitor](#download-sqlmonitor)
   - [Install SQLMonitor Using Wrapper Script](#execute-wrapper-script)
   - [Setup Grafana Dashboards](#setup-grafana-dashboards)

## Why SQLMonitor?
SQLMonitor is designed as opensource tool to replace expensive enterprise monitoring or to simply fill the gap and monitor all environments such as DEV, TEST, QA/UAT & PROD.

### Features
- Highly customizable granularity to capture important spikes in server workload.
- Grafana for real-time dashboarding
- Minimal performance impact (around 1% on a single core SQL Instance)
- Out of the box collection with minimal configuration required to get it up and running
- Zero maintenance. It has been designed to maintain itself.
- Unlimited scalability. As each instance monitors itself, we are not constraint by the capacity of the monitoring server.
- Works with all supported SQL Servers (with some limitations on 2008R2).
- Smart alerting (self clearing) with ability to use Emails, PagerDuty & Slack as target.

## Live Dashboard - Basic Metrics
You can visit [http://ajaydwivedi.ddns.net:3000](http://ajaydwivedi.ddns.net:3000/d/Fg8Q_wSMz/monitoring-live?orgId=1&refresh=30s&from=now-30m&to=now) for live dashboard for basic real time monitoring.<br><br>

![](https://github.com/imajaydwivedi/Images/blob/master/SQLMonitor/Live-Dashboards-All.gif) <br>


## Live Dashboard - Perfmon Counters - Quest Softwares
Visit [http://ajaydwivedi.ddns.net:3000](http://ajaydwivedi.ddns.net:3000/d/_dioLINMk/monitoring-perfmon-counters-quest-softwares?orgId=1&refresh=1m) for live dashboard of all Perfmon counters suggested in [SQL Server Perfmon Counters of Interest - Quest Software](https://drive.google.com/file/d/1LB7Joo6055T1FfPcholXByazOX55e5b8/view?usp=sharing).<br><br>

![](https://github.com/imajaydwivedi/Images/blob/master/SQLMonitor/Quest-Dashboards-All.gif) <br>

### Portal Credentials
Database/Grafana Portal | User Name | Password
------------ | --------- | ---------
http://ajaydwivedi.ddns.net:3000/ | guest | ajaydwivedi-guest
Sql Instance -> ajaydwivedi.ddns.net:1433 | grafana | grafana

## How to Setup
SQLMonitor supports both Central & Distributed topology. In preferred distributed topology, each SQL Server instance monitors itself. The required objects like tables, view, functions, procedures, scripts, jobs etc. are created on the monitored instance itself.

SQLMonitor utilizes PowerShell script to collect various metric from operating system including setting up Perfmon data collector, pushing the collected perfmon data to sql tables, collecting os processes running etc.

For collecting metrics available from inside SQL Server, it used standard tsql procedures. 

All the objects are created in [DBA] databases. Only few stored procedures that should have capability to be executed from context of any databases are created in [master] database.

For both OS metrics & SQL metric, SQL Agent jobs are used as schedulers. Each job has its own schedule which may differ in frequency of data collection from every one minute to once a week.

![](https://github.com/imajaydwivedi/Images/blob/master/SQLMonitor/SQLMonitor-Distributed-Topology.png) <br>

### Jobs for SQLMonitor

Following are few of the SQLMonitor data collection jobs. Each of these jobs is set to ‘(dba) SQLMonitor’ job category along with fixed naming convention of `(dba) *********`.

| Job Name                       | Job Category     | Schedule         | Job Type   | Location               |
| ------------------------------ |:----------------:|:----------------:|:----------:|:----------------------:|
| (dba) Collect-PerfmonData      | (dba) SQLMonitor | Every 2 minute   | PowerShell | PowerShell Jobs Server |
| (dba) Collect-XEvents          | (dba) SQLMonitor | Every minute     | TSQL       | Tsql Jobs Server       |
| (dba) Run-WhoIsActive          | (dba) SQLMonitor | Every 2 minute   | TSQL       | Tsql Jobs Server       |
| (dba) Partitions-Maintenance   | (dba) SQLMonitor | Every Day        | TSQL       | Tsql Jobs Server       |
| (dba) Update-SqlServerVersions | (dba) SQLMonitor | Once a week      | PowerShell | PowerShell Jobs Server |
| (dba) Collect-OSProcesses      | (dba) SQLMonitor | Every 2 minute   | PowerShell | PowerShell Jobs Server |
| (dba) Collect-WaitStats        | (dba) SQLMonitor | Every 10 minutes | TSQL       | Tsql Jobs Server       |
| (dba) Purge-Tables             | (dba) SQLMonitor | Every Day        | TSQL       | Tsql Jobs Server       |
| (dba) Remove-XEventFiles       | (dba) SQLMonitor | Every 4 hours    | PowerShell | PowerShell Jobs Server |
| (dba) Collect-DiskSpace        | (dba) SQLMonitor | Every 30 minutes | PowerShell | PowerShell Jobs Server |

----
`PowerShell Jobs Server` can be same SQL Instance that is being baselined, or some other server in same Cluster network, or some some other server in same network, or even Inventory Server.

`Tsql Jobs Server` can be same SQL Instance that is being baselined, or some other server in same Cluster network, or some some other server in same network, or even Inventory Server.

### Download SQLMonitor
Download SQLMonitor repository on your central server from where you deploy your scripts on all other servers. Say, after closing SQLMonitor, our local repo directory is `D:\Ajay-Dwivedi\GitHub-Personal\SQLMonitor`.

If the local SQLMonitor repo folder already exists, simply pull the latest from master branch.

### Execute Wrapper Script
Open script `D:\Ajay-Dwivedi\GitHub-Personal\SQLMonitor\SQLMonitor\Wrapper-InstallSQLMonitor.ps1`. Replace the appropriate values for parameters, and execute the script.

```
#$DomainCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
#$personal = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'Administrator' -Message 'Local Admin'

cls
import-module dbatools
$params = @{
    SqlInstanceToBaseline = 'Workstation'
    DbaDatabase = 'DBA'
    #HostName = 'Workstation'
    #RetentionDays = 7
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    RemoteSQLMonitorPath = 'C:\SQLMonitor'
    InventoryServer = 'SQLMonitor'
    InventoryDatabase = 'DBA'
    DbaGroupMailId = 'some_dba_mail_id@gmail.com'
    #SqlCredential = $personal
    #WindowsCredential = $DomainCredential
    <#
    SkipSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__CreateJobCheckInstanceAvailability", "24__WhoIsActivePartition",
                "25__GrafanaLogin", "26__LinkedServerOnInventory", "27__LinkedServerForDataDestinationInstance",
                "28__AlterViewsForDataDestinationInstance")
    #>
    #StartAtStep = '1__sp_WhoIsActive'
    #StopAtStep = '28__AlterViewsForDataDestinationInstance'
    #DropCreatePowerShellJobs = $true
    #DryRun = $false
    #SkipRDPSessionSteps = $true
    #SkipPowerShellJobs = $true
    #SkipTsqlJobs = $true
    #SkipMailProfileCheck = $true
    #skipCollationCheck = $true
    #SkipWindowsAdminAccessTest = $true
    #SqlInstanceAsDataDestination = 'Workstation'
    #SqlInstanceForPowershellJobs = 'Workstation'
    #SqlInstanceForTsqlJobs = 'Workstation'
    #ConfirmValidationOfMultiInstance = $true
}
D:\Ajay-Dwivedi\GitHub-Personal\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params

#Copy-DbaDbMail -Source 'SomeSourceInstance' -Destination 'SomeDestinationInstance' -SourceSqlCredential $personal -DestinationSqlCredential $personal
<#

Enable-PSRemoting -Force # run on remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value InventoryServerIP -Force
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

Enter-PSSession -ComputerName 'SqlInstanceToBaseline' -Credential $localAdmin -Authentication Negotiate
Test-WSMan 'SqlInstanceToBaseline' -Credential $localAdmin -Authentication Negotiate

#>
```

Below are some key highlight of above code:

`Line` 1-> Enable/use this variable when the `SqlInstanceToBaseline`  is not in same domain as inventory server (server from where these scripts are being executed). In this line, we are creating/saving credentials that could take RDP to SqlInstanceToBaseline .

`Line 2`-> Enable/use this variable when the `SqlInstanceToBaseline`  is not in same domain as inventory server (server from where these scripts are being executed). In this line, we are creating/saving credentials that could execute elevated SQL Queries against `SqlInstanceToBaseline`.

`Line 3`-> Enable/use this variable when the `SqlInstanceToBaseline`  is not joined to any domain. In this line, we are creating/saving credentials that could take RDP to SqlInstanceToBaseline.

`Lines 7-45` → These are the parameters for function `Install-SQLMonitor`. Enable/use them based on the requirement of various behavior of function. For example, when target server belongs different domain, then SqlCredential & WindowsCredential parameters can be utilized.

### Setup Grafana Dashboards
Download Grafana which is open source visualization tool. Install & configure same.

Create a datasource on Grafana that connects to your Inventory Server. Say, we set it with name 'SQLMonitor'. Use `grafana` as login & password while setting up this data source. The `grafana` sql login is created on each server being baselined with `db_datareader` on `DBA` database.

At next step, import all the dashboard `*.json` files on path `D:\Ajay-Dwivedi\GitHub-Personal\SQLMonitor\Grafana-Dashboards` into `SQLServer` folder on grafana portal. While importing each JSON file, we need to explicitly choose `SQLMonitor` Data Source & Folder we created in above steps.

## Remove SQLMonitor
Similar to `Wrapper-InstallSQLMonitor`, we have `Wrapper-RemoveSQLMonitor` that can help us remove SQLMonitor for a particular baselined server.

Open script `D:\Ajay-Dwivedi\GitHub-Personal\SQLMonitor\SQLMonitor\Wrapper-RemoveSQLMonitor.ps1`. Replace the appropriate values for parameters, and execute the script.

	
Thanks :smiley:. Subscribe for updates :thumbsup:
