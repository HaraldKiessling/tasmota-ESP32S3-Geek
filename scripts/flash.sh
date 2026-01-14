#!/bin/bash
# flash.sh - Flash Tasmota firmware to ESP32S3-Geek
# Version: 15.2.0
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
FIRMWARE_DIR="$PROJECT_ROOT/firmware/release"
BUILD_VERSION="15.2.0"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota ESP32S3-Geek Flash Tool${NC}"
echo -e "${GREEN}Version: $BUILD_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if esptool is installed
if ! command -v esptool.py &> /dev/null; then
    echo -e "${YELLOW}esptool.py not found. Installing...${NC}"
    pip3 install esptool
fi

# Check if firmware exists
FIRMWARE_FILE="$FIRMWARE_DIR/tasmota32s3geek-v${BUILD_VERSION}.bin"
FACTORY_FILE="$FIRMWARE_DIR/tasmota32s3geek-v${BUILD_VERSION}-factory.bin"

if [ ! -f "$FIRMWARE_FILE" ] && [ ! -f "$FACTORY_FILE" ]; then
    echo -e "${RED}Error: Firmware not found!${NC}"
    echo "Please build the firmware first: ./scripts/build.sh"
    exit 1
fi

# Detect serial port
echo -e "${YELLOW}Detecting serial port...${NC}"
if [ -e /dev/ttyUSB0 ]; then
    PORT="/dev/ttyUSB0"
elif [ -e /dev/ttyACM0 ]; then
    PORT="/dev/ttyACM0"
else
    echo -e "${YELLOW}No serial port detected automatically.${NC}"
    read -p "Enter serial port (e.g., /dev/ttyUSB0): " PORT
fi

echo -e "${GREEN}Using port: $PORT${NC}"

# Ask for flash type
echo ""
echo "Select flash type:"
echo "1) OTA Update (firmware.bin) - For existing Tasmota installation"
echo "2) Factory Flash (firmware.factory.bin) - For new/blank device"
read -p "Enter choice (1 or 2): " FLASH_TYPE

if [ "$FLASH_TYPE" = "1" ]; then
    if [ ! -f "$FIRMWARE_FILE" ]; then
        echo -e "${RED}Error: OTA firmware not found!${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Flashing OTA firmware...${NC}"
    esptool.py --chip esp32s3 --port "$PORT" --baud 460800 \
        --before default_reset --after hard_reset write_flash \
        -z --flash_mode dio --flash_freq 80m --flash_size detect \
        0x0 "$FIRMWARE_FILE"
elif [ "$FLASH_TYPE" = "2" ]; then
    if [ ! -f "$FACTORY_FILE" ]; then
        echo -e "${RED}Error: Factory firmware not found!${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Erasing flash...${NC}"
    esptool.py --chip esp32s3 --port "$PORT" erase_flash
    
    echo -e "${YELLOW}Flashing factory firmware...${NC}"
    esptool.py --chip esp32s3 --port "$PORT" --baud 460800 \
        --before default_reset --after hard_reset write_flash \
        -z --flash_mode dio --flash_freq 80m --flash_size detect \
        0x0 "$FACTORY_FILE"
else
    echo -e "${RED}Invalid choice!${NC}"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Flash completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Device will reboot automatically"
    echo "2. Connect to WiFi AP 'tasmota-XXXXXX'"
    echo "3. Configure WiFi and MQTT"
    echo "4. Apply template from config/template-commands.txt"
    echo "5. Upload autoexec.be for display automation"
    echo ""
    echo "For detailed instructions, see docs/installation.md"
else
    echo -e "${RED}Flash failed!${NC}"
    exit 1
fi
