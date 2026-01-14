# Tasmota ESP32-S3 Geek Scripts

Automation scripts for managing Tasmota devices on ESP32-S3 Geek hardware.

## Quick Start

### Full Regression Test (Network only)

```bash
TASMOTA_URL=http://192.168.0.77 ./full-regression.sh
```

This resets the device, uploads config files, and runs all tests.

### Factory Reset with Firmware Flash (USB required)

```bash
WIFI_SSID="your_ssid" WIFI_PASS="your_password" SERIAL_PORT=/dev/ttyUSB0 ./factory-reset-and-test.sh
```

This flashes firmware, configures WiFi, uploads files, and runs tests.

---

## Scripts

### full-regression.sh

Complete regression test cycle via network:
1. Reset device (keep WiFi)
2. Upload configuration files via Berry
3. Apply template and settings
4. Run regression tests

**Usage:**
```bash
TASMOTA_URL=http://192.168.0.77 ./full-regression.sh
```

---

### factory-reset-and-test.sh

Complete factory reset including firmware flash:
1. Flash firmware via USB
2. Configure WiFi (manual step)
3. Upload configuration files
4. Apply template
5. Run regression tests

**Usage:**
```bash
WIFI_SSID="your_ssid" WIFI_PASS="your_password" ./factory-reset-and-test.sh
```

**Windows PowerShell:**
```powershell
$env:WIFI_SSID="your_ssid"
$env:WIFI_PASS="your_password"
$env:SERIAL_PORT="COM7"
bash ./factory-reset-and-test.sh
```

---

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

The scripts use configuration files from `../config/`:

Required files:
- `display.ini` - ST7789 display configuration
- `autoexec.be` - Berry script for sensor dashboard
- `pages.jsonl` - HASPmota UI layout

---

## GPIO Configuration

The scripts apply a base template and then configure sensors via GPIO commands:

### Base Template

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,1,1,0,0,0,0],
  "FLAG": 0,
  "BASE": 1
}
```

The base template sets display GPIOs (22-27) and uses `1` (User) for sensor GPIOs.

### Peripheral Configuration

After applying the template, peripherals are configured via:

```
# DS18x20 temperature sensors
Backlog gpio6 1312; gpio13 1313; gpio14 1314

# BME280 I2C sensors
Backlog gpio16 640; gpio17 608

# UART serial
Backlog gpio43 3200; gpio44 3232

# All peripherals
Backlog gpio6 1312; gpio13 1313; gpio14 1314; gpio16 640; gpio17 608; gpio43 3200; gpio44 3232
```

Key GPIO assignments:
- GPIO 6: DS18x20-1 (code 1312)
- GPIO 13: DS18x20-2 (code 1313)
- GPIO 14: DS18x20-3 (code 1314)
- GPIO 16: I2C SDA (code 640)
- GPIO 17: I2C SCL (code 608)
- GPIO 22-27: SPI Display (codes 8896, 8960, 8800, 8832, 8864, 8928)
- GPIO 43: Serial Tx (code 3200)
- GPIO 44: Serial Rx (code 3232)

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
