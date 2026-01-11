# Firmware Recovery - tasmota-75 and tasmota-77

## Situation

Both devices (tasmota-75 and tasmota-77) are offline after attempted OTA update with custom-built firmware.

**Attempted Update**:
- Source: Custom tasmota32s3-lvgl.bin (built from v15.0.1 with custom config)
- Result: Devices not responding after update

**Likely Cause**:
- Firmware incompatibility (custom build vs. standard build)
- Partition scheme mismatch
- Boot loop due to configuration conflict

## Available Firmware Options

### Option 1: Official tasmota32-lvgl.bin (RECOMMENDED)
- **File**: `firmware/tasmota32-lvgl-15.2.0.bin`
- **Version**: 15.2.0 Stephan
- **Size**: 2.6 MB
- **Source**: http://ota.tasmota.com/tasmota32/release/tasmota32-lvgl.bin
- **Features**: Full LVGL + HASPmota support
- **Compatibility**: ESP32, ESP32-S2, ESP32-S3, ESP32-C3
- **Status**: ✅ Official release, tested and stable

### Option 2: Official tasmota32s3.bin
- **File**: `firmware/tasmota32s3-15.2.0.bin`
- **Version**: 15.2.0 Stephan
- **Size**: 2.0 MB
- **Source**: http://ota.tasmota.com/tasmota32/release/tasmota32s3.bin
- **Features**: Standard ESP32-S3 build (NO LVGL)
- **Status**: ❌ No LVGL/HASPmota support

### Option 3: Custom Build (NOT RECOMMENDED)
- **File**: `firmware/tasmota32s3-lvgl.bin`
- **Version**: 15.0.1 (custom)
- **Size**: 2.7 MB
- **Status**: ❌ Caused devices to go offline

## Recovery Methods

### Method 1: Physical Access Required (Serial Flash)

**Requirements**:
- USB cable
- Physical access to devices
- esptool.py installed

**Steps**:

1. **Connect device via USB**

2. **Erase flash** (optional, if device is completely bricked):
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash
   ```

3. **Flash official firmware**:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
     write_flash -z 0x0 firmware/tasmota32-lvgl-15.2.0.bin
   ```

4. **Wait for boot** (30-60 seconds)

5. **Connect to WiFi**:
   - Device creates AP: `tasmota-XXXXXX`
   - Connect and configure WiFi

6. **Restore configuration**:
   - Upload display.ini
   - Upload autoexec.be
   - Set GPIO template
   - Restart

### Method 2: Remote Recovery (If devices are accessible)

**If devices are in boot loop but still accessible**:

1. **Try safe mode**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=SetOption36%201"
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Restart%201"
   ```

2. **Reset to defaults**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Reset%201"
   ```

3. **Flash official firmware via OTA**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=OtaUrl%20http://ota.tasmota.com/tasmota32/release/tasmota32-lvgl.bin"
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Upgrade%201"
   ```

### Method 3: Wait for Auto-Recovery

Some Tasmota versions have auto-recovery after failed OTA:
- Wait 10-15 minutes
- Device may automatically rollback to previous firmware
- Check if devices come back online

## Post-Recovery Configuration

### For tasmota-75 (BME280 sensors)

1. **Upload display.ini**:
   ```bash
   curl -F "file=@config/display.ini" http://tasmota-75.samharald.eu/u2
   ```

2. **Upload autoexec.be**:
   ```bash
   curl -F "file=@autoconf/autoexec-final.be;filename=autoexec.be" http://tasmota-75.samharald.eu/u2
   ```

3. **Set GPIO template** (I2C for BME280):
   ```json
   {
     "NAME": "ESP32S3-Geek",
     "GPIO": [32, 1, 1, 0, 4864, 1, 1, 1, 1, 1, 1, 1, 1, 1, 33, 1, 1, 608, 640, 1, 1, 3840, 6210]
   }
   ```
   - GPIO 17: I2C SCL (608)
   - GPIO 18: I2C SDA (640)

4. **Restart**:
   ```bash
   curl "http://tasmota-75.samharald.eu/cm?cmnd=Restart%201"
   ```

### For tasmota-77 (DS18B20 sensors)

1. **Upload display.ini**:
   ```bash
   curl -F "file=@config/display.ini" http://tasmota-77.samharald.eu/u2
   ```

2. **Upload autoexec.be**:
   ```bash
   curl -F "file=@autoconf/autoexec-final.be;filename=autoexec.be" http://tasmota-77.samharald.eu/u2
   ```

3. **Set GPIO template** (DS18B20 + I2C):
   ```json
   {
     "NAME": "ESP32S3-Geek",
     "GPIO": [32, 1, 1, 0, 4864, 1, 1, 1, 1, 1, 1, 1, 1, 1312, 33, 1, 1, 608, 640, 1, 1, 3840, 6210]
   }
   ```
   - GPIO 13: DS18x20 (1312)
   - GPIO 17: I2C SCL (608)
   - GPIO 18: I2C SDA (640)

4. **Restart**:
   ```bash
   curl "http://tasmota-77.samharald.eu/cm?cmnd=Restart%201"
   ```

## Verification

After recovery and configuration:

1. **Check firmware version**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Status%202" | jq '.StatusFWR'
   ```
   Expected: Version 15.2.0

2. **Check display**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=DisplayModel"
   ```
   Expected: `{"DisplayModel":17}`

3. **Check HASPmota**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Berry%20global.haspmota"
   ```
   Expected: haspmota object (not nil)

4. **Check sensors**:
   ```bash
   curl "http://tasmota-XX.samharald.eu/cm?cmnd=Status%208" | jq '.StatusSNS'
   ```
   Expected: BME280 or DS18B20 sensors listed

## Lessons Learned

### ❌ What Went Wrong

1. **Custom firmware build** with modified user_config_override.h
2. **Partition scheme mismatch** between custom and standard builds
3. **OTA update without testing** on non-production device first
4. **No backup plan** for recovery

### ✅ Best Practices

1. **Use official firmware** from ota.tasmota.com
2. **Test on one device first** before updating all devices
3. **Keep backup firmware** accessible
4. **Document current configuration** before updates
5. **Have physical access** for serial recovery
6. **Use factory.bin** for initial flashing
7. **Use OTA .bin** only for updates

## Recommended Approach Going Forward

### For Production Deployment

1. **Use official tasmota32-lvgl.bin** (15.2.0 or later)
   - Proven stable
   - Full LVGL/HASPmota support
   - Works on ESP32-S3

2. **Configuration via files** (not custom firmware):
   - display.ini for display setup
   - autoexec.be for automation
   - pages.jsonl for UI (generated automatically)
   - GPIO template via web UI

3. **Test procedure**:
   - Flash one device
   - Verify all features work
   - Document any issues
   - Only then update other devices

4. **Recovery plan**:
   - Keep USB cable accessible
   - Have esptool.py ready
   - Keep backup firmware files
   - Document recovery steps

## Current Status

**tasmota-75**: ❌ Offline after failed OTA update
**tasmota-77**: ❌ Offline after failed OTA update

**Next Steps**:
1. Physical access required for serial recovery
2. Flash official tasmota32-lvgl-15.2.0.bin
3. Restore configuration
4. Test all features
5. Document results

## Support Files

- **Official Firmware**: `firmware/tasmota32-lvgl-15.2.0.bin`
- **Display Config**: `config/display.ini`
- **Automation**: `autoconf/autoexec-final.be`
- **Recovery Guide**: This document

## Contact

For recovery assistance, physical access to devices is required to perform serial flashing.
