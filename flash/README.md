# Flash Tools for ESP32-S3 Geek

Tools for flashing Tasmota firmware.

## Quick Start

### Flash Factory Firmware

**Linux/Mac:**
```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 ../firmware/tasmota32s3-lvgl-full.factory.bin
```

**Windows:**
```powershell
python -m esptool --chip esp32s3 --port COM7 --baud 921600 write-flash 0x0 ..\firmware\tasmota32s3-lvgl-full.factory.bin
```

### After Flashing

1. Connect to WiFi AP `tasmota-XXXXXX`
2. Configure WiFi at `http://192.168.4.1`
3. Upload config files via Berry (see below)
4. Apply template and restart

## Upload Configuration Files

After WiFi is configured, use the Berry upload script:

```bash
TASMOTA_URL=http://192.168.0.77 ../scripts/upload-via-berry.sh ../config/display.ini
TASMOTA_URL=http://192.168.0.77 ../scripts/upload-via-berry.sh ../config/autoexec.be
TASMOTA_URL=http://192.168.0.77 ../scripts/upload-via-berry.sh ../config/pages.jsonl
```

Then apply template in Tasmota console:

```
Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; DisplayRotate 1; Restart 1
```

## Files

| File | Description |
|------|-------------|
| `flash-with-config.sh` | Interactive flash script with instructions |

## ESP32-S3 Boot Mode

To enter boot mode for flashing:
1. Hold BOOT button
2. Press and release RESET button
3. Release BOOT button

## Requirements

- Python 3
- esptool (`pip install esptool`)

## Full Automated Workflow

For complete automation including tests, use:

```bash
cd ../scripts
WIFI_SSID="your_ssid" WIFI_PASS="your_password" ./factory-reset-and-test.sh
```

See [scripts/README.md](../scripts/README.md) for details.
