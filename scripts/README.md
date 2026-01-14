# Tasmota ESP32-S3 Geek Scripts

Automation scripts for managing Tasmota devices on ESP32-S3 Geek hardware.

## Scripts

### regression-test.sh

Runs comprehensive tests to verify device functionality.

**Tests performed:**
- Network connectivity (IP, SSID)
- System clock synchronization
- ST7789 Display initialization
- LVGL graphics engine
- Berry scripting runtime
- Berry Console availability
- Extension Manager
- DS18B20 temperature sensors
- BME280 I2C sensors (if connected)
- Configuration files (display.ini, autoexec.be, pages.jsonl)
- GPIO template configuration

**Usage:**
```bash
TASMOTA_URL=https://your-device-url/ ./regression-test.sh
```

**Exit codes:**
- 0: All tests passed
- 1: Some tests failed (device mostly functional)
- 2: Multiple failures (device needs attention)

---

### auto-install.sh

Automatically configures a fresh or reset Tasmota device.

**What it does:**
1. Uploads configuration files (display.ini, autoexec.be, pages.jsonl)
2. Applies GPIO template for ESP32-S3 Geek
3. Configures device settings (name, timezone, telemetry)
4. Sets DisplayRotate for correct orientation
5. Restarts device and verifies installation

**Prerequisites:**
- Device must have WiFi already configured
- Device must be accessible via network

**Usage:**
```bash
TASMOTA_URL=https://your-device-url/ ./auto-install.sh
```

**Important:** Run this script BEFORE resetting the device, or immediately after WiFi is configured on a fresh device.

---

### upload-via-berry.sh

Uploads files to Tasmota via Berry scripting. Use this when normal HTTP upload fails.

**Usage:**
```bash
TASMOTA_URL=http://192.168.0.77 ./upload-via-berry.sh ../config/autoexec.be
TASMOTA_URL=http://192.168.0.77 ./upload-via-berry.sh ../config/pages.jsonl
```

**How it works:**
- Creates the file on the device
- Writes content line by line via Berry commands
- Works around HTTP upload issues

---

### reset-device.sh

Resets device configuration while preserving WiFi settings.

**What it does:**
1. Deletes configuration files (display.ini, autoexec.be, pages.jsonl)
2. Executes Reset 4 (erase settings, keep WiFi)
3. Waits for device to restart

**Usage:**
```bash
TASMOTA_URL=https://your-device-url/ ./reset-device.sh
```

**Warning:** After reset, the device may crash (Exception) until configuration files are re-uploaded. Run `auto-install.sh` immediately after reset.

---

## Workflow

### Full Reset and Reinstall

```bash
export TASMOTA_URL=https://your-device-url/

# 1. Reset device
./reset-device.sh

# 2. Wait for device to stabilize (may show exceptions)
sleep 30

# 3. Reinstall configuration
./auto-install.sh

# 4. Verify installation
./regression-test.sh
```

### Quick Verification

```bash
TASMOTA_URL=https://your-device-url/ ./regression-test.sh
```

---

## Configuration Files

The scripts use configuration files from:
1. `../config/` (primary)
2. `../firmware/release/v7/` (fallback)

Required files:
- `display.ini` - ST7789 display configuration
- `autoexec.be` - Berry script for sensor dashboard
- `pages.jsonl` - HASPmota UI layout

---

## GPIO Template

The scripts apply this GPIO template:

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],
  "FLAG": 0,
  "BASE": 1
}
```

Key GPIO assignments:
- GPIO 6, 13, 14: DS18x20 temperature sensors (code 1312)
- GPIO 16: I2C SDA (code 640)
- GPIO 17: I2C SCL (code 608)

---

## Troubleshooting

### Device crashes after reset

The device may crash with "StoreProhibited" exception if Berry/LVGL tries to start without the required configuration files. Solution:
1. Wait for device to stabilize
2. Upload files manually via web interface if scripts fail
3. Restart device

### File upload fails with "Not enough space"

This can occur after exceptions corrupt the filesystem state. Solutions:
1. Restart device and try again
2. Use web interface to upload files manually
3. As last resort, reflash firmware

### Berry not running

Check that:
1. `autoexec.be` is uploaded
2. `display.ini` is uploaded
3. DisplayRotate is set to 1
4. Device has been restarted after configuration

---

## Requirements

- bash
- curl
- grep with Perl regex support (-P flag)

---

## License

MIT License - See repository root for details.
