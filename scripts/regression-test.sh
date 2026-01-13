#!/bin/bash
# Tasmota ESP32-S3 Geek Regression Test Script
# Tests: Display, Berry, Extension Manager, ST7789, LVGL, Network, Sensors

# Don't exit on error - we handle errors ourselves
set +e

# Configuration - override with environment variable
TASMOTA_URL="${TASMOTA_URL:-}"

if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL environment variable not set"
    echo "Usage: TASMOTA_URL=https://your-tasmota-device/ ./regression-test.sh"
    exit 1
fi

# Remove trailing slash
TASMOTA_URL="${TASMOTA_URL%/}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

# Test function
test_result() {
    local name="$1"
    local result="$2"
    local details="$3"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $name"
        [ -n "$details" ] && echo "   $details"
        ((PASSED++))
    elif [ "$result" = "WARN" ]; then
        echo -e "${YELLOW}⚠️  WARN${NC}: $name"
        [ -n "$details" ] && echo "   $details"
        ((WARNINGS++))
    else
        echo -e "${RED}❌ FAIL${NC}: $name"
        [ -n "$details" ] && echo "   $details"
        ((FAILED++))
    fi
}

# Helper: Execute Tasmota command
tasmota_cmd() {
    local cmd="$1"
    curl -s --max-time 10 --get --data-urlencode "cmnd=$cmd" "$TASMOTA_URL/cm" 2>/dev/null
}

# Helper: Check if device is reachable
check_device() {
    curl -s --max-time 5 "$TASMOTA_URL/" >/dev/null 2>&1
}

echo "========================================"
echo "Tasmota ESP32-S3 Geek Regression Tests"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "----------------------------------------"

# Test 1: Device Reachability
echo ""
echo "=== Network Tests ==="
if check_device; then
    test_result "Device Reachable" "PASS"
else
    test_result "Device Reachable" "FAIL" "Cannot connect to $TASMOTA_URL"
    echo ""
    echo "FATAL: Device not reachable. Aborting tests."
    exit 1
fi

# Test 2: Get Status
STATUS=$(tasmota_cmd "Status 0")
if [ -n "$STATUS" ] && echo "$STATUS" | grep -q "Status"; then
    test_result "Status Command" "PASS"
else
    test_result "Status Command" "FAIL" "No valid response"
fi

# Test 3: IP Address
IP=$(echo "$STATUS" | grep -oP '"IPAddress":"[^"]+' | cut -d'"' -f4)
if [ -n "$IP" ]; then
    test_result "IP Address" "PASS" "$IP"
else
    test_result "IP Address" "FAIL" "No IP found"
fi

# Test 4: SSID
SSID=$(tasmota_cmd "Status 11" | grep -oP '"SSId":"[^"]+' | cut -d'"' -f4)
if [ -n "$SSID" ]; then
    test_result "WiFi SSID" "PASS" "$SSID"
else
    test_result "WiFi SSID" "FAIL" "No SSID found"
fi

# Test 5: Time/Clock
echo ""
echo "=== System Tests ==="
TIME=$(tasmota_cmd "Time" | grep -oP '"Time":"[^"]+' | cut -d'"' -f4)
if [ -n "$TIME" ] && [ "$TIME" != "1970-01-01" ]; then
    test_result "System Clock" "PASS" "$TIME"
else
    test_result "System Clock" "WARN" "Time not synced: $TIME"
fi

# Test 6: ST7789 Display (check log or DisplayModel)
echo ""
echo "=== Display Tests ==="
LOG=$(curl -s --max-time 10 "$TASMOTA_URL/cs?c2=0" 2>/dev/null)
DISPLAY_MODEL=$(tasmota_cmd "DisplayModel" | grep -oP '"DisplayModel":[0-9]+' | cut -d':' -f2)

# ST7789 check - either in log or DisplayModel=17
if echo "$LOG" | grep -q "ST7789 initialized"; then
    test_result "ST7789 Display" "PASS" "Found in boot log"
elif [ "$DISPLAY_MODEL" = "17" ]; then
    test_result "ST7789 Display" "PASS" "DisplayModel=17 (Universal Display)"
else
    test_result "ST7789 Display" "FAIL" "Not initialized"
fi

# Test 7: LVGL (check log or Berry status for LVGL objects)
BERRY_STATUS=$(tasmota_cmd "Status 0" | grep -oP '"Berry":\{[^}]+\}')
if echo "$LOG" | grep -q "LVGL initialized"; then
    test_result "LVGL Graphics" "PASS" "Found in boot log"
elif [ -n "$BERRY_STATUS" ]; then
    # If Berry is running with objects, LVGL is likely active
    OBJECTS=$(echo "$BERRY_STATUS" | grep -oP '"Objects":[0-9]+' | cut -d':' -f2)
    if [ -n "$OBJECTS" ] && [ "$OBJECTS" -gt 100 ]; then
        test_result "LVGL Graphics" "PASS" "Berry active with $OBJECTS objects"
    else
        test_result "LVGL Graphics" "WARN" "Berry active but few objects ($OBJECTS)"
    fi
else
    test_result "LVGL Graphics" "FAIL" "Not detected"
fi

# Test 8: Display Model
if [ -n "$DISPLAY_MODEL" ] && [ "$DISPLAY_MODEL" != "0" ]; then
    test_result "Display Model" "PASS" "Model $DISPLAY_MODEL"
else
    test_result "Display Model" "WARN" "Model is $DISPLAY_MODEL"
fi

# Test 9: Berry Scripting
echo ""
echo "=== Berry Tests ==="
BERRY_TEST=$(tasmota_cmd "br print(1+1)")
if echo "$BERRY_TEST" | grep -q '"Br"'; then
    test_result "Berry Command" "PASS"
else
    test_result "Berry Command" "FAIL" "Berry not responding"
fi

# Test 10: Berry Console Page
BERRY_PAGE=$(curl -s --max-time 5 "$TASMOTA_URL/bc" 2>/dev/null)
if echo "$BERRY_PAGE" | grep -q "Berry"; then
    test_result "Berry Console Page" "PASS"
else
    test_result "Berry Console Page" "FAIL" "Page not available"
fi

# Test 11: Berry in Status
BERRY_STATUS=$(tasmota_cmd "Status 0" | grep -oP '"Berry":\{[^}]+\}')
if [ -n "$BERRY_STATUS" ]; then
    HEAP=$(echo "$BERRY_STATUS" | grep -oP '"HeapUsed":[0-9]+' | cut -d':' -f2)
    test_result "Berry Runtime" "PASS" "Heap: ${HEAP}KB"
else
    test_result "Berry Runtime" "FAIL" "Not in status"
fi

# Test 12: Extension Manager
echo ""
echo "=== Extension Manager Tests ==="
EXT_PAGE=$(curl -s --max-time 5 "$TASMOTA_URL/ext" 2>/dev/null)
if echo "$EXT_PAGE" | grep -qi "extension\|manager"; then
    test_result "Extension Manager Page" "PASS"
else
    test_result "Extension Manager Page" "FAIL" "Page not available"
fi

# Test 13: Tools Menu
TOOLS_PAGE=$(curl -s --max-time 5 "$TASMOTA_URL/mn" 2>/dev/null)
if echo "$TOOLS_PAGE" | grep -q "Berry Scripting console"; then
    test_result "Berry in Tools Menu" "PASS"
else
    test_result "Berry in Tools Menu" "FAIL" "Not in menu"
fi

if echo "$TOOLS_PAGE" | grep -q "Extension Manager"; then
    test_result "Extension Manager in Tools" "PASS"
else
    test_result "Extension Manager in Tools" "FAIL" "Not in menu"
fi

# Test 14: Sensors
echo ""
echo "=== Sensor Tests ==="
SENSORS=$(tasmota_cmd "Status 10")
if [ -n "$SENSORS" ]; then
    # DS18B20 sensors
    DS_COUNT=$(echo "$SENSORS" | grep -oP '"DS18B20[^"]*"' | wc -l)
    if [ "$DS_COUNT" -gt 0 ]; then
        test_result "DS18B20 Sensors" "PASS" "$DS_COUNT sensor(s) found"
        # Show temperatures
        echo "$SENSORS" | grep -oP '"DS18B20[^}]+' | while read -r sensor; do
            ID=$(echo "$sensor" | grep -oP '"Id":"[^"]+' | cut -d'"' -f4)
            TEMP=$(echo "$sensor" | grep -oP '"Temperature":[0-9.]+' | cut -d':' -f2)
            echo "   - Sensor $ID: ${TEMP}°C"
        done
    else
        test_result "DS18B20 Sensors" "WARN" "No DS18B20 sensors found"
    fi
    
    # BME280 sensors
    BME_COUNT=$(echo "$SENSORS" | grep -oP '"BME280[^"]*"' | wc -l)
    if [ "$BME_COUNT" -gt 0 ]; then
        test_result "BME280 Sensors" "PASS" "$BME_COUNT sensor(s) found"
        echo "$SENSORS" | grep -oP '"BME280[^}]+' | while read -r sensor; do
            TEMP=$(echo "$sensor" | grep -oP '"Temperature":[0-9.]+' | cut -d':' -f2)
            echo "   - BME280: ${TEMP}°C"
        done
    else
        test_result "BME280 Sensors" "WARN" "No BME280 sensors (I2C not connected?)"
    fi
else
    test_result "Sensor Status" "FAIL" "Cannot read sensors"
fi

# Test 15: Files
echo ""
echo "=== File System Tests ==="
FILES=$(curl -s --max-time 5 "$TASMOTA_URL/ufsd?download=/" 2>/dev/null)

if echo "$FILES" | grep -q "autoexec.be"; then
    test_result "autoexec.be" "PASS"
else
    test_result "autoexec.be" "FAIL" "File missing"
fi

if echo "$FILES" | grep -q "display.ini"; then
    test_result "display.ini" "PASS"
else
    test_result "display.ini" "FAIL" "File missing"
fi

if echo "$FILES" | grep -q "pages.jsonl"; then
    test_result "pages.jsonl" "PASS"
else
    test_result "pages.jsonl" "FAIL" "File missing"
fi

# Test 16: Template
echo ""
echo "=== Configuration Tests ==="
TEMPLATE=$(tasmota_cmd "Template")
if echo "$TEMPLATE" | grep -q "ESP32S3-Geek"; then
    test_result "Template Name" "PASS" "ESP32S3-Geek"
else
    NAME=$(echo "$TEMPLATE" | grep -oP '"NAME":"[^"]+' | cut -d'"' -f4)
    test_result "Template Name" "WARN" "Name is: $NAME"
fi

# Check GPIO configuration
if echo "$TEMPLATE" | grep -q "1312"; then
    test_result "DS18x20 GPIO Config" "PASS"
else
    test_result "DS18x20 GPIO Config" "WARN" "DS18x20 (1312) not in template"
fi

if echo "$TEMPLATE" | grep -q "640"; then
    test_result "I2C SDA GPIO Config" "PASS"
else
    test_result "I2C SDA GPIO Config" "WARN" "I2C SDA (640) not in template"
fi

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "${GREEN}Passed${NC}: $PASSED"
echo -e "${YELLOW}Warnings${NC}: $WARNINGS"
echo -e "${RED}Failed${NC}: $FAILED"
echo "----------------------------------------"

TOTAL=$((PASSED + FAILED))
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
elif [ "$FAILED" -lt 3 ]; then
    echo -e "${YELLOW}Some tests failed, but device is mostly functional${NC}"
    exit 1
else
    echo -e "${RED}Multiple failures detected - device needs attention${NC}"
    exit 2
fi
