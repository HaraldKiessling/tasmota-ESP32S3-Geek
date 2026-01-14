#!/bin/bash
# Factory Reset and Full Regression Test
#
# This script performs a COMPLETE factory reset including:
# 1. Flash firmware via USB
# 2. Wait for device to boot into AP mode
# 3. Configure WiFi
# 4. Upload configuration files
# 5. Apply template
# 6. Run regression tests
#
# Requirements:
# - esptool.py installed (pip install esptool)
# - Device connected via USB
# - WiFi credentials set via environment variables
#
# Usage:
#   WIFI_SSID="your_ssid" WIFI_PASS="your_password" SERIAL_PORT=/dev/ttyUSB0 ./factory-reset-and-test.sh
#
# Windows:
#   $env:WIFI_SSID="your_ssid"
#   $env:WIFI_PASS="your_password"
#   $env:SERIAL_PORT="COM7"
#   bash ./factory-reset-and-test.sh

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
WIFI_SSID="${WIFI_SSID:-}"
WIFI_PASS="${WIFI_PASS:-}"
SERIAL_PORT="${SERIAL_PORT:-/dev/ttyUSB0}"
FIRMWARE="${FIRMWARE:-$SCRIPT_DIR/../firmware/tasmota32s3-lvgl-full.factory.bin}"
DEVICE_IP="${DEVICE_IP:-}"  # Will be discovered or set manually

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo -e "${BLUE}Factory Reset and Full Regression Test${NC}"
echo "========================================"
echo "Date: $(date)"
echo "========================================"

# Validate inputs
if [ -z "$WIFI_SSID" ] || [ -z "$WIFI_PASS" ]; then
    echo -e "${RED}ERROR: WiFi credentials not set${NC}"
    echo ""
    echo "Usage:"
    echo "  WIFI_SSID=\"your_ssid\" WIFI_PASS=\"your_password\" ./factory-reset-and-test.sh"
    echo ""
    echo "Optional:"
    echo "  SERIAL_PORT=/dev/ttyUSB0  (default)"
    echo "  DEVICE_IP=192.168.0.77    (auto-discovered if not set)"
    exit 1
fi

if [ ! -f "$FIRMWARE" ]; then
    echo -e "${RED}ERROR: Firmware not found: $FIRMWARE${NC}"
    exit 1
fi

echo "WiFi SSID: $WIFI_SSID"
echo "Serial Port: $SERIAL_PORT"
echo "Firmware: $FIRMWARE"
echo ""

# Check esptool
if ! command -v esptool.py &> /dev/null && ! command -v esptool &> /dev/null; then
    # Try python module
    if ! python3 -m esptool version &> /dev/null && ! python -m esptool version &> /dev/null; then
        echo -e "${RED}ERROR: esptool not found${NC}"
        echo "Install with: pip install esptool"
        exit 1
    fi
    ESPTOOL="python3 -m esptool"
else
    ESPTOOL="esptool.py"
fi

# Step 1: Flash firmware
echo ""
echo -e "${BLUE}Step 1: Flashing firmware${NC}"
echo -e "${YELLOW}Put device in boot mode: Hold BOOT, press RESET, release BOOT${NC}"
read -p "Press Enter when ready..."

$ESPTOOL --chip esp32s3 --port "$SERIAL_PORT" --baud 921600 \
    write_flash -z 0x0 "$FIRMWARE"

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Flash failed${NC}"
    exit 1
fi
echo -e "  Flash: ${GREEN}OK${NC}"

# Step 2: Wait for AP mode
echo ""
echo -e "${BLUE}Step 2: Waiting for device to boot${NC}"
echo "Device will create WiFi AP 'tasmota-XXXXXX'"
echo ""
sleep 10

# Step 3: Configure WiFi
echo -e "${BLUE}Step 3: Configure WiFi${NC}"

if [ -z "$DEVICE_IP" ]; then
    echo ""
    echo -e "${YELLOW}Manual step required:${NC}"
    echo "1. Connect to WiFi AP 'tasmota-XXXXXX'"
    echo "2. Open http://192.168.4.1"
    echo "3. Enter WiFi credentials:"
    echo "   SSID: $WIFI_SSID"
    echo "   Password: $WIFI_PASS"
    echo "4. Save and wait for device to connect"
    echo ""
    read -p "Enter device IP after WiFi config (e.g., 192.168.0.77): " DEVICE_IP
fi

if [ -z "$DEVICE_IP" ]; then
    echo -e "${RED}ERROR: Device IP not provided${NC}"
    exit 1
fi

TASMOTA_URL="http://$DEVICE_IP"
export TASMOTA_URL

# Step 4: Wait for device
echo ""
echo -e "${BLUE}Step 4: Connecting to device${NC}"
echo -n "  Waiting for $TASMOTA_URL..."

TIMEOUT=60
COUNT=0
while [ $COUNT -lt $TIMEOUT ]; do
    if curl -s --max-time 3 "$TASMOTA_URL/" >/dev/null 2>&1; then
        echo -e " ${GREEN}OK${NC}"
        break
    fi
    sleep 2
    COUNT=$((COUNT + 2))
    echo -n "."
done

if [ $COUNT -ge $TIMEOUT ]; then
    echo -e " ${RED}TIMEOUT${NC}"
    echo "Device not reachable. Check WiFi configuration."
    exit 1
fi

# Wait for Berry
echo "  Waiting for Berry to initialize..."
sleep 10

# Step 5: Upload files
echo ""
echo -e "${BLUE}Step 5: Uploading configuration files${NC}"

"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/display.ini"
"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/autoexec.be"
"$SCRIPT_DIR/upload-via-berry.sh" "$SCRIPT_DIR/../config/pages.jsonl"

# Step 6: Apply configuration
echo ""
echo -e "${BLUE}Step 6: Applying configuration${NC}"

TEMPLATE='{"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}'

curl -s --max-time 15 --get --data-urlencode "cmnd=Template $TEMPLATE" "$TASMOTA_URL/cm" >/dev/null
echo "  Template applied"

curl -s "$TASMOTA_URL/cm?cmnd=Module%200" >/dev/null
echo "  Module: 0"

curl -s "$TASMOTA_URL/cm?cmnd=DeviceName%20ESP32S3-Geek" >/dev/null
echo "  DeviceName: ESP32S3-Geek"

curl -s "$TASMOTA_URL/cm?cmnd=DisplayRotate%201" >/dev/null
echo "  DisplayRotate: 1"

curl -s "$TASMOTA_URL/cm?cmnd=Timezone%2099" >/dev/null
echo "  Timezone: 99"

# Step 7: Restart
echo ""
echo -e "${BLUE}Step 7: Restarting device${NC}"
curl -s "$TASMOTA_URL/cm?cmnd=Restart%201" >/dev/null

echo -n "  Waiting for restart..."
sleep 5
COUNT=0
while [ $COUNT -lt 90 ]; do
    if curl -s --max-time 3 "$TASMOTA_URL/" >/dev/null 2>&1; then
        echo -e " ${GREEN}OK${NC}"
        break
    fi
    sleep 2
    COUNT=$((COUNT + 2))
    echo -n "."
done

# Wait for full init
sleep 15

# Step 8: Run regression tests
echo ""
echo -e "${BLUE}Step 8: Running regression tests${NC}"
echo ""

"$SCRIPT_DIR/regression-test.sh"
TEST_RESULT=$?

# Summary
echo ""
echo "========================================"
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}Factory Reset and Test: PASSED${NC}"
else
    echo -e "${YELLOW}Factory Reset and Test: COMPLETED WITH WARNINGS${NC}"
fi
echo "========================================"
echo "Device URL: $TASMOTA_URL"
echo "========================================"

exit $TEST_RESULT
