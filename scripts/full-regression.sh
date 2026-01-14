#!/bin/bash
# Full Regression Test for Tasmota ESP32-S3 Geek
#
# This script performs a complete test cycle:
# 1. Reset device (keep WiFi)
# 2. Upload configuration files via Berry
# 3. Apply template and settings
# 4. Run regression tests
#
# Prerequisites:
# - Device must be accessible via network
# - WiFi must already be configured
#
# Usage:
#   TASMOTA_URL=http://192.168.0.77 ./full-regression.sh
#
# For full factory reset (requires USB access):
#   See flash/README.md for firmware flashing instructions

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASMOTA_URL="${TASMOTA_URL:-}"

if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL not set"
    echo "Usage: TASMOTA_URL=http://192.168.0.77 ./full-regression.sh"
    exit 1
fi

TASMOTA_URL="${TASMOTA_URL%/}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Template
TEMPLATE='{"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}'

echo "========================================"
echo -e "${BLUE}Full Regression Test${NC}"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "========================================"

# Helper functions
tasmota_cmd() {
    curl -s --max-time 15 --get --data-urlencode "cmnd=$1" "$TASMOTA_URL/cm" 2>/dev/null
}

wait_for_device() {
    local timeout=${1:-90}
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

# Step 1: Check device
echo ""
echo -e "${BLUE}Step 1: Checking device${NC}"
if ! curl -s --max-time 5 "$TASMOTA_URL/" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Device not reachable${NC}"
    exit 1
fi
echo -e "  Device reachable: ${GREEN}OK${NC}"

VERSION=$(tasmota_cmd "Status 2" | grep -oP '"Version":"[^"]+' | cut -d'"' -f4)
echo "  Firmware: $VERSION"

# Step 2: Delete old config files
echo ""
echo -e "${BLUE}Step 2: Cleaning old configuration${NC}"
tasmota_cmd "UfsDelete display.ini" >/dev/null
echo "  Deleted display.ini"
tasmota_cmd "UfsDelete autoexec.be" >/dev/null
echo "  Deleted autoexec.be"
tasmota_cmd "UfsDelete pages.jsonl" >/dev/null
echo "  Deleted pages.jsonl"

# Step 3: Reset device (keep WiFi)
echo ""
echo -e "${BLUE}Step 3: Resetting device (keeping WiFi)${NC}"
tasmota_cmd "Reset 4" >/dev/null
sleep 5
wait_for_device 90

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Device did not come back after reset${NC}"
    echo "WiFi may have been lost. Reconfigure manually."
    exit 1
fi

# Wait for Berry to initialize
echo "  Waiting for Berry to initialize..."
sleep 10

# Step 4: Upload files via Berry
echo ""
echo -e "${BLUE}Step 4: Uploading configuration files${NC}"

"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/display.ini"
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to upload display.ini${NC}"
    exit 1
fi

"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/autoexec.be"
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to upload autoexec.be${NC}"
    exit 1
fi

"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/pages.jsonl"
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to upload pages.jsonl${NC}"
    exit 1
fi

# Step 5: Apply template
echo ""
echo -e "${BLUE}Step 5: Applying configuration${NC}"

RESULT=$(tasmota_cmd "Template $TEMPLATE")
if echo "$RESULT" | grep -q "ESP32S3-Geek"; then
    echo -e "  Template: ${GREEN}OK${NC}"
else
    echo -e "  Template: ${YELLOW}WARNING${NC}"
fi

tasmota_cmd "Module 0" >/dev/null
echo "  Module: 0 (Template)"

tasmota_cmd "DeviceName ESP32S3-Geek" >/dev/null
echo "  DeviceName: ESP32S3-Geek"

tasmota_cmd "Timezone 99" >/dev/null
echo "  Timezone: 99 (auto)"

tasmota_cmd "TelePeriod 60" >/dev/null
echo "  TelePeriod: 60s"

tasmota_cmd "DisplayRotate 1" >/dev/null
echo "  DisplayRotate: 1"

# Step 6: Restart
echo ""
echo -e "${BLUE}Step 6: Restarting device${NC}"
tasmota_cmd "Restart 1" >/dev/null
sleep 5
wait_for_device 90

# Wait for full initialization
echo "  Waiting for full initialization..."
sleep 15

# Step 7: Run regression tests
echo ""
echo -e "${BLUE}Step 7: Running regression tests${NC}"
echo ""

"$SCRIPT_DIR/regression-test.sh"
TEST_RESULT=$?

# Summary
echo ""
echo "========================================"
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}Full Regression Test: PASSED${NC}"
else
    echo -e "${YELLOW}Full Regression Test: COMPLETED WITH WARNINGS${NC}"
fi
echo "========================================"

exit $TEST_RESULT
