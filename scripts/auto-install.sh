#!/bin/bash
# Tasmota ESP32-S3 Geek Automatic Installation Script
# Configures a fresh or reset Tasmota device
#
# IMPORTANT: This script expects the device to already have WiFi configured
# and be accessible via the network.

set +e

# Configuration - override with environment variable
TASMOTA_URL="${TASMOTA_URL:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL environment variable not set"
    echo "Usage: TASMOTA_URL=https://your-tasmota-device/ ./auto-install.sh"
    exit 1
fi

# Remove trailing slash
TASMOTA_URL="${TASMOTA_URL%/}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# GPIO Template for ESP32S3-Geek hardware
# Base template with display GPIOs (22-27) - peripherals configured via gpio command
# Display GPIOs require explicit SPI codes (8896,8960,8800,8832,8864,8928) for ST7789
TEMPLATE='{"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,1,1,0,0,0,0],"FLAG":0,"BASE":1}'

# Peripheral GPIO configuration (applied after template)
# DS18x20: gpio6 1312, gpio13 1313, gpio14 1314
# I2C: gpio16 640, gpio17 608
# UART: gpio43 3200, gpio44 3232
PERIPHERAL_GPIO="gpio6 1312; gpio13 1313; gpio14 1314; gpio16 640; gpio17 608; gpio43 3200; gpio44 3232"

echo "========================================"
echo "Tasmota ESP32-S3 Geek Auto-Install"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "----------------------------------------"

# Helper: Execute Tasmota command via HTTP API
# Tasmota exposes /cm endpoint for command execution
# Commands return JSON response with result
tasmota_cmd() {
    local cmd="$1"
    curl -s --max-time 15 --get --data-urlencode "cmnd=$cmd" "$TASMOTA_URL/cm" 2>/dev/null
}

# Helper: Upload file with retry
upload_file() {
    local file="$1"
    local filename=$(basename "$file")
    local filesize=$(wc -c < "$file" | tr -d ' ')
    local max_retries=5
    local retry=0
    
    echo -n "  Uploading $filename ($filesize bytes)... "
    
    while [ $retry -lt $max_retries ]; do
        # Wait before upload
        sleep 2
        
        local result=$(curl -s --max-time 30 -X POST \
            -F "ufsu=@$file" \
            "$TASMOTA_URL/ufsu?fsz=$filesize" 2>/dev/null)
        
        if echo "$result" | grep -q "Successful"; then
            echo -e "${GREEN}OK${NC}"
            return 0
        fi
        
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo -n "retry($retry)... "
            sleep 3
        fi
    done
    
    echo -e "${RED}FAILED${NC}"
    return 1
}

# Helper: Wait for device
wait_for_device() {
    local timeout=${1:-60}
    local count=0
    echo -n "  Waiting for device..."
    while [ $count -lt $timeout ]; do
        if curl -s --max-time 3 "$TASMOTA_URL/" >/dev/null 2>&1; then
            echo -e " ${GREEN}OK${NC}"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        echo -n "."
    done
    echo -e " ${RED}TIMEOUT${NC}"
    return 1
}

# Step 1: Check device reachability
echo ""
echo "Step 1: Checking device..."
if ! curl -s --max-time 10 "$TASMOTA_URL/" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Device not reachable at $TASMOTA_URL${NC}"
    echo "Make sure the device is powered on and connected to WiFi."
    exit 1
fi
echo -e "  Device reachable: ${GREEN}OK${NC}"

# Get current firmware version
VERSION=$(tasmota_cmd "Status 2" | grep -oP '"Version":"[^"]+' | cut -d'"' -f4)
echo "  Firmware: $VERSION"

# Step 2: Upload configuration files FIRST (before any restart)
# This prevents crashes when Berry/LVGL tries to load missing files
echo ""
echo "Step 2: Uploading configuration files..."

# Check if config files exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}ERROR: Config directory not found: $CONFIG_DIR${NC}"
    exit 1
fi

UPLOAD_SUCCESS=true

# Upload display.ini
if [ -f "${CONFIG_DIR}/display.ini" ]; then
    upload_file "${CONFIG_DIR}/display.ini" || UPLOAD_SUCCESS=false
else
    echo -e "  ${RED}ERROR: display.ini not found${NC}"
    UPLOAD_SUCCESS=false
fi

# Upload autoexec.be
if [ -f "${CONFIG_DIR}/autoexec.be" ]; then
    upload_file "${CONFIG_DIR}/autoexec.be" || UPLOAD_SUCCESS=false
else
    echo -e "  ${RED}ERROR: autoexec.be not found${NC}"
    UPLOAD_SUCCESS=false
fi

# Upload pages.jsonl
if [ -f "${CONFIG_DIR}/pages.jsonl" ]; then
    upload_file "${CONFIG_DIR}/pages.jsonl" || UPLOAD_SUCCESS=false
else
    echo -e "  ${RED}ERROR: pages.jsonl not found${NC}"
    UPLOAD_SUCCESS=false
fi

if [ "$UPLOAD_SUCCESS" = false ]; then
    echo ""
    echo -e "${RED}ERROR: File upload failed. Cannot continue.${NC}"
    echo "The device may crash without these files."
    exit 1
fi

# Step 3: Apply Template
# Template <json> - Configure GPIO pin assignments for the hardware
# Base template has display GPIOs, sensors configured separately
echo ""
echo "Step 3: Applying GPIO Template..."
RESULT=$(tasmota_cmd "Template $TEMPLATE")
if echo "$RESULT" | grep -q "ESP32S3-Geek"; then
    echo -e "  Template applied: ${GREEN}OK${NC}"
else
    echo -e "  Template apply: ${YELLOW}WARNING${NC}"
    echo "  Response: $RESULT"
fi

# Wait for template restart
echo "  Waiting for restart..."
sleep 10
wait_for_device 60

# Configure peripheral GPIOs
# DS18x20: gpio6 1312, gpio13 1313, gpio14 1314
# I2C: gpio16 640, gpio17 608
# UART: gpio43 3200, gpio44 3232
echo ""
echo "Step 3b: Configuring peripheral GPIOs..."
tasmota_cmd "Backlog $PERIPHERAL_GPIO" >/dev/null
echo "  Peripheral GPIOs configured"

# Wait for gpio restart
echo "  Waiting for restart..."
sleep 10
wait_for_device 60

# Step 4: Configure device settings (before restart)
echo ""
echo "Step 4: Configuring device settings..."

# DeviceName <name> - Device name shown in web UI header
tasmota_cmd "DeviceName ESP32S3-Geek" >/dev/null
echo "  DeviceName: ESP32S3-Geek"

# FriendlyName <name> - Name used in MQTT topics and Home Assistant
tasmota_cmd "FriendlyName ESP32S3-Geek" >/dev/null
echo "  FriendlyName: ESP32S3-Geek"

# Timezone 99 - Auto-detect timezone via IP geolocation
tasmota_cmd "Timezone 99" >/dev/null
echo "  Timezone: 99 (auto)"

# TelePeriod <sec> - Interval for MQTT telemetry messages (60-3600s)
tasmota_cmd "TelePeriod 60" >/dev/null
echo "  TelePeriod: 60s"

# DisplayRotate <0-3> - Rotate display (0=0°, 1=90°, 2=180°, 3=270°)
tasmota_cmd "DisplayRotate 1" >/dev/null
echo "  DisplayRotate: 1"

# Step 5: Restart to apply all settings
# Restart 1 - Restart device (required after Template/Module changes)
echo ""
echo "Step 5: Restarting device..."
tasmota_cmd "Restart 1" >/dev/null
sleep 5
wait_for_device 90

# Step 6: Verify installation
echo ""
echo "Step 6: Verifying installation..."
sleep 10  # Give Berry/LVGL time to initialize

# Status 0 - Full device status including Berry runtime info
BERRY_STATUS=$(tasmota_cmd "Status 0" | grep -oP '"Berry":\{[^}]+\}')
if [ -n "$BERRY_STATUS" ]; then
    HEAP=$(echo "$BERRY_STATUS" | grep -oP '"HeapUsed":[0-9]+' | cut -d':' -f2)
    OBJECTS=$(echo "$BERRY_STATUS" | grep -oP '"Objects":[0-9]+' | cut -d':' -f2)
    echo -e "  Berry: ${GREEN}OK${NC} (Heap: ${HEAP}KB, Objects: $OBJECTS)"
else
    echo -e "  Berry: ${RED}NOT RUNNING${NC}"
fi

# DisplayModel - Show current display driver (17 = Universal Display for ST7789)
DISPLAY_MODEL=$(tasmota_cmd "DisplayModel" | grep -oP '"DisplayModel":[0-9]+' | cut -d':' -f2)
if [ "$DISPLAY_MODEL" = "17" ]; then
    echo -e "  Display: ${GREEN}OK${NC} (Model 17 - Universal Display)"
else
    echo -e "  Display: ${YELLOW}Model $DISPLAY_MODEL${NC}"
fi

# Status 10 - Sensor readings (DS18B20 temperatures, BME280, etc.)
SENSORS=$(tasmota_cmd "Status 10")
DS_COUNT=$(echo "$SENSORS" | grep -oP '"DS18B20[^"]*"' | wc -l)
echo "  DS18B20 Sensors: $DS_COUNT found"

# Check files
FILES=$(curl -s --max-time 5 "$TASMOTA_URL/ufsd?download=/" 2>/dev/null)
echo -n "  Files: "
[ -n "$(echo "$FILES" | grep 'display.ini')" ] && echo -n "display.ini " 
[ -n "$(echo "$FILES" | grep 'autoexec.be')" ] && echo -n "autoexec.be "
[ -n "$(echo "$FILES" | grep 'pages.jsonl')" ] && echo -n "pages.jsonl"
echo ""

# Summary
echo ""
echo "========================================"
echo "Installation Complete"
echo "========================================"
echo "Device URL: $TASMOTA_URL"
echo ""
echo "Run regression tests to verify:"
echo "  TASMOTA_URL=$TASMOTA_URL ./regression-test.sh"
echo ""
