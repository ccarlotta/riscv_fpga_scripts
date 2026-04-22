adapter speed     100

# Olimex ARM-USB-OCD-H
adapter driver ftdi
ftdi device_desc "Olimex OpenOCD JTAG ARM-USB-OCD-H"
ftdi vid_pid 0x15ba 0x002b

ftdi layout_init 0x0908 0x0b1b
ftdi layout_signal nSRST -oe 0x0200
ftdi layout_signal nTRST -data 0x0100
ftdi layout_signal LED -data 0x0800

adapter serial ${serial}
set irlen 5

source [file dirname [info script]]/openocd.common.tcl
