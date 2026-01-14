# Tasmota ESP32S3-Geek

Custom Tasmota configuration for Waveshare ESP32S3-Geek with ST7789 display, DS18B20 sensors, and I2C support.

![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Tasmota](https://img.shields.io/badge/Tasmota-15.2.0-orange)

---

## Quick Start

### 1. Flash Firmware

Use the standard `tasmota32s3-lvgl` firmware (v15.2.0 or later).

### 2. Apply GPIO Template

Open Tasmota console and paste:

```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
DisplayRotate 1
Restart 1
```

### 3. Upload Configuration Files

Upload these files to the device filesystem:
- `config/display.ini` → `/display.ini`
- `config/autoexec.be` → `/autoexec.be`
- `config/pages.jsonl` → `/pages.jsonl`

### 4. Connect Sensors (Optional)

**DS18B20 Temperature Sensors**:
- GPIO 6, 13, 14 (with 4.7kΩ pull-up resistor)

**I2C Sensors** (BME280, etc.):
- GPIO 16 (SDA), GPIO 17 (SCL)

---

## Features

- **DS18B20 Temperature Sensors** - Up to 10 sensors displayed
- **BME280 Support** - I2C temperature/humidity/pressure
- **ST7789 Display** - 240x135 TFT with HASPmota UI
- **Real-time Updates** - IP, SSID, time, and sensor data
- **Works without sensors** - Display shows network info even without sensors

---

## Display Layout

The HASPmota display shows:
- **Header (red)**: IP address, SSID, time, WiFi signal
- **BME280 sensors (yellow)**: Up to 2 sensors with I2C address
- **DS18x20 sensors (white)**: Up to 10 sensors with short ID

---

## Configuration Files

### config/display.ini

ST7789 display driver configuration for 240x135 landscape mode.

### config/autoexec.be

Berry script that:
- Starts HASPmota engine
- Updates header (IP, SSID, time) every second
- Displays sensor temperatures
- Works with or without sensors connected

### config/pages.jsonl

HASPmota page layout in JSONL format (one JSON object per line).

---

## Hardware

**Board**: Waveshare ESP32-S3 Geek  
**Display**: ST7789 240x135 TFT  
**MCU**: ESP32-S3  
**Flash**: 16 MB  
**PSRAM**: 8 MB  

### GPIO Configuration

| GPIO | Function | Description |
|------|----------|-------------|
| 6 | DS18x20 | Temperature sensor |
| 13 | DS18x20 | Temperature sensor |
| 14 | DS18x20 | Temperature sensor |
| 16 | I2C SDA | I2C data line |
| 17 | I2C SCL | I2C clock line |
| 7-12 | Display | ST7789 (auto-configured) |

---

## Troubleshooting

### Display shows wrong orientation

```
DisplayRotate 1
Restart 1
```

### IP/SSID/Time not updating

Ensure `pages.jsonl` has correct JSONL format - each JSON object must be on a separate line.

### Sensors not detected

1. Check GPIO template is applied
2. Verify physical connections
3. For DS18B20: Check pull-up resistor (4.7kΩ)
4. For BME280: Check I2C addresses (0x76, 0x77)

---

## Documentation

- [Firmware Update Guide](docs/FIRMWARE_UPDATE_GUIDE.md)
- [GPIO Pin Mapping](docs/GPIO_PINOUT.md)
- [DS18B20 Configuration](docs/DS18X20_CONFIGURATION.md)
- [Display Configuration](docs/DISPLAY_INI_REFERENCE.md)
- [Template Guide](config/TEMPLATE_GUIDE.md)

---

## License

This project uses Tasmota firmware which is licensed under GPL-3.0.

---

## References

- [Tasmota Documentation](https://tasmota.github.io/docs/)
- [HASPmota Documentation](https://tasmota.github.io/docs/HASPmota/)
- [Waveshare ESP32-S3 Geek](https://www.waveshare.com/wiki/ESP32-S3-Geek)
