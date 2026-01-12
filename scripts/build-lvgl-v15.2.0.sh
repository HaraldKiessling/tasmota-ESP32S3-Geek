#!/bin/bash
# build-lvgl-v15.2.0.sh - Build Tasmota32 S3 LVGL firmware v15.2.0 for ESP32S3-Geek
# by Harald Kiessling

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TASMOTA_DIR="$PROJECT_ROOT/Tasmota"
FIRMWARE_DIR="$PROJECT_ROOT/firmware"
CONFIG_DIR="$PROJECT_ROOT/config"
VENV_DIR="$PROJECT_ROOT/.venv"
PIO="$VENV_DIR/bin/pio"

TASMOTA_VERSION="v15.2.0"
BUILD_ENV="tasmota32s3-lvgl"
BUILD_DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota32 S3 LVGL Firmware Build${NC}"
echo -e "${GREEN}Version: $TASMOTA_VERSION${NC}"
echo -e "${GREEN}Environment: $BUILD_ENV${NC}"
echo -e "${GREEN}Build Date: $BUILD_DATE${NC}"
echo -e "${GREEN}by Harald Kiessling${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Step 1: Check/Clone Tasmota repository
if [ ! -d "$TASMOTA_DIR" ]; then
    echo -e "${YELLOW}Step 1: Cloning Tasmota repository...${NC}"
    git clone --depth 1 --branch "$TASMOTA_VERSION" https://github.com/arendst/Tasmota.git "$TASMOTA_DIR"
    echo -e "${GREEN}✓ Tasmota repository cloned${NC}"
else
    echo -e "${BLUE}Step 1: Tasmota repository exists${NC}"
    cd "$TASMOTA_DIR"
    
    # Check current version
    CURRENT_VERSION=$(git describe --tags 2>/dev/null || echo "unknown")
    echo -e "${BLUE}Current version: $CURRENT_VERSION${NC}"
    
    if [ "$CURRENT_VERSION" != "$TASMOTA_VERSION" ]; then
        echo -e "${YELLOW}Checking out $TASMOTA_VERSION...${NC}"
        git fetch --depth 1 origin tag "$TASMOTA_VERSION" 2>/dev/null || true
        git checkout "$TASMOTA_VERSION"
        echo -e "${GREEN}✓ Checked out $TASMOTA_VERSION${NC}"
    fi
fi
echo ""

# Step 2: Setup Python virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}Step 2: Creating Python virtual environment...${NC}"
    python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${BLUE}Step 2: Virtual environment exists${NC}"
fi
echo ""

# Step 3: Install PlatformIO
if [ ! -f "$PIO" ]; then
    echo -e "${YELLOW}Step 3: Installing PlatformIO...${NC}"
    "$VENV_DIR/bin/pip" install --upgrade pip
    "$VENV_DIR/bin/pip" install platformio
    echo -e "${GREEN}✓ PlatformIO installed${NC}"
else
    echo -e "${BLUE}Step 3: PlatformIO already installed${NC}"
    PIO_VERSION=$("$PIO" --version 2>/dev/null | head -1)
    echo -e "${BLUE}Version: $PIO_VERSION${NC}"
fi
echo ""

# Step 4: Copy configuration files
echo -e "${YELLOW}Step 4: Copying configuration files...${NC}"

# Copy user_config_override.h
if [ -f "$CONFIG_DIR/user_config_override_v15.2.0.h" ]; then
    cp "$CONFIG_DIR/user_config_override_v15.2.0.h" "$TASMOTA_DIR/tasmota/user_config_override.h"
    echo -e "${GREEN}✓ user_config_override.h copied (v15.2.0)${NC}"
elif [ -f "$CONFIG_DIR/user_config_override.h" ]; then
    cp "$CONFIG_DIR/user_config_override.h" "$TASMOTA_DIR/tasmota/"
    echo -e "${GREEN}✓ user_config_override.h copied${NC}"
else
    echo -e "${RED}✗ user_config_override.h not found in config/${NC}"
fi

# Copy platformio_override.ini
if [ -f "$CONFIG_DIR/platformio_override.ini" ]; then
    cp "$CONFIG_DIR/platformio_override.ini" "$TASMOTA_DIR/"
    echo -e "${GREEN}✓ platformio_override.ini copied${NC}"
else
    echo -e "${RED}✗ platformio_override.ini not found in config/${NC}"
fi
echo ""

# Step 5: Clean previous build (optional)
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    cd "$TASMOTA_DIR"
    "$PIO" run -e "$BUILD_ENV" -t clean
    echo -e "${GREEN}✓ Build cleaned${NC}"
    echo ""
fi

# Step 6: Build firmware
echo -e "${YELLOW}Step 5: Building firmware...${NC}"
echo -e "${BLUE}This may take several minutes...${NC}"
echo ""

cd "$TASMOTA_DIR"
BUILD_START=$(date +%s)

if "$PIO" run -e "$BUILD_ENV"; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo -e "${GREEN}Build time: ${BUILD_TIME}s${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Step 7: Copy firmware files
    echo -e "${YELLOW}Step 6: Copying firmware files...${NC}"
    
    BUILD_DIR="$TASMOTA_DIR/.pio/build/$BUILD_ENV"
    
    if [ -f "$BUILD_DIR/firmware.bin" ]; then
        cp "$BUILD_DIR/firmware.bin" "$FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.bin"
        echo -e "${GREEN}✓ firmware.bin → tasmota32s3-lvgl-15.2.0.bin${NC}"
    fi
    
    if [ -f "$BUILD_DIR/firmware.factory.bin" ]; then
        cp "$BUILD_DIR/firmware.factory.bin" "$FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.factory.bin"
        echo -e "${GREEN}✓ firmware.factory.bin → tasmota32s3-lvgl-15.2.0.factory.bin${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Firmware sizes:${NC}"
    ls -lh "$FIRMWARE_DIR"/tasmota32s3-lvgl-15.2.0*.bin 2>/dev/null | awk '{print "  " $9 ": " $5}'
    echo ""
    
    # Step 8: Verify firmware
    echo -e "${YELLOW}Step 7: Verifying firmware...${NC}"
    
    if command -v strings &> /dev/null; then
        echo -e "${BLUE}Checking for LVGL support...${NC}"
        if strings "$FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.bin" | grep -q "LVGL"; then
            echo -e "${GREEN}✓ LVGL found in firmware${NC}"
        else
            echo -e "${RED}✗ LVGL not found in firmware${NC}"
        fi
        
        echo -e "${BLUE}Checking for HASPmota support...${NC}"
        if strings "$FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.bin" | grep -q "HASPmota"; then
            echo -e "${GREEN}✓ HASPmota found in firmware${NC}"
        else
            echo -e "${RED}✗ HASPmota not found in firmware${NC}"
        fi
        
        echo -e "${BLUE}Checking firmware identifier...${NC}"
        if strings "$FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.bin" | grep -q "tasmota32s3-lvgl"; then
            echo -e "${GREEN}✓ Firmware identifier correct${NC}"
        else
            echo -e "${RED}✗ Firmware identifier not found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ 'strings' command not available, skipping verification${NC}"
    fi
    
    # Calculate checksums
    echo ""
    echo -e "${YELLOW}Step 8: Calculating checksums...${NC}"
    cd "$FIRMWARE_DIR"
    md5sum tasmota32s3-lvgl-15.2.0*.bin > tasmota32s3-lvgl-15.2.0.md5
    echo -e "${GREEN}✓ MD5 checksums saved to tasmota32s3-lvgl-15.2.0.md5${NC}"
    cat tasmota32s3-lvgl-15.2.0.md5
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Firmware location:${NC}"
    echo -e "  $FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.bin"
    echo -e "  $FIRMWARE_DIR/tasmota32s3-lvgl-15.2.0.factory.bin"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Flash firmware: ./scripts/flash.sh"
    echo -e "  2. Or use esptool.py directly:"
    echo -e "     esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \\"
    echo -e "       write_flash -z 0x0 firmware/tasmota32s3-lvgl-15.2.0.factory.bin"
    echo ""
    
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ Build failed!${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the error messages above for details.${NC}"
    exit 1
fi
