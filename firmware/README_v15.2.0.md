# Tasmota32 S3 LVGL v15.2.0-full Firmware

Custom build for ESP32-S3 Geek with all features enabled.

## Quick Start

### Download

- **OTA**: `tasmota32s3-lvgl-full.bin` (2.6 MB)
- **Factory**: `tasmota32s3-lvgl-full.factory.bin` (3.5 MB)

### Flash

```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota32s3-lvgl-full.factory.bin
```

**Windows:**
```powershell
python -m esptool --chip esp32s3 --port COM7 --baud 921600 write-flash 0x0 tasmota32s3-lvgl-full.factory.bin
```

### Configure

1. WiFi: Connect to AP `tasmota-XXXXXX`, configure at `http://192.168.4.1`
2. Upload files: `display.ini`, `autoexec.be`, `pages.jsonl`
3. Apply template (in console):
   ```
   Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
   Module 0
   DisplayRotate 1
   Restart 1
   ```

## Features

- ✅ Berry Scripting
- ✅ LVGL Graphics
- ✅ HASPmota
- ✅ Extension Manager
- ✅ DS18x20 Temperature Sensors
- ✅ BME280/BME680 I2C Sensors
- ✅ Rules Engine
- ✅ File System (12MB)

## Automated Installation

Use the scripts in `scripts/` directory:

```bash
# Set WiFi credentials
export WIFI_SSID="your_ssid"
export WIFI_PASS="your_password"
export TASMOTA_URL="http://192.168.0.77"

# After flashing and WiFi config, upload files via Berry
./scripts/upload-via-berry.sh ../config/display.ini
./scripts/upload-via-berry.sh ../config/autoexec.be
./scripts/upload-via-berry.sh ../config/pages.jsonl

# Run regression tests
./scripts/regression-test.sh
```

## Documentation

- [Flash Tools](../flash/README.md)
- [Scripts](../scripts/README.md)
- [GPIO Pinout](../docs/GPIO_PINOUT.md)

## Support

- Issues: [GitHub](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues)
- Docs: [Tasmota](https://tasmota.github.io/docs/)

---

**Version**: 15.2.0-full  
**Date**: 2026-01-14  
**Status**: Tested
