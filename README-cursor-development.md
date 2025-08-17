# RAK4631 Firmware Development in Cursor/VS Code

This document explains how to compile and flash RAK4631 firmware directly from Cursor/VS Code without the Arduino IDE.

## Prerequisites

✅ **Already Installed:**
- `arduino-cli` - Command line Arduino tool
- RAK RUI3 board package (`rak_rui:nrf52`)
- Required Arduino libraries (ArduinoJson, CayenneLPP, etc.)

## Quick Start

### Make Commands (Terminal)

```bash
# Compile firmware
make compile

# Upload to specific port
make upload PORT=/dev/cu.usbmodemXXXXXX

# Open serial monitor
make monitor PORT=/dev/tty.usbmodemXXXXXXX

# Clean build files
make clean

# Complete workflow (clean + compile + upload)
make deploy

# Show all available commands
make help
```

### Method 4: Direct Arduino CLI

```bash
# Compile
arduino-cli compile --fqbn rak_rui:nrf52:WisCoreRAK4631Board .

# Upload
arduino-cli upload --fqbn rak_rui:nrf52:WisCoreRAK4631Board --port /dev/cu.usbmodemXXXXXX .

# Monitor
arduino-cli monitor --port /dev/cu.usbmodemXXXXXX --config baudrate=115200
```

## Workflow

1. **Connect RAK4631** via USB-C
2. **Check port**: Run "List Serial Ports" task or `make list-ports`
3. **Compile**: `make compile`
4. **Upload**: `make upload`
5. **Monitor**: `make monitor`

## File Structure

```
buoyfish-tracker-rui3/
├── buoyfish-tracker-rui3.ino    # Main firmware file
├── app.h                        # Header with declarations
├── custom_at.cpp                # Custom AT commands
├── wisblock_cayenne.cpp/.h      # Cayenne LPP extensions
├── RAK12500_gnss.cpp            # GPS module driver
├── RAK1904.cpp                  # Accelerometer driver
├── dr_calculator.cpp            # Data rate calculator
├── build/                       # Compiled binaries (auto-created)
├── .vscode/
│   ├── tasks.json              # VS Code build tasks
│   ├── keybindings.json        # Keyboard shortcuts
│   └── arduino.json            # Arduino configuration
├── Makefile                    # Make-based build system
└── README-cursor-development.md # This file
```

## Port Detection

Your RAK4631 typically shows up as:
- macOS: `/dev/cu.usbmodemXXXXXX`
- Linux: `/dev/ttyACMX` or `/dev/ttyUSBX`
- Windows: `COMX`

Run `make list-ports` or the "List Serial Ports" task to see connected devices.

## Troubleshooting

### Compilation Issues
- Ensure only one `.ino` file exists in the directory
- Check that all required libraries are installed
- Run `make clean` to clear build cache

### Upload Issues
- Verify correct port selection
- Ensure device is in bootloader mode (double-click reset button)
- Check USB cable supports data transfer
- Try different USB ports

### Serial Monitor Issues
- Verify correct baud rate (115200)
- Ensure no other applications are using the serial port
- On macOS, use `cu.` ports for communication

### Missing Libraries
```bash
arduino-cli lib install "ArduinoJson"
arduino-cli lib install "CayenneLPP"
arduino-cli lib install "SparkFun u-blox GNSS Arduino Library"
arduino-cli lib install "Adafruit LIS3DH"
arduino-cli lib install "Adafruit BusIO"
arduino-cli lib install "Adafruit Unified Sensor"
```

## Advanced Features

### Custom Board Configuration
The build uses these settings (from `.vscode/arduino.json`):
- Board: `rak_rui:nrf52:WisCoreRAK4631Board`
- Configuration: Debug level, LoRa regions, etc.

### Build Artifacts
Compiled files are stored in `build/`:
- `*.hex` - Flash image
- `*.bin` - Binary image
- `*.elf` - Executable with debug symbols

### Memory Usage
The firmware uses approximately:
- **Program**: 349KB / 557KB (62%)
- **RAM**: 78KB / 206KB (37%)

## Integration with Cursor

This setup provides a seamless development experience in Cursor:
- Syntax highlighting for Arduino C++
- IntelliSense code completion
- Integrated terminal for build/upload
- Git integration for version control
- Task automation via VS Code tasks

Happy coding! 🚀