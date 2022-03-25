cls

# Copy paste the template file on folder that would contain Perfmon data collection logs
    # Point the template path
$data_collector_template_path = “E:\Perfmon\DBA_PerfMon_All_Counters_Template.xml”;
$data_collector_set_name = 'DBA';

# find Perfmon data collection logs folder path
$collector_root_directory = Split-Path $data_collector_template_path -Parent
$log_file_path = "$collector_root_directory\$data_collector_set_name"
$file_rotation_time = '04:00:00'
$sample_interval = '00:00:05'

logman import -name “$data_collector_set_name” -xml “$data_collector_template_path”
logman update -name “$data_collector_set_name” -f bin -cnf "$file_rotation_time" -o "$log_file_path" -si "$sample_interval"
logman start -name “$data_collector_set_name”

<#
logman stop -name “$data_collector_set_name”
logman delete -name “$data_collector_set_name”
#>
