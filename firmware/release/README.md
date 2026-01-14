# Tasmota ESP32S3-Geek Firmware

## Download

### Version 15.0.1

**Neuinstallation (Factory)**:
- [tasmota32s3geek-v15.0.1-factory.bin](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1-factory.bin)
- Für neue/leere ESP32S3-Geek Geräte
- Enthält Bootloader und Partitionstabelle

**Update (OTA)**:
- [tasmota32s3geek-v15.0.1.bin](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/tasmota32s3geek-v15.0.1.bin)
- Für bestehende Tasmota Installation
- Kleinere Dateigröße, schnelleres Update

## Features

- ✅ DS18B20 Temperatursensoren (bis zu 10 pro GPIO)
- ✅ BME280 Sensoren auf I2C (2 Geräte)
- ✅ ST7789 TFT Display (240x135)
- ✅ MQTT Support
- ✅ Berry Scripting
- ✅ Web Interface
- ✅ OTA Updates

## Hardware

- **Board**: Waveshare ESP32S3-Geek Stick
- **MCU**: ESP32-S3 @ 240MHz
- **Flash**: 16MB
- **PSRAM**: 8MB
- **Display**: ST7789 240x135 TFT

## Installation

### Schnellstart

1. **Download Firmware**:
   - Neuinstallation: `tasmota32s3geek-v15.0.1-factory.bin`
   - Update: `tasmota32s3geek-v15.0.1.bin`

2. **Flash mit esptool**:
   ```bash
   pip3 install esptool
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
     --before default_reset --after hard_reset write_flash \
     -z --flash_mode dio --flash_freq 80m --flash_size detect \
     0x0 tasmota32s3geek-v15.0.1-factory.bin
   ```

3. **WiFi konfigurieren**:
   - Verbinde mit AP: `tasmota-XXXXXX`
   - Öffne: http://192.168.4.1
   - WiFi Daten eingeben

4. **Template anwenden**:
   ```
   Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
   Module 0
   ```

### Detaillierte Anleitung

Siehe [Installation Guide](../../docs/installation.md)

## Konfiguration

### GPIO Template

| GPIO | Funktion | Beschreibung |
|------|----------|--------------|
| 0    | Button 1 | Taster |
| 16   | I2C SDA  | I2C Datenleitung |
| 17   | I2C SCL  | I2C Taktleitung |
| 22-27| SPI      | Display (MISO, MOSI, CLK, CS, DC, Backlight) |
| 29   | LedLink  | Status LED |
| 32   | DS18x20  | Dallas Temperatursensor Bus 1 |
| 33   | DS18x20  | Dallas Temperatursensor Bus 2 |

### Sensoren

**DS18B20** (GPIO 32, 33):
- Bis zu 10 Sensoren pro GPIO
- 4.7kΩ Pull-up Resistor erforderlich
- 3.3V Versorgung

**BME280** (I2C):
- Adresse 0x76 (SDO → GND)
- Adresse 0x77 (SDO → VCC)
- Misst: Temperatur, Luftfeuchtigkeit, Luftdruck

### Display

**ST7789 TFT**:
- Auflösung: 240x135 Pixel
- Automatische Anzeige via Berry Script
- Zeigt: WiFi, IP, Zeit, Sensordaten

## Dateien

### Erforderlich für Installation
- `tasmota32s3geek-v15.0.1-factory.bin` - Factory Firmware
- `tasmota32s3geek-v15.0.1.bin` - OTA Firmware

### Konfigurationsdateien
- `../../config/template.json` - GPIO Template
- `../../config/autoexec.be` - Berry Display Script
- `../../config/template-commands.txt` - Tasmota Befehle

## Changelog

### Version 15.0.1 (2026-01-11)
- Initial release
- Tasmota 15.0.1 base
- ESP32S3-Geek support
- DS18B20 multi-sensor support
- BME280 dual sensor support
- ST7789 display integration
- Berry display automation
- Custom branding

## Support

- **GitHub**: https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek
- **Issues**: https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues
- **Tasmota Docs**: https://tasmota.github.io/docs/

## License

GPL-3.0 (same as Tasmota)

## Credits

- **Tasmota**: Theo Arends and contributors
- **ESP32S3-Geek**: Harald Kiessling
- **Hardware**: Waveshare
