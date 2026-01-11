#!/bin/bash
# test-device.sh - Test Tasmota ESP32S3-Geek device
# Version: 15.0.1
# by Harald Kiessling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEVICE_IP=""
TEST_RESULTS_DIR="$(dirname "$0")/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_FILE="$TEST_RESULTS_DIR/test_${DEVICE_IP}_${TIMESTAMP}.log"

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
    local response=$(curl -s "http://${DEVICE_IP}/cm?cmnd=${cmd}")
    echo "$response"
}

# Parse arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <device_ip>"
    echo "Example: $0 192.168.0.75"
    exit 1
fi

DEVICE_IP="$1"

# Create results directory
mkdir -p "$TEST_RESULTS_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota ESP32S3-Geek Device Test${NC}"
echo -e "${GREEN}Device: $DEVICE_IP${NC}"
echo -e "${GREEN}Timestamp: $TIMESTAMP${NC}"
echo -e "${GREEN}========================================${NC}"

# Start logging
echo "========================================" > "$RESULT_FILE"
echo "Tasmota ESP32S3-Geek Device Test" >> "$RESULT_FILE"
echo "Device: $DEVICE_IP" >> "$RESULT_FILE"
echo "Timestamp: $TIMESTAMP" >> "$RESULT_FILE"
echo "========================================" >> "$RESULT_FILE"
echo "" >> "$RESULT_FILE"

# Test 1: Device Reachability
log_test "Device Reachability"
((TESTS_TOTAL++))
if ping -c 1 -W 2 "$DEVICE_IP" > /dev/null 2>&1; then
    log_pass "Device is reachable at $DEVICE_IP"
else
    log_fail "Device is not reachable at $DEVICE_IP"
fi

# Test 2: Web Interface
log_test "Web Interface"
((TESTS_TOTAL++))
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://${DEVICE_IP}/")
if [ "$HTTP_CODE" = "200" ]; then
    log_pass "Web interface is accessible (HTTP $HTTP_CODE)"
else
    log_fail "Web interface is not accessible (HTTP $HTTP_CODE)"
fi

# Test 3: Tasmota Version
log_test "Tasmota Version"
((TESTS_TOTAL++))
STATUS=$(tasmota_cmd "Status%200")
VERSION=$(echo "$STATUS" | grep -o '"Version":"[^"]*"' | cut -d'"' -f4)
if [[ "$VERSION" == *"15.0.1"* ]]; then
    log_pass "Tasmota version: $VERSION"
else
    log_fail "Unexpected Tasmota version: $VERSION"
fi
log_info "Full version: $VERSION"

# Test 4: Device Name
log_test "Device Name"
((TESTS_TOTAL++))
DEVICE_NAME=$(echo "$STATUS" | grep -o '"DeviceName":"[^"]*"' | cut -d'"' -f4)
if [[ "$DEVICE_NAME" == *"Tasmota"* ]] || [[ "$DEVICE_NAME" == *"ESP32S3"* ]]; then
    log_pass "Device name: $DEVICE_NAME"
else
    log_fail "Unexpected device name: $DEVICE_NAME"
fi

# Test 5: Module Template
log_test "Module Template"
((TESTS_TOTAL++))
TEMPLATE=$(tasmota_cmd "Template")
if [[ "$TEMPLATE" == *"ESP32S3-Geek"* ]]; then
    log_pass "Template is configured: ESP32S3-Geek"
else
    log_fail "Template not configured correctly"
fi
log_info "Template: $TEMPLATE"

# Test 6: WiFi Connection
log_test "WiFi Connection"
((TESTS_TOTAL++))
WIFI_SSID=$(echo "$STATUS" | grep -o '"SSId":"[^"]*"' | cut -d'"' -f4)
WIFI_RSSI=$(echo "$STATUS" | grep -o '"RSSI":[0-9]*' | cut -d':' -f2)
if [ -n "$WIFI_SSID" ] && [ "$WIFI_RSSI" -gt 0 ]; then
    log_pass "WiFi connected to: $WIFI_SSID (RSSI: $WIFI_RSSI)"
else
    log_fail "WiFi not connected properly"
fi

# Test 7: I2C Scan
log_test "I2C Sensors"
((TESTS_TOTAL++))
I2C_SCAN=$(tasmota_cmd "I2CScan")
if [[ "$I2C_SCAN" == *"0x76"* ]] && [[ "$I2C_SCAN" == *"0x77"* ]]; then
    log_pass "I2C sensors found: BME280 at 0x76 and 0x77"
elif [[ "$I2C_SCAN" == *"0x76"* ]] || [[ "$I2C_SCAN" == *"0x77"* ]]; then
    log_pass "I2C sensor found (partial): $I2C_SCAN"
else
    log_fail "I2C sensors not found"
fi
log_info "I2C Scan: $I2C_SCAN"

# Test 8: Sensor Data
log_test "Sensor Data"
((TESTS_TOTAL++))
sleep 2  # Wait for sensor reading
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
        log_info "DS18B20 sensor(s) detected"
    fi
else
    log_fail "No sensor data available"
fi
log_info "Sensor data: $SENSOR_DATA"

# Test 9: Display Configuration
log_test "Display Configuration"
((TESTS_TOTAL++))
DISPLAY_MODE=$(tasmota_cmd "DisplayMode")
if [[ "$DISPLAY_MODE" == *"DisplayMode"* ]]; then
    log_pass "Display is configured"
else
    log_fail "Display not configured"
fi
log_info "Display mode: $DISPLAY_MODE"

# Test 10: MQTT Status (if configured)
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

# Test 11: Uptime
log_test "Device Uptime"
((TESTS_TOTAL++))
UPTIME=$(echo "$STATUS" | grep -o '"Uptime":"[^"]*"' | cut -d'"' -f4)
if [ -n "$UPTIME" ]; then
    log_pass "Device uptime: $UPTIME"
else
    log_fail "Could not retrieve uptime"
fi

# Test 12: Free Heap
log_test "Memory Status"
((TESTS_TOTAL++))
HEAP=$(echo "$STATUS" | grep -o '"Heap":[0-9]*' | cut -d':' -f2)
if [ "$HEAP" -gt 100 ]; then
    log_pass "Free heap: ${HEAP}KB"
else
    log_fail "Low memory: ${HEAP}KB"
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
