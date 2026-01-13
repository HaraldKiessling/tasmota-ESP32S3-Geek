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

# Template for ESP32-S3 Geek
TEMPLATE='{"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}'

echo "========================================"
echo "Tasmota ESP32-S3 Geek Auto-Install"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "----------------------------------------"

# Helper: Execute Tasmota command
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
    echo -e "${YELLOW}WARNING: Config directory not found: $CONFIG_DIR${NC}"
    echo "  Trying firmware/release/v7 instead..."
    CONFIG_DIR="${SCRIPT_DIR}/../firmware/release/v7"
fi

UPLOAD_SUCCESS=true

# Upload display.ini
DISPLAY_FILE=""
if [ -f "${SCRIPT_DIR}/../config/display.ini" ]; then
    DISPLAY_FILE="${SCRIPT_DIR}/../config/display.ini"
elif [ -f "${SCRIPT_DIR}/../firmware/release/v7/display.ini" ]; then
    DISPLAY_FILE="${SCRIPT_DIR}/../firmware/release/v7/display.ini"
fi

if [ -n "$DISPLAY_FILE" ]; then
    upload_file "$DISPLAY_FILE" || UPLOAD_SUCCESS=false
else
    echo -e "  ${RED}ERROR: display.ini not found${NC}"
    UPLOAD_SUCCESS=false
fi

# Upload autoexec.be
AUTOEXEC_FILE=""
if [ -f "${SCRIPT_DIR}/../config/autoexec.be" ]; then
    AUTOEXEC_FILE="${SCRIPT_DIR}/../config/autoexec.be"
elif [ -f "${SCRIPT_DIR}/../firmware/release/v7/autoexec.be" ]; then
    AUTOEXEC_FILE="${SCRIPT_DIR}/../firmware/release/v7/autoexec.be"
fi

if [ -n "$AUTOEXEC_FILE" ]; then
    upload_file "$AUTOEXEC_FILE" || UPLOAD_SUCCESS=false
else
    echo -e "  ${RED}ERROR: autoexec.be not found${NC}"
    UPLOAD_SUCCESS=false
fi

# Upload pages.jsonl
PAGES_FILE=""
if [ -f "${SCRIPT_DIR}/../config/pages.jsonl" ]; then
    PAGES_FILE="${SCRIPT_DIR}/../config/pages.jsonl"
elif [ -f "${SCRIPT_DIR}/../firmware/release/v7/pages.jsonl" ]; then
    PAGES_FILE="${SCRIPT_DIR}/../firmware/release/v7/pages.jsonl"
fi

if [ -n "$PAGES_FILE" ]; then
    upload_file "$PAGES_FILE" || UPLOAD_SUCCESS=false
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
echo ""
echo "Step 3: Applying GPIO Template..."
RESULT=$(tasmota_cmd "Template $TEMPLATE")
if echo "$RESULT" | grep -q "ESP32S3-Geek"; then
    echo -e "  Template applied: ${GREEN}OK${NC}"
else
    echo -e "  Template apply: ${YELLOW}WARNING${NC}"
    echo "  Response: $RESULT"
fi

# Set Module to 0 (use template)
tasmota_cmd "Module 0" >/dev/null
echo "  Module set to 0 (Template)"

# Step 4: Configure device settings (before restart)
echo ""
echo "Step 4: Configuring device settings..."

tasmota_cmd "DeviceName ESP32S3-Geek" >/dev/null
echo "  DeviceName: ESP32S3-Geek"

tasmota_cmd "FriendlyName ESP32S3-Geek" >/dev/null
echo "  FriendlyName: ESP32S3-Geek"

tasmota_cmd "Timezone 99" >/dev/null
echo "  Timezone: 99 (auto)"

tasmota_cmd "TelePeriod 60" >/dev/null
echo "  TelePeriod: 60s"

tasmota_cmd "DisplayRotate 1" >/dev/null
echo "  DisplayRotate: 1"

# Step 5: Restart to apply all settings
echo ""
echo "Step 5: Restarting device..."
tasmota_cmd "Restart 1" >/dev/null
sleep 5
wait_for_device 90

# Step 6: Verify installation
echo ""
echo "Step 6: Verifying installation..."
sleep 10  # Give Berry/LVGL time to initialize

# Check Berry
BERRY_STATUS=$(tasmota_cmd "Status 0" | grep -oP '"Berry":\{[^}]+\}')
if [ -n "$BERRY_STATUS" ]; then
    HEAP=$(echo "$BERRY_STATUS" | grep -oP '"HeapUsed":[0-9]+' | cut -d':' -f2)
    OBJECTS=$(echo "$BERRY_STATUS" | grep -oP '"Objects":[0-9]+' | cut -d':' -f2)
    echo -e "  Berry: ${GREEN}OK${NC} (Heap: ${HEAP}KB, Objects: $OBJECTS)"
else
    echo -e "  Berry: ${RED}NOT RUNNING${NC}"
fi

# Check Display
DISPLAY_MODEL=$(tasmota_cmd "DisplayModel" | grep -oP '"DisplayModel":[0-9]+' | cut -d':' -f2)
if [ "$DISPLAY_MODEL" = "17" ]; then
    echo -e "  Display: ${GREEN}OK${NC} (Model 17 - Universal Display)"
else
    echo -e "  Display: ${YELLOW}Model $DISPLAY_MODEL${NC}"
fi

# Check sensors
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
