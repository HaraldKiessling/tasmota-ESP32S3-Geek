# Tasmota ESP32S3-Geek

**Custom Tasmota firmware for Waveshare ESP32S3-Geek stick**

![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Version](https://img.shields.io/badge/Version-v7-blue)
![Tasmota](https://img.shields.io/badge/Tasmota-15.0.1-orange)

## 🎯 Latest Release: v7 + Custom Firmware (2026-01-11)

**✅ CUSTOM ESP32-S3 LVGL FIRMWARE BUILT**
- tasmota32s3-lvgl-15.0.1.bin with full HASPmota support
- 2.5 MB firmware, 87.8% flash usage
- Compatible partition scheme with esp32s3geek
- Verified LVGL and HASPmota in binary
- Ready for serial flash deployment

**✅ HYBRID APPROACH WORKING ON TASMOTA-101**
- Automatic sensor detection (5x DS18B20)
- Dynamic pages.jsonl generation
- Display updates every 2 seconds
- Production ready configuration

**⚠️ DEVICES IN SAFEBOOT**
- tasmota-75 and tasmota-77 require serial flash recovery
- Normal firmware partition damaged from OTA attempts
- Physical access required for deployment

[📥 Download Custom Firmware](firmware/tasmota32s3-lvgl-15.0.1.bin)  
[📖 Build Documentation](docs/CUSTOM_FIRMWARE_BUILD_SUCCESS.md)

## Features

✅ **DS18B20 Temperature Sensors** (GPIO 6, 13, 14)  
✅ **I2C Support** (GPIO 16 SDA, 17 SCL) for BME280, etc.  
✅ **ST7789 TFT Display** (240x135) with HASPmota  
✅ **Automatic Display Updates** every 2 seconds  
✅ **MQTT Integration** with configurable telemetry  
✅ **OTA Updates** with preserved WiFi settings  
✅ **Berry Scripting** with minimal configuration  
✅ **Universal Display Driver** with display.ini  
✅ **text_rule** based sensor updates (no manual coding)  
✅ **Complete Documentation** and tested configuration  

## Hardware Specification

### ESP32S3-Geek Pinout
- **DS18B20**: GPIO 6, 13, or 14
- **I2C SDA**: GPIO 16
- **I2C SCL**: GPIO 17
- **UART TX**: GPIO 43
- **UART RX**: GPIO 44
- **Display**: ST7789 (via display.ini)

### Tested Configuration
- **Board**: Waveshare ESP32S3-Geek
- **Sensors**: 2x DS18B20 on GPIO 13
- **Display**: ST7789 240x135 TFT
- **Status**: ✅ All features working

## Quick Start

### 2. Flash Firmware

```bash
pip3 install esptool

# Factory install (first time)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 firmware/release/v7/tasmota32s3geek-v15.0.1-v7-factory.bin
```

### 3. Configure WiFi

1. Connect to AP: `tasmota-XXXXXX`
2. Open: http://192.168.4.1
3. Enter WiFi credentials

### 4. Upload Configuration Files

Via web interface (Tools → Manage File system):
1. Upload `display.ini`
2. Upload `pages.jsonl`
3. Upload `autoexec.be`

All files are in `firmware/release/v7/` folder.

### 5. Apply GPIO Template

Via Console:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,1,1,0,4864,1,1312,1,1,1,1,1,1,1312,1312,1,640,608,1,1,1,3840,6210,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,3200,3232],"FLAG":0,"BASE":1}
Module 0
Restart 1
```

### 6. Verify

After restart (~30 seconds):
```bash
curl -s "http://tasmota-77.local/cm?cmnd=Status%2010" | jq .
```

You should see DS18B20 sensors detected.

## Configuration Files

### Firmware
- **tasmota32s3-lvgl-15.0.1.bin** - ✅ Custom ESP32-S3 LVGL firmware (RECOMMENDED)
- Full LVGL and HASPmota support
- Compatible partition scheme
- Ready for serial flash

### Recommended Configuration (Hybrid Approach)
- **autoexec-final.be** - Automatic sensor detection, generates pages.jsonl dynamically
- **display.ini** - Display driver configuration (ST7789)
- **template.json** - GPIO configuration with correct pins

### Alternative Configurations
- **autoexec-101.be** - Minimal (3 lines), requires manual pages.jsonl
- **pages-final.jsonl** - text_rule based, manual sensor configuration
- **autoexec-75-dynamic.be** - HASPmota labels, dynamic detection (requires working HASPmota)

See [Scripts Guide](docs/SCRIPTS-GUIDE.md) and [Custom Firmware Build](docs/CUSTOM_FIRMWARE_BUILD_SUCCESS.md) for details.

## Display Features
- Download: [autoexec.be](config/autoexec.be)
- Upload über Tasmota Web Interface → Manage File System
- Restart

## Projektstruktur

```
tasmota-ESP32S3-Geek/
├── config/                      # Konfigurationsdateien
│   ├── autoexec.be             # Berry Display Script
│   ├── template.json           # GPIO Template
│   ├── template-commands.txt   # Tasmota Befehle
│   ├── gpio-mapping.md         # GPIO Dokumentation
│   └── display-config.md       # Display Konfiguration
├── docs/                        # Dokumentation
│   ├── installation.md         # Installationsanleitung
│   ├── requirements.md         # Anforderungen
│   └── testing.md              # Test Dokumentation
├── firmware/                    # Firmware Dateien
│   ├── tasmota32s3-lvgl-15.0.1.bin  # ✅ Custom LVGL firmware
│   └── release/                # Release Binaries
│       ├── tasmota32s3geek-v15.0.1.bin
│       ├── tasmota32s3geek-v15.0.1-factory.bin
│       ├── version.txt
│       └── README.md
├── scripts/                     # Build & Flash Scripts
│   ├── build.sh                # Firmware bauen
│   └── flash.sh                # Firmware flashen
├── tests/                       # Test Scripts
│   ├── test-device.sh          # Device Tests
│   ├── run-all-tests.sh        # Alle Tests
│   └── results/                # Test Ergebnisse
├── Tasmota/                     # Tasmota Source (gitignored)
└── README.md                    # Diese Datei
```

## Dokumentation

### Firmware Build & Deployment
- [Custom Firmware Build](docs/CUSTOM_FIRMWARE_BUILD_SUCCESS.md) - ✅ Build-Prozess und Ergebnisse
- [Firmware Test Results](docs/FIRMWARE_TEST_RESULTS.md) - Test-Ergebnisse und Analyse
- [Firmware Recovery](docs/FIRMWARE_RECOVERY.md) - Recovery-Prozeduren
- [Final Solution](docs/FINAL_SOLUTION.md) - Empfohlene Lösungen

### Configuration & Testing
- [Configuration Comparison](docs/CONFIGURATION_COMPARISON.md) - Geräte-Vergleich
- [Scripts Guide](docs/SCRIPTS-GUIDE.md) - Berry Script Vergleich
- [Installation Guide](docs/installation.md) - Installationsanleitung
- [Testing Guide](docs/testing.md) - Test Dokumentation

### Hardware & GPIO
- [Hardware Specification](docs/HARDWARE.md) - Hardware Details
- [GPIO Mapping](config/gpio-mapping.md) - GPIO Pin Belegung
- [Display Config](config/display-config.md) - Display Konfiguration

## Build von Source

### Custom ESP32-S3 LVGL Firmware

**✅ Successfully Built**: tasmota32s3-lvgl-15.0.1.bin

```bash
# Setup
cd Tasmota
python3 -m venv .venv
.venv/bin/pip install platformio

# Checkout v15.0.1
git checkout v15.0.1

# Build
.venv/bin/pio run -e tasmota32s3-lvgl
```

**Build Result**:
- Size: 2.5 MB (87.8% flash)
- RAM: 18.9% (61892 bytes)
- Build Time: 393 seconds
- Features: LVGL, HASPmota, DS18B20, BME280, ST7789

**Output**: `Tasmota/.pio/build/tasmota32s3-lvgl/firmware.bin`

See [Build Documentation](docs/CUSTOM_FIRMWARE_BUILD_SUCCESS.md) for details.

## Sensoren

### DS18B20 (Dallas Temperature)

**Anschluss**:
- VCC → 3.3V
- GND → GND
- DATA → GPIO 32 oder GPIO 33
- Pull-up: 4.7kΩ zwischen DATA und VCC

**Unterstützung**:
- Bis zu 10 Sensoren pro GPIO
- 3 GPIO verfügbar (32, 33, und weitere)
- Automatische Erkennung

### BME280 (I2C)

**Anschluss**:
- VCC → 3.3V
- GND → GND
- SDA → GPIO 16
- SCL → GPIO 17

**Adressen**:
- BME280-76: 0x76 (SDO → GND)
- BME280-77: 0x77 (SDO → VCC)

**Messwerte**:
- Temperatur (°C)
- Luftfeuchtigkeit (%)
- Luftdruck (hPa)

## Display

**ST7789 TFT Display** (240x135 Pixel):
- Automatische Anzeige via Berry Script
- Update alle 5 Sekunden
- Zeigt: Device Name, WiFi SSID, IP, Zeit, Sensordaten

**Layout**:
```
ESP32S3-Geek
SSID: <WiFi Name>
IP: <IP Adresse>
<Datum> <Uhrzeit>
BME76: 22.5°C 45%
BME77: 23.1°C 48%
DS1: 21.8°C
DS2: 22.3°C
```

## MQTT

**Konfiguration**:
- Web Interface → Configuration → Configure MQTT
- Host, Port, User, Password eingeben
- Topic: `tasmota_%06X` (Standard)

**Topics**:
- `tele/tasmota_XXXXXX/SENSOR` - Sensor Daten (alle 60s)
- `stat/tasmota_XXXXXX/STATUS` - Status Updates
- `cmnd/tasmota_XXXXXX/POWER` - Befehle

## Testing

### Automatisierte Tests

**Einzelnes Gerät**:
```bash
./tests/test-device.sh 192.168.0.75
```

**Alle Geräte**:
```bash
./tests/run-all-tests.sh
```

**Test Umgebung**:
- tasmota-75 (192.168.0.75): Update Installation mit BME280
- tasmota-77 (192.168.0.77): Neuinstallation mit DS18B20

### Test Ergebnisse

Tests prüfen:
- ✅ Device Erreichbarkeit
- ✅ Web Interface
- ✅ Tasmota Version
- ✅ Template Konfiguration
- ✅ WiFi Verbindung
- ✅ I2C Sensoren
- ✅ Sensor Daten
- ✅ Display Konfiguration
- ✅ MQTT Status
- ✅ Uptime & Memory

Ergebnisse werden gespeichert in: `tests/results/`

## OTA Updates

### Via Web Interface
1. Firmware hochladen: `tasmota32s3geek-v15.0.1.bin`
2. "Start Upgrade" klicken
3. Warten auf Neustart

### Via MQTT
```bash
mosquitto_pub -h <broker> -t "cmnd/tasmota_XXXXXX/OtaUrl" \
  -m "https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1.bin"
mosquitto_pub -h <broker> -t "cmnd/tasmota_XXXXXX/Upgrade" -m "1"
```

## Troubleshooting

### Display bleibt schwarz
```bash
# Template prüfen
Template

# Display Mode setzen
DisplayMode 0
DisplayRotate 1

# Berry Script prüfen
Br load('autoexec.be')
```

### Sensoren nicht erkannt
```bash
# I2C Scan
I2CScan

# DS18B20 prüfen (Pull-up Resistor?)
Status 8
```

### WiFi Probleme
```bash
# WiFi Reset
Reset 1

# WiFi Status
Status 5
```

## Changelog

### Version 15.0.1 (2026-01-11)
- Initial Release
- Tasmota 15.0.1 Basis
- ESP32S3-Geek Support
- DS18B20 Multi-Sensor (bis zu 10 pro GPIO)
- BME280 Dual-Sensor (I2C)
- ST7789 Display Integration
- Berry Display Automation
- MQTT Support
- Custom Branding
- Vollständige Dokumentation
- Automatisierte Tests

## Lizenz

GPL-3.0 (wie Tasmota)

## Credits

- **Tasmota**: Theo Arends und Contributors
- **ESP32S3-Geek Firmware**: Harald Kiessling
- **Hardware**: Waveshare

## Support

- **GitHub**: https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek
- **Issues**: https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues
- **Tasmota Docs**: https://tasmota.github.io/docs/

## Links

### Firmware Downloads
- [Factory Firmware v15.0.1](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1-factory.bin)
- [OTA Firmware v15.0.1](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1.bin)

### Konfiguration
- [autoexec.be](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/config/autoexec.be)
- [template.json](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/config/template.json)
- [template-commands.txt](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/config/template-commands.txt)

### Dokumentation
- [Installation Guide](docs/installation.md)
- [Requirements](docs/requirements.md)
- [Testing Guide](docs/testing.md)
- [GPIO Mapping](config/gpio-mapping.md)
- [Display Config](config/display-config.md)

## Test Geräte

- **tasmota-75** (https://tasmota-75.samharald.eu): Update Installation mit 2x BME280
- **tasmota-77** (https://tasmota-77.samharald.eu): Neuinstallation mit 2x DS18B20
