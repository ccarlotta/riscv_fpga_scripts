set Filename [lindex $argv 0]
set ProbeFilename [lindex $argv 1]
set serial [lindex $argv 2]
set hwDeviceName [lindex $argv 3]
set port [lindex $argv 4]

#if {[string trim $board] eq "vcu118"} {
#    set hwDeviceName xcvu9p_0
#} elseif {[string trim $board] eq "genesys2"} {
#    set hwDeviceName xc7k325t_0
#}

#set host localhost.localdomain:$port
set host localhost:3121

open_hw_manager
connect_hw_server -url $host
current_hw_target [get_hw_targets -filter "NAME =~ *$serial"]
open_hw_target

current_hw_device [get_hw_devices $hwDeviceName]
set hwDevice [lindex [get_hw_devices $hwDeviceName] 0]

refresh_hw_device -update_hw_probes false $hwDevice

set_property PROBES.FILE $ProbeFilename [get_hw_devices $hwDevice]
set_property FULL_PROBES.FILE $ProbeFilename [get_hw_devices $hwDevice]
set_property PROGRAM.FILE $Filename [get_hw_devices $hwDevice]
program_hw_devices [get_hw_devices $hwDevice]
refresh_hw_device [lindex [get_hw_devices $hwDevice] 0]

exit

