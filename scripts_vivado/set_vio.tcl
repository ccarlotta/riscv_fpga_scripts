set ProbeFilename [lindex $argv 0]
set command [lindex $argv 1]
set serial [lindex $argv 2]
set probe [lindex $argv 3]
set hwDeviceName [lindex $argv 4]
set port [lindex $argv 5]

if { [string trim $command] eq "jtag"} {
   set output 0
} elseif { [string trim $command] eq "spi"} { 
   set output 2
} else {
   set output 1
}

#set host localhost.localdomain:$port
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

set cmd [string trim $probe]
set filter "NAME =~ *$cmd*"

if { [string trim $probe] eq "reset"} {
	set_property OUTPUT_VALUE 1 [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]
	commit_hw_vio [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]
	set_property OUTPUT_VALUE 0 [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]
	commit_hw_vio [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]
} else {
	set_property OUTPUT_VALUE $output [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]
	commit_hw_vio [get_hw_probes [lindex [get_hw_probes -of_objects [get_hw_vios] -filter $filter] 0]]
}


exit
