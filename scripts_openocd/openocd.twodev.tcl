# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Common OpenOCD script for Cheshire (2 targets)

transport select jtag
telnet port disabled
tcl port disabled
reset_config none

set NUM_TARGETS 2
set _CHIPNAME riscv

# Create JTAG taps and targets
for {set i 0} {$i < $NUM_TARGETS} {incr i} {
    set TAPNAME $_CHIPNAME.cpu$i
    set TARGETNAME $_CHIPNAME.cpu$i

    jtag newtap $_CHIPNAME cpu$i -irlen 5
    target create $TARGETNAME riscv \
        -chain-position $TAPNAME
}


#$_CHIPNAME.cpu0 configure -work-area-phys 0x80000000 -work-area-size 1000 -work-area-backup 0
#riscv set_mem_access sysbus
#riscv expose_csrs 1984=cpuctrl,1985=secureseed

#gdb report_data_abort enable
#gdb report_register_access_error enable

riscv set_command_timeout_sec 120

init
halt
echo "Ready for Remote Connections."

