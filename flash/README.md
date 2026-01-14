# Flash Tools for ESP32-S3 Geek

Tools for flashing Tasmota firmware with pre-configured settings.

## Quick Start

### Option 1: Flash and Configure Manually (Simplest)

```bash
# Flash factory firmware
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 ../firmware/tasmota32s3-lvgl-15.2.0.factory.bin

# Then:
# 1. Connect to AP 'tasmota-XXXXXX'
# 2. Configure WiFi at http://192.168.4.1
# 3. Upload files via web interface
# 4. Apply template and restart
```

### Option 2: Use Flash Script

```bash
./flash-with-config.sh
```

This script guides you through the process.

### Option 3: Pre-configured Filesystem (Advanced)

```bash
# Install requirements
pip install littlefs-python

# Set WiFi credentials
export WIFI_SSID="your_ssid"
export WIFI_PASS="your_password"

# Create filesystem image with config files
python create-filesystem.py

# Flash firmware + filesystem together
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash \
  0x0 ../firmware/tasmota32s3-lvgl-15.2.0-full.factory.bin \
  0x310000 filesystem.bin
```

**Windows PowerShell:**
```powershell
$env:WIFI_SSID="your_ssid"
$env:WIFI_PASS="your_password"
python create-filesystem.py
python -m esptool --chip esp32s3 --port COM7 --baud 921600 write-flash 0x0 ..\firmware\tasmota32s3-lvgl-15.2.0-full.factory.bin 0x310000 filesystem.bin
```

## Files

| File | Description |
|------|-------------|
| `flash-with-config.sh` | Interactive flash script |
| `create-filesystem.py` | Creates LittleFS image with config |
| `init.bat` | WiFi configuration (executed at first boot) |

## Post-Flash Configuration

After flashing and WiFi configuration:

1. **Upload files** (via web interface or curl):
   - `display.ini`
   - `autoexec.be`
   - `pages.jsonl`

2. **Apply template**:
   ```
   Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
   Module 0
   ```

3. **Configure display**:
   ```
   DisplayRotate 1
   Restart 1
   ```

## Troubleshooting

### Device crashes after boot

The device needs `display.ini` and `autoexec.be` to initialize Berry/LVGL properly. Upload these files BEFORE applying the template.

### Upload fails with "Not enough space"

This can happen after crashes. Try:
1. Restart device
2. Upload via web interface manually
3. If persistent, reflash firmware

### esptool.py not found

```bash
pip install esptool
```

## ESP32-S3 Boot Mode

To enter boot mode for flashing:
1. Hold BOOT button
2. Press and release RESET button
3. Release BOOT button
4. Device is now in boot mode

## Partition Layout

| Partition | Offset | Size |
|-----------|--------|------|
| Bootloader | 0x0 | - |
| Firmware | 0x10000 | ~3MB |
| Filesystem | 0x310000 | ~12MB |

## Security Note

The `init.bat` file contains WiFi credentials in plain text. Do not commit this file to public repositories. Use `.gitignore` to exclude it.
