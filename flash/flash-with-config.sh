#!/bin/bash
# Flash Tasmota ESP32-S3 Geek with pre-configured WiFi
#
# This script:
# 1. Flashes the factory firmware
# 2. Waits for device to boot into AP mode
# 3. Configures WiFi via the AP
#
# Requirements:
# - esptool.py installed
# - Device connected via USB
# - WiFi credentials set below

# ============================================
# CONFIGURATION - Edit these values
# ============================================
WIFI_SSID="${WIFI_SSID:-YOUR_WIFI_SSID}"
WIFI_PASS="${WIFI_PASS:-YOUR_WIFI_PASSWORD}"
SERIAL_PORT="${SERIAL_PORT:-/dev/ttyUSB0}"  # or /dev/ttyACM0, COM3, etc.
FIRMWARE="${FIRMWARE:-../firmware/tasmota32s3-lvgl-15.2.0-full.factory.bin}"
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Tasmota ESP32-S3 Geek Flash Tool"
echo "========================================"
echo ""

# Check if esptool is available
if ! command -v esptool.py &> /dev/null; then
    echo -e "${RED}ERROR: esptool.py not found${NC}"
    echo "Install with: pip install esptool"
    exit 1
fi

# Check if firmware exists
FIRMWARE_PATH="$SCRIPT_DIR/$FIRMWARE"
if [ ! -f "$FIRMWARE_PATH" ]; then
    echo -e "${RED}ERROR: Firmware not found: $FIRMWARE_PATH${NC}"
    exit 1
fi

echo "Firmware: $FIRMWARE_PATH"
echo "Serial Port: $SERIAL_PORT"
echo "WiFi SSID: $WIFI_SSID"
echo ""

# Confirm
read -p "Press Enter to start flashing (Ctrl+C to cancel)..."

# Step 1: Flash firmware
echo ""
echo "Step 1: Flashing firmware..."
echo -e "${YELLOW}Put device in boot mode: Hold BOOT button, press RESET, release BOOT${NC}"
echo ""

esptool.py --chip esp32s3 --port "$SERIAL_PORT" --baud 921600 \
    --before default_reset --after hard_reset \
    write_flash -z 0x0 "$FIRMWARE_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Flash failed${NC}"
    exit 1
fi

echo -e "${GREEN}Flash successful!${NC}"

# Step 2: Wait for device to boot
echo ""
echo "Step 2: Waiting for device to boot..."
echo "The device will create a WiFi AP named 'tasmota-XXXXXX'"
echo ""
sleep 10

# Step 3: Instructions for WiFi configuration
echo "========================================"
echo "Step 3: Configure WiFi"
echo "========================================"
echo ""
echo "Option A: Manual (recommended)"
echo "  1. Connect to WiFi AP 'tasmota-XXXXXX'"
echo "  2. Open http://192.168.4.1"
echo "  3. Enter WiFi credentials:"
echo "     SSID: $WIFI_SSID"
echo "     Password: $WIFI_PASS"
echo ""
echo "Option B: Automatic (if device IP is known)"
echo "  After device connects to WiFi, run:"
echo "  curl 'http://DEVICE_IP/cm?cmnd=Backlog%20SSID1%20$WIFI_SSID%3B%20Password1%20$WIFI_PASS'"
echo ""
echo "========================================"
echo "After WiFi is configured:"
echo "========================================"
echo ""
echo "1. Upload configuration files BEFORE applying template:"
echo "   - display.ini"
echo "   - autoexec.be"
echo "   - pages.jsonl"
echo ""
echo "2. Apply template:"
echo '   Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}'
echo "   Module 0"
echo ""
echo "3. Configure display:"
echo "   DisplayRotate 1"
echo "   Restart 1"
echo ""
echo "4. Run regression tests:"
echo "   TASMOTA_URL=http://DEVICE_IP ./scripts/regression-test.sh"
echo ""
