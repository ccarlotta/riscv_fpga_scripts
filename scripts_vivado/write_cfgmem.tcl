#Set your Linux file
set LINUX_FILE "/home/fpga/linux.genesys2.gpt.bin"
#This part depends on the flash available in the FPGA (e.g. vcu118) and the one selected in the device tree (e.g cheshire.vcu118.dts)
set MYPART mt25qu01g-spi-x1_x2_x4
set host localhost:3121
set serial 210308BA4E87

open_hw_manager
connect_hw_server -url $host
current_hw_target [get_hw_targets -filter "NAME =~ *$serial"]
open_hw_target

refresh_hw_device [get_hw_devices]

create_hw_cfgmem -hw_device [lindex [get_hw_devices xcvu9p_0] 0] [lindex [get_cfgmem_parts $MYPART] 0]
set mycfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xcvu9p_0] 0]]

set_property PROGRAM.BLANK_CHECK 0 			$mycfgmem 
set_property PROGRAM.ERASE 1 				$mycfgmem
set_property PROGRAM.CFG_PROGRAM 1 			$mycfgmem
set_property PROGRAM.VERIFY 1 				$mycfgmem
set_property PROGRAM.CHECKSUM 0 			$mycfgmem
set_property PROGRAM.ADDRESS_RANGE {use_file} 		$mycfgmem
set_property PROGRAM.FILES [list $LINUX_FILE] 		$mycfgmem
set_property PROGRAM.PRM_FILE {} 			$mycfgmem
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $mycfgmem
set_property PROGRAM.BLANK_CHECK 0 			$mycfgmem
set_property PROGRAM.ERASE 1 				$mycfgmem
set_property PROGRAM.CFG_PROGRAM 1 			$mycfgmem
set_property PROGRAM.VERIFY 1 				$mycfgmem
set_property PROGRAM.CHECKSUM 0 			$mycfgmem

startgroup 

create_hw_bitstream -hw_device [lindex [get_hw_devices xcvu9p_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xcvu9p_0] 0]]; program_hw_devices [lindex [get_hw_devices xcvu9p_0] 0]; refresh_hw_device [lindex [get_hw_devices xcvu9p_0] 0];

program_hw_cfgmem -hw_cfgmem $mycfgmem

exit
