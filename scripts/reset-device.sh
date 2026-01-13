#!/bin/bash
# Tasmota ESP32-S3 Geek Reset Script
# Resets device configuration while keeping WiFi settings

set +e

# Configuration - override with environment variable
TASMOTA_URL="${TASMOTA_URL:-}"

if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL environment variable not set"
    echo "Usage: TASMOTA_URL=https://your-tasmota-device/ ./reset-device.sh"
    exit 1
fi

# Remove trailing slash
TASMOTA_URL="${TASMOTA_URL%/}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Tasmota ESP32-S3 Geek Reset"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "----------------------------------------"

# Helper: Execute Tasmota command
tasmota_cmd() {
    local cmd="$1"
    curl -s --max-time 15 --get --data-urlencode "cmnd=$cmd" "$TASMOTA_URL/cm" 2>/dev/null
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
if ! curl -s --max-time 5 "$TASMOTA_URL/" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Device not reachable at $TASMOTA_URL${NC}"
    exit 1
fi
echo -e "  Device reachable: ${GREEN}OK${NC}"

# Step 2: Delete configuration files
echo ""
echo "Step 2: Deleting configuration files..."

# Delete display.ini
RESULT=$(tasmota_cmd "UfsDelete display.ini")
if echo "$RESULT" | grep -q "Done"; then
    echo -e "  display.ini: ${GREEN}Deleted${NC}"
else
    echo -e "  display.ini: ${YELLOW}Not found or error${NC}"
fi

# Delete autoexec.be
RESULT=$(tasmota_cmd "UfsDelete autoexec.be")
if echo "$RESULT" | grep -q "Done"; then
    echo -e "  autoexec.be: ${GREEN}Deleted${NC}"
else
    echo -e "  autoexec.be: ${YELLOW}Not found or error${NC}"
fi

# Delete pages.jsonl
RESULT=$(tasmota_cmd "UfsDelete pages.jsonl")
if echo "$RESULT" | grep -q "Done"; then
    echo -e "  pages.jsonl: ${GREEN}Deleted${NC}"
else
    echo -e "  pages.jsonl: ${YELLOW}Not found or error${NC}"
fi

# Step 3: Reset device (keep WiFi)
echo ""
echo "Step 3: Resetting device (keeping WiFi)..."
echo -e "  ${YELLOW}Using Reset 4 (erase settings, keep WiFi)${NC}"

RESULT=$(tasmota_cmd "Reset 4")
if echo "$RESULT" | grep -q "Restarting"; then
    echo -e "  Reset command: ${GREEN}Sent${NC}"
else
    echo -e "  Reset command: ${YELLOW}Response: $RESULT${NC}"
fi

# Step 4: Wait for device to come back
echo ""
echo "Step 4: Waiting for device to restart..."
sleep 5
wait_for_device 90

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Reset Complete"
    echo "========================================"
    echo ""
    echo "Device has been reset. WiFi settings preserved."
    echo ""
    echo "To reinstall, run:"
    echo "  TASMOTA_URL=$TASMOTA_URL ./auto-install.sh"
    echo ""
else
    echo ""
    echo -e "${RED}========================================"
    echo "Reset may have failed"
    echo "========================================${NC}"
    echo ""
    echo "Device did not respond after reset."
    echo "Possible causes:"
    echo "1. WiFi settings were lost (Reset 4 sometimes behaves like Reset 2)"
    echo "2. Device is still restarting"
    echo ""
    echo "Try accessing the device directly or check for AP mode."
    exit 1
fi
