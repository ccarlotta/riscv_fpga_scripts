# SCAR-V FPGA SCRIPTS

Just some scripts to interact with RTL cores on FPGA.

## Project structure

```text
.
├── hyper_init.tcl
├── Makefile
├── README.md
├── scripts_openocd
│   ├── openocd.bscan.tcl
│   ├── openocd.common.tcl
│   ├── openocd.hs2.tcl
│   ├── openocd.olimex.tcl
│   ├── openocd.opentitan.tcl
│   └── openocd.twodev.tcl
├── scripts_vivado
│   ├── jtag_program.tcl
│   ├── set_vio.tcl
│   ├── target_examine.tcl
│   └── write_cfgmem.tcl
└── setup_env.sh
```

### `scripts_vivado/`
It contains all the scripts used by vivado to program, reset, change boot mode and more. 

### `scripts_openocd/`
It contains all the scripts used to lauch openocd.
OpenOCD should be started with one of the following:

- `scripts_openocd/openocd.hs2.tcl`
- `scripts_openocd/openocd.olimex.tcl`

These scripts act as top-level configuration entry points, and they:
- Select the correct debug adapter configuration
- Launch a design-specific openocd scripts such as: 

  - `scripts_openocd/openocd.common.tcl`
  - `scripts_openocd/openocd.twodev.tcl`
  - `scripts_openocd/openocd.opentitan.tcl`

The `scripts_openocd/openocd.twodev.tcl` script is used when the two cores inside SCAR-V (CVA6 and Ibex) are connected in a daisy chain. In this case, a single debugger will be used.

## Common Commands

### Program FPGA

```bash
make program DEVICE=<device> PROJECT_NAME=<path> USB_SERIAL=<serial>
```

### Set VIO

```bash
make set_vio USB_SERIAL=<serial> DEVICE=<device> PROJECT_NAME=<path> VIO_COMMAND=<cmd> VIO_PROBE=<probe>
```

### Run OpenOCD

```bash
make openocd USB_SERIAL=<serial>
```

---

## Example workflow

The first step is to find out which FPGA targets are available in the server. For each FPGA target, the JTAG configuration is provided through a Digilent onboard USB-to-JTAG configuration logic module, which is built on top of the FDTI chip. Thus, each FPGA target can be uniquely identified by means of the FTDI chip serial number. The following command will list all the available targets, along with the serial number and device name.
```bash
make targets
```
Once the serial number corresponding to the FPGA targets have been settled, it is time to discover the external debuggers used to probe the RTL design. It is assumed that the only possible devices are either an Olimex debugger (USB ID 15ba:002b) or an HS2 debugger (USB ID 0403:6014). The following command will print all the USB devices which corresponds either to an Olimex or HS2 debbuger. It should also be noted that the HS2 debugger and the onboard Xilinx debugger both use the same FTDI chip. Therefore, the command will also print the serial number of the FPGA targets.
```bash
make serial
```
With the information about the FPGA targets it is possible to program the FPGA.
```bash
make program \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  USB_SERIAL=210308BA4E87
```
Then we can launch openocd using the correct debugger.
```bash
make openocd USB_SERIAL=210249BC2333
```
In the above example, 210308BA4E87 is the serial number of the FTDI chip of the Xilinx onboard debugger which programs the FPGA through the JTAG. Instead, 210249BC2333, is the serial number of the HS2 debugger, used to probe the design.


## Virtual Input Output (VIO)
Some designs (e.g., SCARV) include a Virtual Input/Output (VIO) core to configure the system (e.g., reset and boot mode). The following commands provide examples of how to use the scripts available in this repository.
```bash
make set_vio \
  USB_SERIAL=210308BA4E87 \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  VIO_COMMAND=jtag \
  VIO_PROBE=vio_boot_mode

make set_vio \
  USB_SERIAL=210308BA4E87 \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  VIO_PROBE=reset

make set_vio \
  USB_SERIAL=210308BA4E87 \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  VIO_PROBE=git_hash
```

---


## Configuration

These are some of the variables that can be set inside the Makefile

| Variable     | Description            | Example          |
| ------------ | ---------------------- | ---------------- |
| USB_SERIAL   | FPGA board serial      | 210308BA4E87     |
| DEVICE       | Target FPGA device     | xcvu9p_0         |
| PROJECT_NAME | Bitstream/project path | /path/to/project |
| VIO_COMMAND  | VIO action             | jtag / reset     |
| VIO_PROBE    | Target probe           | vio_boot_mode    |


## HyperRam

When the FPGA is used with an HyperRam, instead of the onboard Xilinx DRAM, the following registers should be set up. The value of some registers depends on the specific HyperRam chip, other depends on the design working configuration. These registers are set by means of a minimal script (hyper_init.tcl) which is launched by openocd.

| Register     | Description            | Default Value   |
| ------------ | ---------------------- | ----------------|
| 0x21004000   | Latency                | 0x6             |
| 0x2100400c   | Additional Latency     | 0x6             |
| 0x21004018   | Address Mask           | 0x1b            |
| 0x21004020   | Num Phys               | 0x1             |
| 0x21004024   | Which Phy              | 0x1             |
| 0x21004038   | Chip 0 Base Address    | 0x80000000      |
| 0x2100403c   | Chip 0 End Address     | 0x88000000      |
| 0x21004040   | Chip 1 Base Address    | 0x88000000      |
| 0x21004044   | Chip 1 End Address     | 0x90000000      |

---
