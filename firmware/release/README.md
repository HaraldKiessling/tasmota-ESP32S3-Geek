# Tasmota ESP32S3-Geek Firmware Releases

## Current Version

See [firmware/README_v15.2.0.md](../README_v15.2.0.md) for the latest firmware.

## Download

| File | Description | Size |
|------|-------------|------|
| [tasmota32s3-lvgl-full.bin](../tasmota32s3-lvgl-full.bin) | OTA Update | ~2.6 MB |
| [tasmota32s3-lvgl-full.factory.bin](../tasmota32s3-lvgl-full.factory.bin) | Factory Flash | ~3.5 MB |

## Quick Install

```bash
# Factory flash (new device)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota32s3-lvgl-full.factory.bin

# OTA update (existing device)
# Use Tasmota web interface: Firmware Upgrade → OTA URL
```

## Configuration

After flashing, apply the GPIO template:

```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
DisplayRotate 1
Restart 1
```

## Features

- Berry Scripting + LVGL Graphics
- HASPmota UI
- DS18x20 Temperature Sensors (3 buses)
- BME280/BME680 I2C Sensors
- ST7789 Display (240x135)
- OTA Updates from GitHub

## Documentation

- [Installation Guide](../../docs/INSTALLATION.md)
- [GPIO Pinout](../../docs/GPIO_PINOUT.md)
- [Scripts](../../scripts/README.md)
