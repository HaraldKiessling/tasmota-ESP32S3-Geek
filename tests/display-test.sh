#!/bin/bash
# Display Test für Tasmota ESP32S3-Geek
# Prüft ob autoexec.be und pages.jsonl korrekt funktionieren
#
# Testet:
# - Berry/HASPmota läuft
# - Konfigurationsdateien vorhanden
# - IP-Adresse (p1b12)
# - SSID (p1b13)
# - Uhrzeit (p1b14)
# - BME280 Sensoren (p1b30, p1b31)
# - DS18x20 Sensoren (p1b20-p1b29)
#
# Usage: TASMOTA_URL=http://192.168.0.77 ./display-test.sh

set +e

TASMOTA_URL="${TASMOTA_URL:-}"

if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL not set"
    echo "Usage: TASMOTA_URL=http://192.168.0.77 ./display-test.sh"
    exit 1
fi

TASMOTA_URL="${TASMOTA_URL%/}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "========================================"
echo "Display Test - Tasmota ESP32S3-Geek"
echo "========================================"
echo "Target: $TASMOTA_URL"
echo "Date: $(date)"
echo "----------------------------------------"

# Helper: Execute Tasmota command
tasmota_cmd() {
    curl -s --max-time 10 --get --data-urlencode "cmnd=$1" "$TASMOTA_URL/cm" 2>/dev/null
}

# Helper: Get HASPmota label text via Berry Console
# Uses /bc endpoint which returns Berry output directly
# Response format: "code<SOH>output" where SOH is \x01
get_label_text() {
    local id="$1"
    local code="var o=global.('p1b${id}'); print(o!=nil ? o.text : 'NIL')"
    local result=$(curl -s --max-time 10 --get --data-urlencode "c1=$code" "$TASMOTA_URL/bc?c2=0" 2>/dev/null)
    # Extract text after SOH character (0x01) and trim
    local text=$(echo "$result" | sed 's/.*\x01//' | tr -d '\n\r')
    # Handle NIL marker
    if [ "$text" = "NIL" ]; then
        echo "nil"
    else
        echo "$text"
    fi
}

# Test result helper
test_check() {
    local name="$1"
    local pass="$2"
    local details="$3"
    
    if [ "$pass" = "true" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $name"
        [ -n "$details" ] && echo "   $details"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $name"
        [ -n "$details" ] && echo "   $details"
        FAILED=$((FAILED + 1))
    fi
}

# Check device reachability
echo ""
echo "=== Connectivity ==="
if ! curl -s --max-time 5 "$TASMOTA_URL/" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Device not reachable${NC}"
    exit 1
fi
echo -e "${GREEN}Device reachable${NC}"

# Check Berry runtime
echo ""
echo "=== Runtime Tests ==="
BERRY_STATUS=$(tasmota_cmd "Status 0" | grep -oP '"Berry":\{[^}]+\}')
if [ -n "$BERRY_STATUS" ]; then
    HEAP=$(echo "$BERRY_STATUS" | grep -oP '"HeapUsed":[0-9]+' | cut -d':' -f2)
    OBJECTS=$(echo "$BERRY_STATUS" | grep -oP '"Objects":[0-9]+' | cut -d':' -f2)
    test_check "Berry Runtime" "true" "Heap: ${HEAP}KB, Objects: $OBJECTS"
else
    test_check "Berry Runtime" "false" "Berry not running"
fi

# Check dashboard driver via Berry Console
DASHBOARD=$(curl -s --max-time 10 --get --data-urlencode "c1=print(global.dashboard != nil)" "$TASMOTA_URL/bc?c2=0" 2>/dev/null)
if echo "$DASHBOARD" | grep -q "true"; then
    test_check "Dashboard Driver" "true" "global.dashboard registered"
else
    test_check "Dashboard Driver" "false" "global.dashboard not found"
fi

# Check config files
echo ""
echo "=== Configuration Files ==="
FILES=$(curl -s --max-time 5 "$TASMOTA_URL/ufsd?download=/" 2>/dev/null)

if echo "$FILES" | grep -q "autoexec.be"; then
    test_check "autoexec.be" "true" "File exists"
else
    test_check "autoexec.be" "false" "File missing"
fi

if echo "$FILES" | grep -q "pages.jsonl"; then
    test_check "pages.jsonl" "true" "File exists"
else
    test_check "pages.jsonl" "false" "File missing"
fi

if echo "$FILES" | grep -q "display.ini"; then
    test_check "display.ini" "true" "File exists"
else
    test_check "display.ini" "false" "File missing"
fi

# Get expected values from device
echo ""
echo "=== Reading Device Data ==="

# IP Address (Status 5)
STATUS5=$(tasmota_cmd "Status 5")
EXPECTED_IP=$(echo "$STATUS5" | grep -oP '"IPAddress":"[^"]+' | head -1 | cut -d'"' -f4)
echo "Expected IP: $EXPECTED_IP"

# SSID (Status 11)
STATUS11=$(tasmota_cmd "Status 11")
EXPECTED_SSID=$(echo "$STATUS11" | grep -oP '"SSId":"[^"]+' | cut -d'"' -f4)
echo "Expected SSID: $EXPECTED_SSID"

# Sensors (Status 10)
STATUS10=$(tasmota_cmd "Status 10")

# Count sensors
DS_COUNT=$(echo "$STATUS10" | grep -oP '"DS18[BS]20-[^"]+' | wc -l)
BME_COUNT=$(echo "$STATUS10" | grep -oP '"BME280-[^"]+' | wc -l)
echo "DS18x20 sensors: $DS_COUNT"
echo "BME280 sensors: $BME_COUNT"

# Read display values via Berry
echo ""
echo "=== Display Label Tests ==="

# Test IP (p1b12)
DISPLAY_IP=$(get_label_text "12")
if [ "$DISPLAY_IP" = "$EXPECTED_IP" ]; then
    test_check "IP Address (p1b12)" "true" "Display: '$DISPLAY_IP'"
elif [ "$DISPLAY_IP" = "nil" ]; then
    test_check "IP Address (p1b12)" "false" "Label not initialized (nil)"
else
    test_check "IP Address (p1b12)" "false" "Expected: '$EXPECTED_IP', Display: '$DISPLAY_IP'"
fi

# Test SSID (p1b13)
DISPLAY_SSID=$(get_label_text "13")
if [ "$DISPLAY_SSID" = "$EXPECTED_SSID" ]; then
    test_check "SSID (p1b13)" "true" "Display: '$DISPLAY_SSID'"
elif [ "$DISPLAY_SSID" = "nil" ]; then
    test_check "SSID (p1b13)" "false" "Label not initialized (nil)"
else
    test_check "SSID (p1b13)" "false" "Expected: '$EXPECTED_SSID', Display: '$DISPLAY_SSID'"
fi

# Test Time (p1b14) - format HH:MM:SS
DISPLAY_TIME=$(get_label_text "14")
if echo "$DISPLAY_TIME" | grep -qE '^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$'; then
    test_check "Time Format (p1b14)" "true" "Display: '$DISPLAY_TIME'"
elif [ "$DISPLAY_TIME" = "nil" ]; then
    test_check "Time Format (p1b14)" "false" "Label not initialized (nil)"
else
    test_check "Time Format (p1b14)" "false" "Expected: HH:MM:SS, Display: '$DISPLAY_TIME'"
fi

# Test BME280 sensors (p1b30, p1b31)
echo ""
echo "=== BME280 Sensors ==="

if [ "$BME_COUNT" -gt 0 ]; then
    BME_TEMPS=$(echo "$STATUS10" | grep -oP '"BME280-[0-9A-Fa-f]+"\s*:\s*\{[^}]*"Temperature":[0-9.-]+' | grep -oP '"Temperature":[0-9.-]+' | cut -d':' -f2)
    
    BME_IDX=0
    for TEMP in $BME_TEMPS; do
        if [ $BME_IDX -ge 2 ]; then break; fi
        
        LABEL_ID=$((30 + BME_IDX))
        DISPLAY_BME=$(get_label_text "$LABEL_ID")
        
        if echo "$DISPLAY_BME" | grep -q "$TEMP"; then
            test_check "BME280 #$((BME_IDX+1)) (p1b$LABEL_ID)" "true" "Temp: ${TEMP}°C, Display: '$DISPLAY_BME'"
        elif [ "$DISPLAY_BME" = "nil" ]; then
            test_check "BME280 #$((BME_IDX+1)) (p1b$LABEL_ID)" "false" "Label not initialized (nil)"
        else
            test_check "BME280 #$((BME_IDX+1)) (p1b$LABEL_ID)" "false" "Expected temp: $TEMP, Display: '$DISPLAY_BME'"
        fi
        
        BME_IDX=$((BME_IDX + 1))
    done
else
    echo "No BME280 sensors connected - skipping"
fi

# Test DS18x20 sensors (p1b20-p1b29)
echo ""
echo "=== DS18x20 Sensors ==="

if [ "$DS_COUNT" -gt 0 ]; then
    DS_IDX=0
    
    # Get sensor keys sorted alphabetically (as autoexec.be does)
    SENSOR_KEYS=$(echo "$STATUS10" | grep -oP '"DS18[BS]20-[A-F0-9]+"' | tr -d '"' | sort)
    
    for SENSOR_KEY in $SENSOR_KEYS; do
        if [ $DS_IDX -ge 10 ]; then break; fi
        
        SENSOR_TEMP=$(echo "$STATUS10" | grep -oP "\"$SENSOR_KEY\"[^}]+\"Temperature\":[0-9.-]+" | grep -oP '"Temperature":[0-9.-]+' | cut -d':' -f2)
        
        if [ -n "$SENSOR_TEMP" ]; then
            LABEL_ID=$((20 + DS_IDX))
            DISPLAY_DS=$(get_label_text "$LABEL_ID")
            
            if echo "$DISPLAY_DS" | grep -q "$SENSOR_TEMP"; then
                test_check "$SENSOR_KEY (p1b$LABEL_ID)" "true" "Temp: ${SENSOR_TEMP}°C, Display: '$DISPLAY_DS'"
            elif [ "$DISPLAY_DS" = "nil" ]; then
                test_check "$SENSOR_KEY (p1b$LABEL_ID)" "false" "Label not initialized (nil)"
            else
                test_check "$SENSOR_KEY (p1b$LABEL_ID)" "false" "Expected temp: $SENSOR_TEMP, Display: '$DISPLAY_DS'"
            fi
            
            DS_IDX=$((DS_IDX + 1))
        fi
    done
else
    echo "No DS18x20 sensors connected - skipping"
fi

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "${GREEN}Passed${NC}: $PASSED"
echo -e "${RED}Failed${NC}: $FAILED"
echo "----------------------------------------"

TOTAL=$((PASSED + FAILED))
if [ "$FAILED" -eq 0 ] && [ "$TOTAL" -gt 0 ]; then
    echo -e "${GREEN}All display tests passed!${NC}"
    exit 0
elif [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}No tests executed${NC}"
    exit 1
else
    echo -e "${RED}Some display tests failed${NC}"
    exit 1
fi
