# Firmware Update Guide - ESP32-S3-Geek with LVGL/HASPmota Support

## Overview

This guide covers firmware installation and configuration for the Waveshare ESP32-S3-Geek board with ST7789 display.

## Firmware Details

**Recommended**: `tasmota32s3-lvgl` (v15.2.0 or later)

**Features**:
- Full HASPmota support
- LVGL graphics library
- DS18B20/DS18S20 sensor support
- BME280 sensor support (I2C)
- ST7789 display support
- Berry scripting
- LVGL Mirror button

## Installation Methods

### Method 1: OTA Update

1. **Set OTA URL** in Tasmota Console:
   ```
   OtaUrl https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/tasmota32s3-lvgl-15.2.0.bin
   ```

2. **Start Upgrade**:
   ```
   Upgrade 1
   ```

3. **Wait for reboot** (90-120 seconds)

### Method 2: Web UI Upload

1. Open device web interface
2. Navigate to **Firmware Upgrade**
3. Upload `tasmota32s3-lvgl.bin`
4. Wait for reboot

### Method 3: Serial Flash

```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota32s3-lvgl.factory.bin
```

## Post-Installation Configuration

### 1. Apply GPIO Template

```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
```

### 2. Set Display Rotation

```
DisplayRotate 1
```

### 3. Upload Configuration Files

Upload these files to the device filesystem:
- `config/display.ini` → `/display.ini`
- `config/autoexec.be` → `/autoexec.be`
- `config/pages.jsonl` → `/pages.jsonl`

### 4. Restart

```
Restart 1
```

## Configuration Files

### display.ini

ST7789 display configuration for 240x135 landscape mode.

### autoexec.be

Berry script that:
- Starts HASPmota engine
- Updates IP, SSID, and time in header
- Displays DS18B20/DS18S20 sensor temperatures
- Displays BME280 sensor temperatures
- Works with or without sensors connected

### pages.jsonl

HASPmota page layout with:
- Red header bar with IP, SSID, time, WiFi indicator
- BME280 sensor labels (yellow)
- DS18x20 sensor labels (white, up to 10 sensors)

## Troubleshooting

### Display shows wrong orientation

```
DisplayRotate 1
Restart 1
```

### IP/SSID/Time not updating

Ensure `pages.jsonl` has correct JSONL format (one JSON object per line).

### Sensors not detected

1. Check GPIO template is applied
2. Verify physical connections
3. For DS18B20: Check pull-up resistor (4.7kΩ)
4. For BME280: Check I2C addresses (0x76, 0x77)

### HASPmota objects are nil

1. Verify `pages.jsonl` exists and has correct format
2. Check Berry console for errors after restart
3. Ensure `autoexec.be` calls `haspmota.start()`

## Hardware

- **Board**: Waveshare ESP32-S3-Geek
- **MCU**: ESP32-S3
- **Display**: ST7789 240x135
- **Flash**: 16 MB
- **PSRAM**: 8 MB
