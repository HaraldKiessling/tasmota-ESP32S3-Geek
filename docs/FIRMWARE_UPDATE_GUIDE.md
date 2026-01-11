# Firmware Update Guide - ESP32-S3 with LVGL/HASPmota Support

## Problem Statement

The custom `esp32s3geek` firmware build has incomplete HASPmota support:
- **tasmota-75**: HASPmota labels not created (firmware limitation)
- **tasmota-77**: Display initialized but sensors not detected (hardware issue)

## Solution

Use the standard Tasmota32-S3 firmware with full LVGL/HASPmota support.

## Firmware Details

**File**: `firmware/tasmota32s3-lvgl.bin`
- **Size**: 2.7 MB
- **Version**: 15.0.1
- **Build**: tasmota32s3 with LVGL support
- **Features**:
  - ✅ Full HASPmota support
  - ✅ LVGL graphics library
  - ✅ DS18B20 sensor support
  - ✅ BME280 sensor support (I2C)
  - ✅ ST7789 display support
  - ✅ Berry scripting
  - ✅ LVGL Mirror button

## Installation Methods

### Method 1: OTA Update (Recommended if device is accessible)

1. **Set OTA URL**:
   ```
   http://tasmota-XX.samharald.eu/cm?cmnd=OtaUrl%20http://YOUR_SERVER/tasmota32s3-lvgl.bin
   ```

2. **Start Upgrade**:
   ```
   http://tasmota-XX.samharald.eu/cm?cmnd=Upgrade%201
   ```

3. **Wait for reboot** (90-120 seconds)

4. **Verify version**:
   ```
   http://tasmota-XX.samharald.eu/cm?cmnd=Status%202
   ```

### Method 2: Web UI Upload

1. Open device web interface: `http://tasmota-XX.samharald.eu`
2. Navigate to **Firmware Upgrade**
3. Click **Choose File** and select `tasmota32s3-lvgl.bin`
4. Click **Start Upgrade**
5. Wait for reboot (90-120 seconds)

### Method 3: Serial Flash (If device is bricked)

1. Connect device via USB
2. Use esptool.py:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
     write_flash -z 0x0 tasmota32s3-lvgl.bin
   ```

## Post-Installation Configuration

### 1. Upload Configuration Files

**For tasmota-77 (DS18B20 sensors)**:
```bash
# Upload display.ini
curl -F "file=@config/display.ini" http://tasmota-77.samharald.eu/u2

# Upload autoexec.be (hybrid approach)
curl -F "file=@autoconf/autoexec-final.be;filename=autoexec.be" http://tasmota-77.samharald.eu/u2

# Restart
curl "http://tasmota-77.samharald.eu/cm?cmnd=Restart%201"
```

**For tasmota-75 (BME280 sensors)**:
```bash
# Upload display.ini
curl -F "file=@config/display.ini" http://tasmota-75.samharald.eu/u2

# Upload autoexec.be (hybrid approach)
curl -F "file=@autoconf/autoexec-final.be;filename=autoexec.be" http://tasmota-75.samharald.eu/u2

# Restart
curl "http://tasmota-75.samharald.eu/cm?cmnd=Restart%201"
```

### 2. Configure GPIO Template

**For DS18B20 sensors (tasmota-77)**:
```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32, 1, 1, 0, 4864, 1, 1, 1, 1, 1, 1, 1, 1,
    1312,  // GPIO 13: DS18x20
    33, 1, 1,
    608,   // GPIO 17: I2C SCL
    640,   // GPIO 18: I2C SDA
    1, 1, 3840, 6210
  ]
}
```

**For BME280 sensors (tasmota-75)**:
```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32, 1, 1, 0, 4864, 1, 1, 1, 1, 1, 1, 1, 1, 1, 33, 1, 1,
    608,   // GPIO 17: I2C SCL
    640,   // GPIO 18: I2C SDA
    1, 1, 3840, 6210
  ]
}
```

### 3. Verify Installation

**Check firmware version**:
```bash
curl "http://tasmota-XX.samharald.eu/cm?cmnd=Status%202" | jq '.StatusFWR'
```

Expected output:
```json
{
  "Version": "15.0.1(tasmota32s3-lvgl)",
  "BuildDateTime": "2026-01-11T...",
  "Core": "3_1_3"
}
```

**Check display**:
```bash
curl "http://tasmota-XX.samharald.eu/cm?cmnd=DisplayModel"
```

Expected: `{"DisplayModel":17}` (ST7789)

**Check HASPmota**:
```bash
curl "http://tasmota-XX.samharald.eu/cm?cmnd=Berry%20global.haspmota"
```

Expected: Should return haspmota object (not nil)

**Check sensors**:
```bash
curl "http://tasmota-XX.samharald.eu/cm?cmnd=Status%208" | jq '.StatusSNS'
```

Expected: DS18B20 or BME280 sensors listed

## Testing Checklist

### tasmota-77 (DS18B20)
- [ ] Firmware updated to tasmota32s3-lvgl
- [ ] Display initialized (DisplayModel 17)
- [ ] HASPmota available (not nil)
- [ ] DS18B20 sensors detected (2 sensors expected)
- [ ] pages.jsonl generated automatically
- [ ] Display showing sensor data
- [ ] LVGL Mirror button available
- [ ] Sensor updates working (every 2 seconds)

### tasmota-75 (BME280)
- [ ] Firmware updated to tasmota32s3-lvgl
- [ ] Display initialized (DisplayModel 17)
- [ ] HASPmota available (not nil)
- [ ] BME280 sensors detected (2 sensors expected)
- [ ] pages.jsonl generated automatically
- [ ] Display showing sensor data
- [ ] LVGL Mirror button available
- [ ] Sensor updates working (every 2 seconds)

## Troubleshooting

### Device not responding after OTA

**Symptoms**: Device offline after OTA update

**Solutions**:
1. Wait 5 minutes for device to recover
2. Power cycle the device (unplug/replug)
3. Check if device is on different IP (DHCP reassignment)
4. Use serial connection to check boot logs
5. Flash firmware via serial if device is bricked

### HASPmota labels still nil

**Symptoms**: `global.haspmota` is nil or labels not created

**Solutions**:
1. Verify firmware version is tasmota32s3-lvgl (not esp32s3geek)
2. Check display.ini is loaded: `DisplayModel` should be 17
3. Restart device: `Restart 1`
4. Check Berry console for errors: `Berry print(global.haspmota)`

### Sensors not detected

**Symptoms**: No sensors in Status 8

**Solutions**:
1. Verify GPIO configuration in template
2. Check physical connections
3. For DS18B20: Verify pull-up resistor (4.7kΩ)
4. For BME280: Check I2C addresses (0x76, 0x77)
5. Restart device after GPIO changes

### Display not initialized

**Symptoms**: DisplayModel is 0

**Solutions**:
1. Verify display.ini exists in filesystem
2. Check display.ini syntax (no errors)
3. Restart device to reload display.ini
4. Check GPIO configuration for display pins

## Expected Results

After successful firmware update and configuration:

**tasmota-77**:
- ✅ 2x DS18B20 sensors detected and displayed
- ✅ Automatic sensor updates every 2 seconds
- ✅ LVGL Mirror available
- ✅ HASPmota working

**tasmota-75**:
- ✅ 2x BME280 sensors detected and displayed
- ✅ Automatic sensor updates every 2 seconds
- ✅ LVGL Mirror available
- ✅ HASPmota working

## Rollback

If the new firmware causes issues, rollback to previous version:

```bash
# Set OTA URL to previous firmware
curl "http://tasmota-XX.samharald.eu/cm?cmnd=OtaUrl%20http://YOUR_SERVER/tasmota32s3geek-previous.bin"

# Upgrade
curl "http://tasmota-XX.samharald.eu/cm?cmnd=Upgrade%201"
```

## Notes

- The tasmota32s3-lvgl firmware is larger (2.7 MB) than the minimal build
- First boot after firmware update may take longer (up to 2 minutes)
- Configuration (WiFi, MQTT, GPIO) is preserved during OTA update
- Files in filesystem (display.ini, autoexec.be, pages.jsonl) are preserved
- If device becomes unresponsive, wait 5 minutes before attempting recovery

## Support

For issues or questions:
1. Check device logs via serial connection
2. Review Berry console for errors
3. Verify all configuration files are present
4. Test with minimal configuration first
5. Document error messages for troubleshooting
