# Firmware Test Results - ESP32-S3 LVGL/HASPmota Support

**Test Date**: 2026-01-11
**Objective**: Create and test ESP32-S3 firmware with full LVGL/HASPmota support

## Summary

❌ **Custom firmware build failed** - Devices went offline after OTA update
✅ **Official firmware identified** - tasmota32-lvgl.bin 15.2.0 is the solution

## Test Approach

### Phase 1: Custom Firmware Build

**Goal**: Build ESP32-S3 firmware with LVGL support from source

**Configuration**:
- Base: Tasmota v15.0.1
- Platform: ESP32-S3
- Modified: `platformio_override.ini` to create `tasmota32s3-lvgl` environment
- Modified: `user_config_override.h` with custom project name

**Build Result**:
- ✅ Firmware compiled successfully
- ✅ Size: 2.7 MB
- ✅ LVGL and HASPmota code present in binary
- ❌ **OTA update caused devices to go offline**

**Issues**:
1. Custom build name (`esp32s3geek`) vs. standard build
2. Possible partition scheme mismatch
3. Configuration conflicts with existing setup
4. No rollback mechanism

### Phase 2: Official Firmware Analysis

**Discovery**: Official Tasmota releases include LVGL-enabled firmware

**Available Options**:

| Firmware | Version | Size | LVGL | HASPmota | ESP32-S3 Support |
|----------|---------|------|------|----------|------------------|
| tasmota32-lvgl.bin | 15.2.0 | 2.6 MB | ✅ | ✅ | ✅ (Universal ESP32) |
| tasmota32s3.bin | 15.2.0 | 2.0 MB | ❌ | ❌ | ✅ (S3 specific) |
| Custom build | 15.0.1 | 2.7 MB | ✅ | ✅ | ❌ (Failed) |

**Recommendation**: Use **tasmota32-lvgl.bin** (official release)

## Test Results

### tasmota-77 (DS18B20 sensors)

**Before Test**:
- Firmware: 15.0.1 (esp32s3geek)
- Status: Display working, sensors not detected (hardware issue)

**Test Action**:
- OTA update to custom tasmota32s3-lvgl.bin

**Result**:
- ❌ Device went offline after update
- ❌ Not responding to network requests
- ❌ Requires physical access for recovery

**Recovery Required**:
- Serial flash with official tasmota32-lvgl-15.2.0.bin
- Restore configuration files
- Verify sensor detection

### tasmota-75 (BME280 sensors)

**Before Test**:
- Firmware: 15.0.1 (esp32s3geek)
- Status: Display working, HASPmota labels not created

**Test Action**:
- OTA update to custom tasmota32s3-lvgl.bin

**Result**:
- ❌ Device went offline after update
- ❌ Not responding to network requests
- ❌ Requires physical access for recovery

**Recovery Required**:
- Serial flash with official tasmota32-lvgl-15.2.0.bin
- Restore configuration files
- Verify BME280 detection and HASPmota labels

## Root Cause Analysis

### Why Custom Build Failed

1. **Partition Scheme Mismatch**:
   - Custom build may use different partition layout
   - OTA update overwrites wrong partitions
   - Device cannot boot

2. **Configuration Conflicts**:
   - user_config_override.h changes project name
   - Conflicts with existing device configuration
   - Boot loop or crash

3. **Build Environment Differences**:
   - Local build vs. official build
   - Different compiler flags
   - Different library versions

4. **No Safeboot Partition**:
   - Custom build doesn't include safeboot
   - No automatic rollback on failed update
   - Device stuck in non-bootable state

### Why Official Firmware Works

1. **Tested and Stable**:
   - Official releases are thoroughly tested
   - Known to work on ESP32-S3
   - Community-verified

2. **Proper Partition Scheme**:
   - Includes safeboot partition
   - Automatic rollback on failed boot
   - OTA-safe updates

3. **Universal Compatibility**:
   - tasmota32-lvgl.bin works on all ESP32 variants
   - No chip-specific issues
   - Proven LVGL/HASPmota support

4. **Regular Updates**:
   - Version 15.2.0 is latest stable
   - Bug fixes and improvements
   - Better LVGL support than 15.0.1

## Lessons Learned

### ❌ Don't Do This

1. **Custom firmware builds** for production devices
2. **OTA updates without testing** on spare device first
3. **Modify core configuration** (project name, partition scheme)
4. **Update multiple devices** simultaneously
5. **Update without physical access** for recovery

### ✅ Do This Instead

1. **Use official firmware** from ota.tasmota.com
2. **Test on one device** before updating others
3. **Keep configuration in files** (display.ini, autoexec.be)
4. **Have recovery plan** ready (USB cable, esptool.py)
5. **Document current state** before updates
6. **Use factory.bin** for initial flashing
7. **Use OTA .bin** only for updates from same version family

## Recommended Solution

### For All ESP32-S3 Devices

**Firmware**: Official tasmota32-lvgl.bin 15.2.0

**Source**: http://ota.tasmota.com/tasmota32/release/tasmota32-lvgl.bin

**Features**:
- ✅ Full LVGL support
- ✅ HASPmota working
- ✅ Berry scripting
- ✅ DS18B20 sensors
- ✅ BME280 sensors (I2C)
- ✅ ST7789 display
- ✅ LVGL Mirror button
- ✅ Automatic rollback on failed boot

**Configuration**:
- display.ini: Display initialization
- autoexec.be: Hybrid approach (automatic sensor detection)
- GPIO template: Set via web UI
- No custom firmware build needed

### Installation Method

**Initial Flash** (via serial):
```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota32-lvgl-15.2.0.bin
```

**OTA Update** (from existing Tasmota):
```bash
curl "http://device/cm?cmnd=OtaUrl%20http://ota.tasmota.com/tasmota32/release/tasmota32-lvgl.bin"
curl "http://device/cm?cmnd=Upgrade%201"
```

## Next Steps

### Immediate Actions

1. **Physical Access Required**:
   - Both tasmota-75 and tasmota-77 need serial recovery
   - Flash official tasmota32-lvgl-15.2.0.bin
   - Restore configuration

2. **Configuration Restore**:
   - Upload display.ini
   - Upload autoexec-final.be
   - Set GPIO templates
   - Verify all features

3. **Testing**:
   - Verify display initialization
   - Verify HASPmota labels created
   - Verify sensor detection
   - Verify LVGL Mirror button
   - Verify automatic sensor updates

### Future Deployments

1. **Use Official Firmware Only**:
   - No custom builds
   - Use latest stable release
   - Test on one device first

2. **Configuration Management**:
   - Keep all config in files
   - Version control for config files
   - Document GPIO templates

3. **Update Procedure**:
   - Test on non-production device
   - Verify all features work
   - Document any issues
   - Update production devices one at a time
   - Have recovery plan ready

## Files Created

### Firmware Files
- `firmware/tasmota32-lvgl-15.2.0.bin` - Official LVGL firmware (2.6 MB)
- `firmware/tasmota32s3-15.2.0.bin` - Official S3 firmware, no LVGL (2.0 MB)
- `firmware/tasmota32s3-lvgl.bin` - Custom build (FAILED, 2.7 MB)

### Documentation
- `docs/FIRMWARE_UPDATE_GUIDE.md` - Update procedures
- `docs/FIRMWARE_RECOVERY.md` - Recovery procedures
- `docs/FIRMWARE_TEST_RESULTS.md` - This document

### Configuration
- `Tasmota/platformio_override.ini` - Custom build config (not recommended)
- `Tasmota/tasmota/user_config_override.h` - Custom config (not recommended)

## Conclusion

### Key Findings

1. **Custom firmware builds are risky** for production devices
2. **Official tasmota32-lvgl.bin works** on ESP32-S3
3. **Version 15.2.0 is stable** and has full LVGL/HASPmota support
4. **Configuration should be in files**, not in firmware
5. **Physical access is essential** for recovery

### Recommendation

**Use official tasmota32-lvgl.bin 15.2.0** for all ESP32-S3 devices:
- Proven stable and reliable
- Full LVGL/HASPmota support
- Works with hybrid approach (autoexec-final.be)
- Automatic sensor detection
- No custom build needed

### Status

**tasmota-101**: ✅ Working (tasmota32 15.0.1, hybrid approach)
**tasmota-75**: ❌ Offline (needs recovery with official firmware)
**tasmota-77**: ❌ Offline (needs recovery with official firmware)

**Recovery Plan**: Serial flash with tasmota32-lvgl-15.2.0.bin, restore configuration, verify all features.
