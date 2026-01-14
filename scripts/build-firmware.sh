#!/bin/bash
# Build Tasmota ESP32-S3 LVGL Firmware
#
# This script builds the tasmota32s3-lvgl-full firmware from source.
#
# Usage:
#   ./build-firmware.sh
#
# Output:
#   firmware/tasmota32s3-lvgl-full.bin
#   firmware/tasmota32s3-lvgl-full.factory.bin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/config"
FIRMWARE_DIR="$PROJECT_ROOT/firmware"
TASMOTA_VERSION="${TASMOTA_VERSION:-v15.2.0}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Tasmota ESP32-S3 LVGL Firmware Build"
echo "========================================"
echo "Tasmota Version: $TASMOTA_VERSION"
echo "Output: firmware/tasmota32s3-lvgl-full.bin"
echo "========================================"

# Check for platformio
if ! command -v pio &> /dev/null; then
    if command -v ~/.local/bin/pio &> /dev/null; then
        PIO=~/.local/bin/pio
    else
        echo -e "${RED}ERROR: PlatformIO not found${NC}"
        echo "Install with: pip install platformio"
        exit 1
    fi
else
    PIO=pio
fi

# Clone Tasmota
echo ""
echo "Step 1: Cloning Tasmota $TASMOTA_VERSION..."
cd "$PROJECT_ROOT"
rm -rf Tasmota
git clone --depth 1 --branch "$TASMOTA_VERSION" https://github.com/arendst/Tasmota.git

# Copy config files
echo ""
echo "Step 2: Copying configuration..."
cp "$CONFIG_DIR/platformio_override.ini" Tasmota/
cp "$CONFIG_DIR/user_config_override.h" Tasmota/tasmota/
echo -e "  ${GREEN}✓${NC} platformio_override.ini"
echo -e "  ${GREEN}✓${NC} user_config_override.h"

# Build
echo ""
echo "Step 3: Building firmware..."
cd Tasmota
$PIO run -e tasmota32s3-lvgl

# Copy output
echo ""
echo "Step 4: Copying firmware..."
cp .pio/build/tasmota32s3-lvgl/firmware.bin "$FIRMWARE_DIR/tasmota32s3-lvgl-full.bin"
cp .pio/build/tasmota32s3-lvgl/firmware.factory.bin "$FIRMWARE_DIR/tasmota32s3-lvgl-full.factory.bin"
echo -e "  ${GREEN}✓${NC} tasmota32s3-lvgl-full.bin"
echo -e "  ${GREEN}✓${NC} tasmota32s3-lvgl-full.factory.bin"

# Generate checksums
echo ""
echo "Step 5: Generating checksums..."
cd "$FIRMWARE_DIR"
md5sum tasmota32s3-lvgl-full.bin tasmota32s3-lvgl-full.factory.bin > tasmota32s3-lvgl-full.md5
cat tasmota32s3-lvgl-full.md5

# Cleanup
echo ""
echo "Step 6: Cleanup..."
cd "$PROJECT_ROOT"
rm -rf Tasmota
echo -e "  ${GREEN}✓${NC} Removed Tasmota source"

# Summary
echo ""
echo "========================================"
echo -e "${GREEN}Build Complete${NC}"
echo "========================================"
echo "Files:"
ls -lh "$FIRMWARE_DIR"/tasmota32s3-lvgl-full*.bin | awk '{print "  " $9 ": " $5}'
echo ""
echo "Flash with:"
echo "  esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \\"
echo "    write_flash -z 0x0 firmware/tasmota32s3-lvgl-full.factory.bin"
echo ""
