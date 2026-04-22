# RISCV FPGA SCRIPTS

Just some scripts to interact with RTL cores on FPGA.


## Example workflow

```bash
# Configure VIO (boot mode)
make set_vio \
  USB_SERIAL=210308BA4E87 \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  VIO_COMMAND=jtag \
  VIO_PROBE=vio_boot_mode

# Start OpenOCD
make openocd USB_SERIAL=210249BC2333

# Reset via VIO
make set_vio \
  USB_SERIAL=210308BA4E87 \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  VIO_COMMAND=reset \
  VIO_PROBE=reset

# Program the device
make program \
  DEVICE=xcvu9p_0 \
  PROJECT_NAME=/path/to/file/bit_name \
  USB_SERIAL=210308BA4E87
```

---

## Common Commands

### Set VIO

```bash
make set_vio USB_SERIAL=<serial> DEVICE=<device> PROJECT_NAME=<path> VIO_COMMAND=<cmd> VIO_PROBE=<probe>
```

### Run OpenOCD

```bash
make openocd USB_SERIAL=<serial>
```

### Program FPGA

```bash
make program DEVICE=<device> PROJECT_NAME=<path> USB_SERIAL=<serial>
```

---

## Configuration

| Variable     | Description            | Example          |
| ------------ | ---------------------- | ---------------- |
| USB_SERIAL   | FPGA board serial      | 210308BA4E87     |
| DEVICE       | Target FPGA device     | xcvu9p_0         |
| PROJECT_NAME | Bitstream/project path | ../bitstream/... |
| VIO_COMMAND  | VIO action             | jtag / reset     |
| VIO_PROBE    | Target probe           | vio_boot_mode    |

---

