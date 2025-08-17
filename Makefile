# Makefile for RAK4631 Buoyfish Tracker Firmware
# 
# Usage:
#   make compile    - Compile the firmware
#   make upload     - Upload to device (will prompt for port)
#   make monitor    - Open serial monitor
#   make clean      - Clean build artifacts
#   make list-ports - List available serial ports

# Configuration
FQBN := rak_rui:nrf52:WisCoreRAK4631Board
SKETCH_DIR := buoyfish-tracker
BUILD_DIR := build
BAUDRATE := 115200

# Port detection function (same pattern as used in all scripts)
DETECTED_PORT := $(shell ls /dev/tty.usbmodem* 2>/dev/null | head -n 1)

# Default serial port (auto-detect or fallback)
# Override with: make upload PORT=/dev/cu.yourport
ifeq ($(DETECTED_PORT),)
PORT ?= /dev/tty.usbmodemF2187E25ABA01
else
PORT ?= $(DETECTED_PORT)
endif

# Default target
.PHONY: all
all: compile

# Compile the firmware
.PHONY: compile
compile:
	@echo "🔨 Compiling firmware for RAK4631..."
	arduino-cli compile --fqbn $(FQBN) $(SKETCH_DIR) --output-dir $(BUILD_DIR)
	@echo "✅ Compilation successful!"
	@echo "📁 Binary location: $(BUILD_DIR)/"

# Upload firmware to device
.PHONY: upload
upload: compile
	@if [ -z "$(PORT)" ]; then \
		echo "❌ No port specified and no RAK devices detected"; \
		echo "💡 Try: make list-ports to see available devices"; \
		exit 1; \
	fi
	@echo "📡 Uploading firmware to $(PORT)..."
	@if [ "$(PORT)" = "$(DETECTED_PORT)" ] && [ -n "$(DETECTED_PORT)" ]; then \
		echo "ℹ️  Using auto-detected port"; \
	else \
		echo "ℹ️  Using manually specified port"; \
	fi
	arduino-cli upload --fqbn $(FQBN) --port $(PORT) $(SKETCH_DIR)
	@echo "✅ Upload successful!"

# Upload with port detection
.PHONY: upload-detect
upload-detect: compile
	@echo "📡 Detecting connected boards..."
	@arduino-cli board list
	@echo ""
	@read -p "Enter port (e.g., /dev/cu.usbmodem14101): " port; \
	echo "📡 Uploading firmware to $$port..."; \
	arduino-cli upload --fqbn $(FQBN) --port $$port $(SKETCH_DIR)
	@echo "✅ Upload successful!"

# Open serial monitor
.PHONY: monitor
monitor:
	@if [ -z "$(PORT)" ]; then \
		echo "❌ No port specified and no RAK devices detected"; \
		echo "💡 Try: make list-ports to see available devices"; \
		exit 1; \
	fi
	@echo "📺 Opening serial monitor on $(PORT) at $(BAUDRATE) baud..."
	@if [ "$(PORT)" = "$(DETECTED_PORT)" ] && [ -n "$(DETECTED_PORT)" ]; then \
		echo "ℹ️  Using auto-detected port"; \
	else \
		echo "ℹ️  Using manually specified port"; \
	fi
	@echo "Press Ctrl+C to exit"
	arduino-cli monitor --port $(PORT) --config baudrate=$(BAUDRATE)

# Detect RAK device port
.PHONY: detect-port
detect-port:
	@echo "🔍 Detecting RAK devices..."
	@if [ -n "$(DETECTED_PORT)" ]; then \
		echo "✅ Found RAK device: $(DETECTED_PORT)"; \
		if [ -x "../scripts/helpers/test_port_access.py" ]; then \
			echo "🧪 Testing port access..."; \
			python3 ../scripts/helpers/test_port_access.py $(DETECTED_PORT) || true; \
		fi; \
	else \
		echo "❌ No RAK devices found"; \
		echo "📋 Available serial ports:"; \
		ls /dev/tty.* 2>/dev/null | head -10 || echo "  No tty devices found"; \
	fi

# List available serial ports
.PHONY: list-ports
list-ports:
	@echo "🔍 Available serial ports and boards:"
	arduino-cli board list
	@echo ""
	@echo "🔍 RAK device detection:"
	@make detect-port

# Clean build artifacts
.PHONY: clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	@echo "✅ Clean complete!"

# Show firmware info
.PHONY: info
info:
	@echo "ℹ️  Firmware Information:"
	@echo "   Board: RAK4631 (WisCore)"
	@echo "   FQBN: $(FQBN)"
	@echo "   Build Directory: $(BUILD_DIR)"
	@echo "   Detected Port: $(if $(DETECTED_PORT),$(DETECTED_PORT),none detected)"
	@echo "   Active Port: $(PORT)"
	@echo "   Baudrate: $(BAUDRATE)"
	@echo ""
	@echo "🔍 Port Detection Status:"
	@if [ -n "$(DETECTED_PORT)" ]; then \
		echo "   ✅ RAK device auto-detected at $(DETECTED_PORT)"; \
	else \
		echo "   ❌ No RAK devices auto-detected"; \
	fi

# Development workflow - compile and upload in one step
.PHONY: deploy
deploy: clean compile upload
	@echo "🚀 Deployment complete!"

# Help target
.PHONY: help
help:
	@echo "🛠️  RAK4631 Firmware Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  compile      - Compile the firmware"
	@echo "  upload       - Upload to device (auto-detects port)"
	@echo "  upload-detect- Upload with manual port selection"
	@echo "  monitor      - Open serial monitor (auto-detects port)"
	@echo "  detect-port  - Detect and test RAK device ports"
	@echo "  list-ports   - List available serial ports"
	@echo "  clean        - Clean build artifacts"
	@echo "  deploy       - Clean, compile, and upload"
	@echo "  info         - Show firmware and port information"
	@echo "  help         - Show this help"
	@echo ""
	@echo "Port Detection:"
	@echo "  • Automatically detects RAK devices using /dev/tty.usbmodem* pattern"
	@echo "  • Same detection logic as used in ../scripts/helpers/"
	@echo "  • Override with: make upload PORT=/dev/tty.usbmodemXXXX"
	@echo ""
	@echo "Examples:"
	@echo "  make info                                    # Show current configuration"
	@echo "  make detect-port                             # Test port detection"
	@echo "  make compile                                 # Compile firmware"
	@echo "  make upload                                  # Upload (auto-detect port)"
	@echo "  make upload PORT=/dev/tty.usbmodem12345      # Upload to specific port"
	@echo "  make monitor                                 # Monitor (auto-detect port)"
	@echo "  make deploy                                  # Full workflow"