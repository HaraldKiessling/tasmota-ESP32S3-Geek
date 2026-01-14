#!/bin/bash
# run-all-tests.sh - Run all device tests
# Version: 15.2.0
# by Harald Kiessling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tasmota ESP32S3-Geek Test Suite${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Test devices
DEVICE_75="192.168.0.75"  # tasmota-75 (Update test with BME280)
DEVICE_77="192.168.0.77"  # tasmota-77 (New installation test with DS18B20)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test tasmota-75 (Update Installation)
echo -e "${BLUE}Testing tasmota-75 (Update Installation with BME280)${NC}"
echo -e "${YELLOW}Device: $DEVICE_75${NC}"
echo ""

if "$SCRIPT_DIR/test-device.sh" "$DEVICE_75"; then
    echo -e "${GREEN}✓ tasmota-75 tests passed${NC}"
    TEST_75_RESULT="PASS"
else
    echo -e "${RED}✗ tasmota-75 tests failed${NC}"
    TEST_75_RESULT="FAIL"
fi

echo ""
echo "========================================="
echo ""

# Test tasmota-77 (New Installation)
echo -e "${BLUE}Testing tasmota-77 (New Installation with DS18B20)${NC}"
echo -e "${YELLOW}Device: $DEVICE_77${NC}"
echo ""

if "$SCRIPT_DIR/test-device.sh" "$DEVICE_77"; then
    echo -e "${GREEN}✓ tasmota-77 tests passed${NC}"
    TEST_77_RESULT="PASS"
else
    echo -e "${RED}✗ tasmota-77 tests failed${NC}"
    TEST_77_RESULT="FAIL"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Overall Test Results${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "tasmota-75 (Update/BME280): ${TEST_75_RESULT}"
echo -e "tasmota-77 (New/DS18B20): ${TEST_77_RESULT}"
echo -e "${GREEN}========================================${NC}"

# Exit with error if any tests failed
if [ "$TEST_75_RESULT" = "FAIL" ] || [ "$TEST_77_RESULT" = "FAIL" ]; then
    exit 1
fi

exit 0
