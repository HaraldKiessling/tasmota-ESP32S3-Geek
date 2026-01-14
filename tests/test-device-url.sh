#!/bin/bash
# test-device-url.sh - Test Tasmota ESP32S3-Geek device via URL
# Version: 15.2.0
# by Harald Kiessling

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEVICE_URL=""
TEST_RESULTS_DIR="$(dirname "$0")/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_FILE=""

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Functions
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
    echo "[TEST] $1" >> "$RESULT_FILE"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    echo "[PASS] $1" >> "$RESULT_FILE"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo "[FAIL] $1" >> "$RESULT_FILE"
    ((TESTS_FAILED++))
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$RESULT_FILE"
}

tasmota_cmd() {
    local cmd="$1"
    local response=$(curl -s -m 10 "${DEVICE_URL}/cm?cmnd=${cmd}")
    echo "$response"
}

# Parse arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <device_url>"
    echo "Example: $0 http://192.168.0.77"
    exit 1
fi

DEVICE_URL="$1"
DEVICE_NAME=$(echo "$DEVICE_URL" | sed 's|https://||' | sed 's|http://||' | cut -d'.' -f1)
RESULT_FILE="$TEST_RESULTS_DIR/test_${DEVICE_NAME}_${TIMESTAMP}.log"

# Create results directory
mkdir -p "$TEST_RESULTS_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota ESP32S3-Geek Device Test${NC}"
echo -e "${GREEN}Device: $DEVICE_URL${NC}"
echo -e "${GREEN}Timestamp: $TIMESTAMP${NC}"
echo -e "${GREEN}========================================${NC}"

# Start logging
echo "========================================" > "$RESULT_FILE"
echo "Tasmota ESP32S3-Geek Device Test" >> "$RESULT_FILE"
echo "Device: $DEVICE_URL" >> "$RESULT_FILE"
echo "Timestamp: $TIMESTAMP" >> "$RESULT_FILE"
echo "========================================" >> "$RESULT_FILE"
echo "" >> "$RESULT_FILE"

# Test 1: Device Reachability
log_test "Device Reachability"
((TESTS_TOTAL++))
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "$DEVICE_URL/")
if [ "$HTTP_CODE" = "200" ]; then
    log_pass "Device is reachable at $DEVICE_URL (HTTP $HTTP_CODE)"
else
    log_fail "Device is not reachable at $DEVICE_URL (HTTP $HTTP_CODE)"
fi

# Test 2: Tasmota Version
log_test "Tasmota Version"
((TESTS_TOTAL++))
STATUS=$(tasmota_cmd "Status%202")
VERSION=$(echo "$STATUS" | grep -o '"Version":"[^"]*"' | cut -d'"' -f4)
BUILD_DATE=$(echo "$STATUS" | grep -o '"BuildDateTime":"[^"]*"' | cut -d'"' -f4)
if [[ "$VERSION" == *"15.2.0"* ]]; then
    log_pass "Tasmota version: $VERSION"
    if [[ "$VERSION" == *"esp32s3geek"* ]]; then
        log_pass "Custom firmware detected: esp32s3geek"
    fi
else
    log_fail "Unexpected Tasmota version: $VERSION"
fi
log_info "Build date: $BUILD_DATE"

# Test 3: Device Name
log_test "Device Name"
((TESTS_TOTAL++))
STATUS0=$(tasmota_cmd "Status%200")
DEVICE_NAME_RESP=$(echo "$STATUS0" | grep -o '"DeviceName":"[^"]*"' | cut -d'"' -f4)
if [ -n "$DEVICE_NAME_RESP" ]; then
    log_pass "Device name: $DEVICE_NAME_RESP"
else
    log_fail "No device name found"
fi

# Test 4: Module Template
log_test "Module Template"
((TESTS_TOTAL++))
TEMPLATE=$(tasmota_cmd "Template")
if [[ "$TEMPLATE" == *"ESP32S3-Geek"* ]]; then
    log_pass "Template is configured: ESP32S3-Geek"
else
    log_fail "Template not configured correctly"
fi

# Test 5: WiFi Connection
log_test "WiFi Connection"
((TESTS_TOTAL++))
WIFI_SSID=$(echo "$STATUS0" | grep -o '"SSId":"[^"]*"' | cut -d'"' -f4)
WIFI_RSSI=$(echo "$STATUS0" | grep -o '"RSSI":[0-9]*' | cut -d':' -f2)
if [ -n "$WIFI_SSID" ] && [ "$WIFI_RSSI" -gt 0 ]; then
    log_pass "WiFi connected to: $WIFI_SSID (RSSI: $WIFI_RSSI)"
else
    log_fail "WiFi not connected properly"
fi

# Test 6: I2C Scan
log_test "I2C Sensors"
((TESTS_TOTAL++))
I2C_SCAN=$(tasmota_cmd "I2CScan")
if [[ "$I2C_SCAN" == *"0x76"* ]] && [[ "$I2C_SCAN" == *"0x77"* ]]; then
    log_pass "I2C sensors found: BME280 at 0x76 and 0x77"
elif [[ "$I2C_SCAN" == *"0x76"* ]] || [[ "$I2C_SCAN" == *"0x77"* ]]; then
    log_pass "I2C sensor found (partial): $I2C_SCAN"
elif [[ "$I2C_SCAN" == *"No devices found"* ]]; then
    log_info "No I2C devices (expected for DS18B20 setup)"
else
    log_fail "I2C scan failed"
fi

# Test 7: Sensor Data
log_test "Sensor Data"
((TESTS_TOTAL++))
SENSOR_DATA=$(tasmota_cmd "Status%208")
if [[ "$SENSOR_DATA" == *"BME280"* ]] || [[ "$SENSOR_DATA" == *"DS18B20"* ]]; then
    log_pass "Sensor data available"
    
    # Parse BME280 data
    if [[ "$SENSOR_DATA" == *"BME280-76"* ]]; then
        log_info "BME280-76 detected"
    fi
    if [[ "$SENSOR_DATA" == *"BME280-77"* ]]; then
        log_info "BME280-77 detected"
    fi
    
    # Parse DS18B20 data
    if [[ "$SENSOR_DATA" == *"DS18B20"* ]]; then
        DS_COUNT=$(echo "$SENSOR_DATA" | grep -o "DS18B20-[^\"]*" | wc -l)
        log_info "DS18B20 sensor(s) detected: $DS_COUNT"
    fi
else
    log_fail "No sensor data available"
fi
log_info "Sensor data: $SENSOR_DATA"

# Test 8: Display Configuration
log_test "Display Configuration"
((TESTS_TOTAL++))
DISPLAY_MODE=$(tasmota_cmd "DisplayMode")
if [[ "$DISPLAY_MODE" == *"DisplayMode"* ]]; then
    log_pass "Display is configured"
else
    log_fail "Display not configured"
fi

# Test 9: MQTT Status
log_test "MQTT Status"
((TESTS_TOTAL++))
MQTT_STATUS=$(tasmota_cmd "Status%206")
if [[ "$MQTT_STATUS" == *"MqttHost"* ]]; then
    MQTT_HOST=$(echo "$MQTT_STATUS" | grep -o '"MqttHost":"[^"]*"' | cut -d'"' -f4)
    MQTT_COUNT=$(echo "$MQTT_STATUS" | grep -o '"MqttCount":[0-9]*' | cut -d':' -f2)
    if [ "$MQTT_COUNT" -gt 0 ]; then
        log_pass "MQTT connected to: $MQTT_HOST (Count: $MQTT_COUNT)"
    else
        log_info "MQTT configured but not connected: $MQTT_HOST"
    fi
else
    log_info "MQTT not configured (optional)"
fi

# Test 10: Uptime
log_test "Device Uptime"
((TESTS_TOTAL++))
UPTIME=$(echo "$STATUS0" | grep -o '"Uptime":"[^"]*"' | cut -d'"' -f4)
if [ -n "$UPTIME" ]; then
    log_pass "Device uptime: $UPTIME"
else
    log_fail "Could not retrieve uptime"
fi

# Test 11: Free Heap
log_test "Memory Status"
((TESTS_TOTAL++))
HEAP=$(echo "$STATUS0" | grep -o '"Heap":[0-9]*' | cut -d':' -f2 | tr -d '\n')
if [ -n "$HEAP" ] && [ "$HEAP" -gt 100 ] 2>/dev/null; then
    log_pass "Free heap: ${HEAP}KB"
elif [ -n "$HEAP" ]; then
    log_fail "Low memory: ${HEAP}KB"
else
    log_fail "Could not retrieve heap memory"
fi

# Test 12: Custom Firmware Check
log_test "Custom Firmware Verification"
((TESTS_TOTAL++))
if [[ "$VERSION" == *"esp32s3geek"* ]]; then
    log_pass "Custom firmware 'esp32s3geek' verified"
else
    log_fail "Custom firmware identifier not found"
fi

# Summary
echo "" >> "$RESULT_FILE"
echo "========================================" >> "$RESULT_FILE"
echo "Test Summary" >> "$RESULT_FILE"
echo "========================================" >> "$RESULT_FILE"
echo "Total Tests: $TESTS_TOTAL" >> "$RESULT_FILE"
echo "Passed: $TESTS_PASSED" >> "$RESULT_FILE"
echo "Failed: $TESTS_FAILED" >> "$RESULT_FILE"
echo "Success Rate: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%" >> "$RESULT_FILE"
echo "========================================" >> "$RESULT_FILE"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Test Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Total Tests: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Success Rate: ${BLUE}$(( TESTS_PASSED * 100 / TESTS_TOTAL ))%${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Results saved to: ${YELLOW}$RESULT_FILE${NC}"

# Exit with error if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
