# Tasmota ESP32S3-Geek

Custom Tasmota 15.0.1 Firmware für Waveshare ESP32S3-Geek Stick mit Multi-Sensor Support

## Übersicht

Dieses Projekt stellt eine angepasste Tasmota Firmware für den Waveshare ESP32S3-Geek Stick bereit mit Unterstützung für:

- **DS18B20 Temperatursensoren**: Bis zu 10 Sensoren pro GPIO (3 GPIO verfügbar)
- **BME280 Sensoren**: 2 Geräte über I2C (Temperatur, Luftfeuchtigkeit, Luftdruck)
- **ST7789 TFT Display**: 240x135 Pixel mit automatischer Anzeige
- **MQTT**: Vollständige Integration
- **Berry Scripting**: Automatische Display-Updates
- **Web Interface**: Konfiguration und Monitoring

## Features

✅ Tasmota 15.0.1 (kompatibel mit ESP32S3-Geek)  
✅ Multi-Sensor Support (DS18B20 + BME280)  
✅ **LVGL Graphics Library** (v3)  
✅ Universal Display Driver  
✅ Enhanced WiFi Scan GUI  
✅ Automatische Display-Anzeige (IP, SSID, Zeit, Sensoren)  
✅ MQTT Integration mit konfigurierbarem TelePeriod  
✅ OTA Updates  
✅ Berry Scripting + UFileSys  
✅ Autoconf GPIO  
✅ Custom Branding (esp32s3geek / by Harald)  
✅ Vollständige Dokumentation  
✅ Automatisierte Tests  

## Hardware

- **Board**: Waveshare ESP32S3-Geek Stick
- **MCU**: ESP32-S3 @ 240MHz
- **Flash**: 16MB
- **PSRAM**: 8MB
- **Display**: ST7789 240x135 TFT
- **Sensoren**: DS18B20 (GPIO 32, 33), BME280 (I2C 0x76, 0x77)

## Schnellstart

### 1. Firmware Download

**Empfohlen: v3 LVGL (neueste Version)**:
```bash
# Neuinstallation (Factory)
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1-factory.bin

# OTA Update
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1-v3-lvgl.bin
```

**Alternative Versionen**:
- `tasmota32s3geek-v15.0.1.bin` - v1 Basis (2.0 MB)
- `tasmota32s3geek-v15.0.1-v2.bin` - v2 mit Compile Zeit (2.0 MB)
- `tasmota32s3geek-v15.0.1-v3-lvgl.bin` - v3 mit LVGL (2.7 MB) ✅ Empfohlen

### 2. Installation

**Automatisch** (empfohlen):
```bash
git clone https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek.git
cd tasmota-ESP32S3-Geek
./scripts/flash.sh
```

**Manuell**:
```bash
pip3 install esptool
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
  --before default_reset --after hard_reset write_flash \
  -z --flash_mode dio --flash_freq 80m --flash_size detect \
  0x0 tasmota32s3geek-v15.0.1-factory.bin
```

### 3. Konfiguration

**WiFi** (nach erstem Start):
- Verbinde mit AP: `tasmota-XXXXXX`
- Öffne: http://192.168.4.1
- WiFi Daten eingeben

**Template** (in Tasmota Console):
```
Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; DeviceName ESP32S3-Geek; DisplayMode 0; DisplayRotate 1; TelePeriod 60; SaveData 1; Restart 1
```

**Display Automation**:
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

### Anleitungen
- [Installation Guide](docs/installation.md) - Detaillierte Installationsanleitung
- [Requirements](docs/requirements.md) - Projektanforderungen
- [Testing Guide](docs/testing.md) - Test Dokumentation

### Konfiguration
- [GPIO Mapping](config/gpio-mapping.md) - GPIO Pin Belegung
- [Display Config](config/display-config.md) - Display Konfiguration
- [Template Commands](config/template-commands.txt) - Tasmota Befehle

### Firmware
- [Firmware README](firmware/release/README.md) - Download und Features
- [Version Info](firmware/release/version.txt) - Build Informationen

## Build von Source

### Voraussetzungen
```bash
# Python 3 und PlatformIO
python3 -m venv .venv
.venv/bin/pip install platformio

# Tasmota Source
git clone --depth 1 --branch v15.0.1 https://github.com/arendst/Tasmota.git
```

### Build
```bash
./scripts/build.sh
```

Firmware wird erstellt in: `firmware/release/`

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
