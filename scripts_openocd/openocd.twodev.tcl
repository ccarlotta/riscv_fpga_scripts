transport select jtag
telnet_port disabled
tcl_port disabled
reset_config none

set _CHIPNAME ibex
jtag newtap $_CHIPNAME cpu -irlen ${irlen}

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME -coreid 0

set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen ${irlen}

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME -coreid 0

#riscv set_mem_access sysbus

gdb_port 6666
gdb_report_data_abort enable
gdb_report_register_access_error enable

riscv set_command_timeout_sec 120
riscv set_command_timeout_sec 120


# Exit when debugger detaches
$_TARGETNAME configure -event gdb-detach {
    echo "GDB detached; ending debugging session."
    shutdown
}

init
halt
echo "Ready for Remote Connections."
