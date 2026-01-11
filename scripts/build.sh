#!/bin/bash
# build.sh - Build Tasmota firmware for ESP32S3-Geek
# Version: 15.0.1
# by Harald Kiessling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TASMOTA_DIR="$PROJECT_ROOT/Tasmota"
FIRMWARE_DIR="$PROJECT_ROOT/firmware/release"
VENV_DIR="$PROJECT_ROOT/.venv"
PIO="$VENV_DIR/bin/pio"

# Build timestamp
BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")
BUILD_VERSION="15.0.1"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota ESP32S3-Geek Firmware Build${NC}"
echo -e "${GREEN}Version: $BUILD_VERSION${NC}"
echo -e "${GREEN}Build Date: $BUILD_DATE${NC}"
echo -e "${GREEN}by Harald Kiessling${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if Tasmota directory exists
if [ ! -d "$TASMOTA_DIR" ]; then
    echo -e "${RED}Error: Tasmota directory not found!${NC}"
    echo "Please run: git clone --depth 1 --branch v15.0.1 https://github.com/arendst/Tasmota.git"
    exit 1
fi

# Check if PlatformIO is installed
if [ ! -f "$PIO" ]; then
    echo -e "${RED}Error: PlatformIO not found!${NC}"
    echo "Please run: python3 -m venv .venv && .venv/bin/pip install platformio"
    exit 1
fi

# Check if user_config_override.h exists
if [ ! -f "$TASMOTA_DIR/tasmota/user_config_override.h" ]; then
    echo -e "${YELLOW}Warning: user_config_override.h not found!${NC}"
    echo "Copying from project config..."
    cp "$PROJECT_ROOT/config/user_config_override.h" "$TASMOTA_DIR/tasmota/" 2>/dev/null || true
fi

# Create firmware output directory
mkdir -p "$FIRMWARE_DIR"

# Change to Tasmota directory
cd "$TASMOTA_DIR"

echo -e "${YELLOW}Building tasmota32s3 environment...${NC}"

# Build the firmware
$PIO run -e tasmota32s3

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    
    # Copy firmware files
    echo -e "${YELLOW}Copying firmware files...${NC}"
    
    # Main firmware
    if [ -f ".pio/build/tasmota32s3/firmware.bin" ]; then
        cp ".pio/build/tasmota32s3/firmware.bin" "$FIRMWARE_DIR/tasmota32s3geek-v${BUILD_VERSION}.bin"
        echo -e "${GREEN}✓ Main firmware: tasmota32s3geek-v${BUILD_VERSION}.bin${NC}"
    fi
    
    # Factory firmware (if exists)
    if [ -f ".pio/build/tasmota32s3/firmware.factory.bin" ]; then
        cp ".pio/build/tasmota32s3/firmware.factory.bin" "$FIRMWARE_DIR/tasmota32s3geek-v${BUILD_VERSION}-factory.bin"
        echo -e "${GREEN}✓ Factory firmware: tasmota32s3geek-v${BUILD_VERSION}-factory.bin${NC}"
    fi
    
    # Get file sizes
    echo -e "${YELLOW}Firmware sizes:${NC}"
    ls -lh "$FIRMWARE_DIR"/*.bin | awk '{print $9, $5}'
    
    # Create version info file
    cat > "$FIRMWARE_DIR/version.txt" << EOF
Tasmota ESP32S3-Geek Firmware
Version: $BUILD_VERSION
Build Date: $BUILD_DATE
by Harald Kiessling

Features:
- DS18B20 temperature sensors (up to 10 per GPIO)
- BME280 sensors on I2C (2 devices)
- ST7789 TFT Display (240x135)
- MQTT support
- Berry scripting
- Web interface

Hardware:
- Waveshare ESP32S3-Geek Stick
- ESP32-S3 @ 240MHz
- 16MB Flash
- 8MB PSRAM

Installation:
1. Flash firmware using esptool.py or Tasmota Web Installer
2. Configure WiFi and MQTT
3. Apply template from config/template-commands.txt
4. Upload autoexec.be for display automation

For more information, see README.md
EOF
    
    echo -e "${GREEN}✓ Version info created${NC}"
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo -e "${GREEN}Firmware location: $FIRMWARE_DIR${NC}"
    echo -e "${GREEN}========================================${NC}"
    
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
