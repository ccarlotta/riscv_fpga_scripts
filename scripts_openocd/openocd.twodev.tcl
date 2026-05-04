# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script used to drive two targets over the same jtag chain. 

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

gdb port ${gdb_port}
gdb report_data_abort enable
gdb report_register_access_error enable

# Exit when debugger detaches
$_TARGETNAME configure -event gdb-detach {
    echo "GDB detached; ending debugging session."
    shutdown
}

init
reset halt
echo "Ready for Remote Connections."
