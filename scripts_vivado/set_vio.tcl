set ProbeFilename [lindex $argv 0]
set boot_mode [lindex $argv 1]
set serial [lindex $argv 2]
set command [lindex $argv 3]

set hwDeviceName xcvu9p_0
set host localhost:3121

open_hw_manager
connect_hw_server -url $host
current_hw_target [get_hw_targets -filter "NAME =~ *$serial"]
open_hw_target

current_hw_device [get_hw_devices $hwDeviceName]
set hwDevice [lindex [get_hw_devices $hwDeviceName] 0]

#Refreshing probe files
set_property PROBES.FILE $ProbeFilename [get_hw_devices $hwDevice]
set_property FULL_PROBES.FILE $ProbeFilename [get_hw_devices $hwDevice]
refresh_hw_device [lindex [get_hw_devices $hwDevice] 0]

#0 boot_mode | 1 boot_mode_safety | 2 reset
if {$command == 2} {
	set_property OUTPUT_VALUE 1 [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]
	commit_hw_vio [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]
	set_property OUTPUT_VALUE 0 [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]
	commit_hw_vio [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]
} else {
	set_property OUTPUT_VALUE $boot_mode [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]
	commit_hw_vio [get_hw_probes [lindex [get_hw_probes -of_objects [get_hw_vios]] $command]]
}


exit
