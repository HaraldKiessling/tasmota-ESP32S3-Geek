#!/bin/bash
# Display Test für tasmota-77
# Zeigt IP, SSID, Uhrzeit und DS18B20 Sensoren

DEVICE_URL="https://tasmota-77.samharald.eu"

echo "=== Display Test für tasmota-77 ==="
echo ""

# Hole aktuelle Daten
echo "Hole Sensordaten..."
SENSORS=$(curl -s "$DEVICE_URL/cm?cmnd=Status%208")
WIFI=$(curl -s "$DEVICE_URL/cm?cmnd=Status%205")
TIME=$(date +"%H:%M")

# Parse Daten
IP=$(echo "$WIFI" | grep -o '"IPAddress":"[^"]*"' | cut -d'"' -f4)
SSID=$(curl -s "$DEVICE_URL/cm?cmnd=Status%200" | grep -o '"SSId":"[^"]*"' | cut -d'"' -f4)
DS1_TEMP=$(echo "$SENSORS" | grep -o '"DS18B20-5329E2":{"Id":"[^"]*","Temperature":[0-9.]*' | grep -o 'Temperature":[0-9.]*' | cut -d':' -f2)
DS2_TEMP=$(echo "$SENSORS" | grep -o '"DS18B20-51C76D":{"Id":"[^"]*","Temperature":[0-9.]*' | grep -o 'Temperature":[0-9.]*' | cut -d':' -f2)

echo "IP: $IP"
echo "SSID: $SSID"
echo "Zeit: $TIME"
echo "DS18B20-5329E2: ${DS1_TEMP}°C"
echo "DS18B20-51C76D: ${DS2_TEMP}°C"
echo ""

# Erstelle Display Text
DISPLAY_CMD="DisplayText%20%5Bz%5D%5Bx0y0%5D%5Bf1%5DESP32S3-Geek"
DISPLAY_CMD="${DISPLAY_CMD}%5Bx0y15%5D%5Bf1%5DSSID:%20${SSID}"
DISPLAY_CMD="${DISPLAY_CMD}%5Bx0y30%5D%5Bf1%5DIP:%20${IP}"
DISPLAY_CMD="${DISPLAY_CMD}%5Bx0y45%5D%5Bf1%5DTime:%20${TIME}"
DISPLAY_CMD="${DISPLAY_CMD}%5Bx0y65%5D%5Bf1%5DDS-29E2:%20${DS1_TEMP}C"
DISPLAY_CMD="${DISPLAY_CMD}%5Bx0y80%5D%5Bf1%5DDS-C76D:%20${DS2_TEMP}C"

echo "Sende an Display..."
RESULT=$(curl -s "$DEVICE_URL/cm?cmnd=$DISPLAY_CMD")

if [[ "$RESULT" == *"DisplayText"* ]]; then
    echo "✅ Display Update erfolgreich!"
    echo ""
    echo "Display zeigt:"
    echo "  - ESP32S3-Geek"
    echo "  - SSID: $SSID"
    echo "  - IP: $IP"
    echo "  - Zeit: $TIME"
    echo "  - DS-29E2: ${DS1_TEMP}°C"
    echo "  - DS-C76D: ${DS2_TEMP}°C"
else
    echo "❌ Display Update fehlgeschlagen"
fi
