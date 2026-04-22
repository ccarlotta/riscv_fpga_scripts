# SOFTWARE used by the Makefile
# Vivado is used to program the board via the buit-in jtag chain of the FPGA
# Openocd is used to connect to the debug module inside the design; it also opens a port enabling debug-request from gdb
# GDB is used to debug the riscv cores inside the design; it requires a connection to the port exposed by openocd  
VIVADO	 	?= vivado_lab
OPENOCD		?= openocd
GDB 		?= riscv64-unknown-elf-gdb

# SCRIPTS directories
VIVADO_DIR 		?= scripts_vivado
OPENOCD_DIR 	?= scripts_openocd

# BINARIES directories
ELF_DIR 		= bit_under_test/elf_secd
BITSTREAM_DIR 	?= bit_under_test/fix
PROBES_DIR 		?= $(BITSTREAM_DIR)

# SCRIPTS
PROGRAM_TCL 	?= $(VIVADO_DIR)/jtag_program.tcl
WRITE_CFG_TCL 	?= $(VIVADO_DIR)/write_cfgmem.tcl
VIO_TCL     	?= $(VIVADO_DIR)/set_vio.tcl
TARGET_EXAMINE  ?= $(VIVADO_DIR)/target_examine.tcl
#OPENOCD_SCRIPT 	?= $(OPENOCD_DIR)/openocd.hs2.tcl #$(OPENOCD_DIR)/openocd.olimex.tcl
OPENOCD_SCRIPT 	?= $(OPENOCD_DIR)/openocd.olimex.tcl

# BINARIES
# In the Security Island in scarv the elf boot is executed by the Ibex core to setup the registers of the pulp cluster. The elf app is executed by the pulp cluster.
PROJECT_NAME	?= $(BITSTREAM_DIR)/carfield_top_xilinx
ELF_FILE_BOOT 	?= $(ELF_DIR)/generic_test.elf
ELF_FILE_APP 	?= $(ELF_DIR)/test


# This is the serial used by openocd to identify the ftdi connected to the debug module in the design
# The value can be obtained by inspecting the vivado hardware manager or simply launching lsusb -v
USB_SERIAL 	?= 210308BA4E87
OLIMEX_BUS	:= 15ba:002b
HS2_BUS		:= 0403:6014

# This is the port at which I can connect to talk to a device. By specifying different ports I can talk with different devices without interference
PORT		:= 3121

VIO_PROBE 	:= boot_mode
VIO_COMMAND := jtag

DEVICE 		:= xc7k325t_0

COMMON_ARGS := -mode batch -nojournal -nolog -quiet

all: setup_env program boot_jtag reset openocd gdb_run kill_openocd

secd: program openocd gdb_2bin_run kill_openocd

setup_env:
	./setup_env.sh

# This targets prints the available jtag devices, so that the user can select the right one. It is not possible to know "a priori" which one is the usb connected to the desired FPGA.
serial:
	@echo "Scanning Olimex devices..."
	@lsusb -d $(OLIMEX_BUS) -v | grep iSerial | awk '{print $$3}'
	@echo "Scanning HS2 devices..."
	@lsusb -d $(HS2_BUS) -v | grep iSerial | awk '{print $$3}'

# This targets prevents Vivado to take over all the available devices.
hw_server_filtered:
	hw_server -s tcp::$(PORT) -e "set jtag-port-filter $(USB_SERIAL)" &

program: #hw_server_filtered
	$(VIVADO) $(COMMON_ARGS) \
		-source $(PROGRAM_TCL) \
		-tclargs $(PROJECT_NAME).bit $(PROJECT_NAME).ltx $(USB_SERIAL) $(DEVICE) $(PORT)
	@pkill hw_server

set_vio: #hw_server_filtered
	$(VIVADO) $(COMMON_ARGS) \
		-source $(VIO_TCL) \
		-tclargs $(PROJECT_NAME).ltx $(VIO_COMMAND) $(USB_SERIAL) $(VIO_PROBE) $(DEVICE) $(PORT)
	@pkill hw_server

reset:# hw_server_filtered
	$(VIVADO) $(COMMON_ARGS) \
		-source $(VIO_TCL) \
		-tclargs $(PROJECT_NAME).ltx $(VIO_COMMAND) $(USB_SERIAL) $(VIO_PROBE) $(DEVICE) $(PORT)
	@pkill hw_server

targets: 
	$(VIVADO) $(COMMON_ARGS) \
		-source $(TARGET_EXAMINE)

openocd:
	@echo "Checking for running hw_server..."
#	@pkill hw_server 2>/dev/null || true
	@sleep 1
	@echo $(USB_SERIAL)
	$(OPENOCD) \
	-c "set serial $(USB_SERIAL)" \
	-f $(OPENOCD_SCRIPT) \
	-c "script hyper_init.tcl"
	@echo "Openocd launched"


kill_openocd:
	@echo "Killing openocd..."
	@pkill openocd 2>/dev/null || true

gdb_run:
	$(GDB)  $(ELF_FILE_APP) \
		-ex "target remote localhost:6667 \
		-ex "load" \
		-ex "c"

gdb_2bin_run:
	$(GDB) $(ELF_FILE_APP) \
		-ex "target remote localhost:3333" \
		-ex "load" \
		-ex "file $(ELF_FILE_BOOT)" \
		-ex "load" \
		-ex "c" \
		-ex "exit"

write_bin_mem:
	$(VIVADO) $(COMMON_ARGS) \
		-source $(WRITE_CFG_TCL)
