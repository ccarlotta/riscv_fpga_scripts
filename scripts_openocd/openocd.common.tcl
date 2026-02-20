# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Common OpenOCD script for Cheshire.

transport select jtag
telnet port disabled
tcl port disabled
reset_config none

set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen ${irlen}

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME -coreid 0

gdb report_data_abort enable
gdb report_register_access_error enable

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
