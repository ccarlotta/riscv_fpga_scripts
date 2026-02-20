# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# OpenOCD script for Cheshire through Digilent HS2 adapter.

adapter speed 500
#transport select jtag
reset_config trst_only
adapter driver ftdi
adapter serial 210249BC207B 
ftdi layout_init 0x00e8 0x60eb
#ftdi layout_signal nSRST -data 0x2000
#ftdi layout_signal GPIO2 -data 0x2000
#ftdi layout_signal GPIO1 -data 0x0200
#ftdi layout_signal GPIO0 -data 0x0100
#ftdi device_desc "Digilent USB Device"
ftdi vid_pid 0x0403 0x6014
ftdi channel 0
set irlen 5

source [file dirname [info script]]/openocd.opentitan.tcl
