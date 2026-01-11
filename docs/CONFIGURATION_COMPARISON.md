# Configuration Comparison: tasmota-101 vs tasmota-75 vs tasmota-77

**Last Updated**: 2026-01-11 (after hybrid deployment)

## Quick Reference

**Production Device**: tasmota-101 (tasmota32 firmware + hybrid approach)

**Key Learnings**:
1. ✅ **tasmota32 firmware** has full HASPmota support (use for production)
2. ⚠️ **esp32s3geek firmware** has incomplete HASPmota support (labels not created)
3. ✅ **Hybrid approach** (autoexec-final.be) provides automatic sensor detection
4. ✅ **text_rule** in pages.jsonl enables automatic display updates
5. ❌ Manual Berry updates (263 lines) don't work without HASPmota labels

**Recommendations**:
- Use **tasmota32** firmware for all devices
- Use **hybrid approach** (autoexec-final.be) for automatic configuration
- Avoid manual Berry updates - use text_rule instead

## Executive Summary

| Device | Firmware | Display | HASPmota | Sensors | Status |
|--------|----------|---------|----------|---------|--------|
| **tasmota-101** | tasmota32 | ✅ ST7789 | ✅ Working | ✅ 5x DS18B20 | ✅ **PRODUCTION** |
| **tasmota-75** | esp32s3geek | ✅ ST7789 | ❌ Labels not created | ✅ 2x BME280 | ⚠️ Firmware issue |
| **tasmota-77** | esp32s3geek | ✅ ST7789 | ✅ Available | ❌ No sensors | ❌ Hardware issue |

## Firmware Versions

| Device | Version | Build Date | Core | Build Type |
|--------|---------|------------|------|------------|
| tasmota-101 | 15.0.1 (tasmota32) | 2026-01-10T19:02:35 | 3_1_3 | Standard ESP32 |
| tasmota-75 | 15.0.1 (esp32s3geek) | 2026-01-11T08:08:31 | ? | Custom ESP32-S3 |
| tasmota-77 | 15.0.1 (esp32s3geek) | 2026-01-11T10:52:47 | ? | Custom ESP32-S3 |

**Key Difference**: tasmota-101 uses **tasmota32** (standard ESP32 build) with full HASPmota support. Others use **esp32s3geek** (custom build) with limited/incomplete HASPmota support.

## GPIO Configuration

### tasmota-101 (WORKING)
```json
{
  "NAME": "ESP32-S3-Geek",
  "GPIO": [
    32,    // GPIO 0: Button
    1,     // GPIO 1: User
    1,     // GPIO 2: User
    0,     // GPIO 3: None
    4864,  // GPIO 4: ADC Range
    1,     // GPIO 5: User
    1,     // GPIO 6: User
    ...
    1312,  // GPIO 13: DS18x20 ← DS18B20 SENSOR!
    33,    // GPIO 14: Button_n
    ...
    608,   // GPIO 17: I2C SCL
    640,   // GPIO 18: I2C SDA
    ...
    3840,  // GPIO 21: Output Hi
    6210,  // GPIO 22: Option A
  ]
}
```

**Key GPIOs**:
- **GPIO 13**: DS18x20 (1312) - DS18B20 sensors
- GPIO 17: I2C SCL (608)
- GPIO 18: I2C SDA (640)

### tasmota-75 (BME280 only)
```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0: Button
    ...
    640,   // GPIO 16: I2C SDA (position 16, not GPIO 16!)
    608,   // GPIO 17: I2C SCL
    ...
    8896,  // GPIO 22: SDIO D1
    8960,  // GPIO 23: SDIO D2
    8800,  // GPIO 24: SDIO CLK
    8832,  // GPIO 25: SDIO CMD
    8864,  // GPIO 26: SDIO D0
    8928,  // GPIO 27: SDIO D3
    ...
    6210,  // GPIO 29: Option A
    ...
    3200,  // GPIO 32: Serial Tx
    3232,  // GPIO 33: Serial Rx
  ]
}
```

**Key GPIOs**:
- GPIO 16/17: I2C (for BME280)
- GPIO 22-27: SDIO (for SD card?)
- **NO DS18B20 GPIOs**

### tasmota-77 (NEEDS DS18B20)
Currently has no working GPIO configuration.

## Display Configuration

### display.ini (IDENTICAL on all devices)
```
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40 
:S,2,1,3,0,80,30
:I
01,A0
11,A0
3A,81,55
36,81,00
21,80
13,80
29,A0
:o,28
:O,29
:A,2A,2B,2C
:R,36
:0,C0,35,28,00
:1,A0,28,34,01
:2,00,34,28,02
:3,60,28,35,03
:i,21,20
:TI2,38,32,23
:r,1
:B,30,5
#
```

**Display GPIOs** (from :H line):
- GPIO 3: CS
- GPIO 10: DC
- GPIO 12: MOSI
- GPIO 11: CLK
- GPIO 8: RST
- GPIO 7: ?
- GPIO 9: ?
- GPIO 30: Backlight (from :B line)

## pages.jsonl

### tasmota-101 (SIMPLE, WORKING)
```jsonl
{"page":0,"comment":"---------- Upper stat line ----------"}
{"id":11,"obj":"label","x":0,"y":0,"w":320,"text":"Temperatur","text_font":"montserrat-20"}
{"id":15,"obj":"lv_wifi_arcs","x":211,"y":0,"w":29,"h":22}
{"id":16,"obj":"lv_clock","x":132,"y":3,"w":55,"h":16}

{"page":1,"comment":"---------- Page 1 ----------"}
{"id":11,"obj":"label","x":2,"y":25,"text":"DS18B20-1=","text_rule":"DS18B20-1#Temperature","text_rule_format":"1:%4.2f"}
{"id":12,"obj":"label","x":2,"y":45,"text":"DS18B20-2=","text_rule":"DS18B20-2#Temperature","text_rule_format":"2:%4.2f"}
{"id":13,"obj":"label","x":2,"y":65,"text":"DS18B20-3=","text_rule":"DS18B20-3#Temperature","text_rule_format":"3:%4.2f"}
{"id":14,"obj":"label","x":2,"y":85,"text":"DS18B20-4=","text_rule":"DS18B20-4#Temperature","text_rule_format":"4:%4.2f"}
{"id":15,"obj":"label","x":2,"y":105,"text":"DS18B20-5=","text_rule":"DS18B20-5#Temperature","text_rule_format":"5:%4.2f"}

{"berry_run":"tasmota.add_cron('*/2 * * * * *', def () var s = tasmota.read_sensors() if (s) tasmota.publish_rule(s) end end, 'hm_every_5_s')"}
```

**Features**:
- Uses **text_rule** for automatic sensor updates
- Berry cron job updates sensors every 2 seconds
- Simple, clean layout
- Shows 5 DS18B20 sensors

### tasmota-75 (COMPLEX, Berry-based)
```jsonl
{"page":1}
{"id":0,"bg_color":"#0000A0","bg_grad_color":"#000000","bg_grad_dir":1}
{"id":10,"obj":"obj","x":0,"y":0,"w":240,"h":26,"bg_color":"#D00000"}
{"id":12,"obj":"label","x":3,"y":4,"text":"192.168.0.77"}
{"id":13,"obj":"label","x":92,"y":4,"text":"miVida2"}
{"id":14,"obj":"label","x":155,"y":4,"text":"00:00:00"}
{"id":15,"obj":"lv_wifi_arcs","x":215,"y":0}
{"id":30,"obj":"label","x":5,"y":29,"text":"","text_color":"#FFFF00"}  // BME280-1
{"id":31,"obj":"label","x":125,"y":29,"text":"","text_color":"#FFFF00"} // BME280-2
{"id":20-29,"obj":"label",...}  // DS18B20 sensors (10 slots)
```

**Features**:
- Manual Berry script updates (autoexec.be)
- Complex layout with header
- Supports 2 BME280 + 10 DS18B20
- Requires Berry script to update text

## autoexec.be

### tasmota-101 (HYBRID APPROACH - PRODUCTION)
```berry
# autoexec-final.be - Hybrid approach
# 1. Detects DS18B20 sensors dynamically
# 2. Generates pages.jsonl with text_rule
# 3. Starts HASPmota

import haspmota
import json
import string

# Wait for sensors to initialize
tasmota.delay(2000)

# Read all sensors
var m = tasmota.read_sensors()
if m == nil
    print("No sensors found")
    haspmota.start()
    return
end

# Detect DS18B20 sensors dynamically
var ds_sensors = []
for key: m.keys()
    if string.find(key, 'DS18B20') == 0 || string.find(key, 'DS18S20') == 0
        var sensor = m[key]
        if sensor.contains('Temperature') && sensor.contains('Id')
            ds_sensors.push({
                'key': key,
                'id': sensor['Id']
            })
        end
    end
end

# Sort sensors alphabetically
# ... (sorting code)

# Generate pages.jsonl with text_rule
var pages = []
# ... (generation code)

# Write pages.jsonl
var f = open('pages.jsonl', 'w')
for line: pages
    f.write(line + '\n')
end
f.close()

# Start HASPmota
haspmota.start()
```

**~120 lines** - Fully automatic sensor detection and configuration.

### tasmota-75 (COMPLEX, 263 lines - NOT WORKING)
```berry
import haspmota
import json
import string

haspmota.start()

class SensorDashboard : Driver
    var network_counter
    
    def init()
        self.network_counter = 0
    end
    
    def every_second()
        # Manual updates to global.p1b12, p1b13, etc.
        # 263 lines of code
    end
end

global.dashboard = SensorDashboard()
tasmota.add_driver(global.dashboard)
```

**263 lines!** Manually updates all LVGL objects. **Problem**: HASPmota labels not created in esp32s3geek firmware.

### tasmota-77 (HYBRID APPROACH - COPIED FROM 101)
Same as tasmota-101 hybrid approach, but sensors not detected due to hardware issue (GPIO not connected).

## Display Status

| Device | DisplayModel | DisplayType | HASPmota | LVGL Mirror | Sensors | Approach |
|--------|--------------|-------------|----------|-------------|---------|----------|
| tasmota-101 | 17 (ST7789) | 0 | ✅ Works | ✅ Available | ✅ 5x DS18B20 | ✅ Hybrid (auto) |
| tasmota-75 | 17 (ST7789) | 0 | ❌ Labels not created | ✅ Available | ✅ 2x BME280 | ❌ Manual (263 lines) |
| tasmota-77 | 17 (ST7789) | 0 | ✅ Available | ✅ Available | ❌ None detected | ⚠️ Hybrid (no sensors) |

## Key Findings (Updated 2026-01-11)

### Why tasmota-101 Works ✅

1. **Firmware**: Uses standard **tasmota32** build with full HASPmota support
2. **display.ini**: Loaded and initialized correctly (DisplayModel 17)
3. **GPIO 13**: DS18x20 configured correctly, 5 sensors detected
4. **pages.jsonl**: Generated dynamically with text_rule for automatic updates
5. **autoexec.be**: Hybrid approach (~120 lines) - automatic sensor detection
6. **HASPmota**: Available and working perfectly
7. **LVGL Mirror**: Available in Web UI

**Status**: ✅ **PRODUCTION READY** - Hybrid approach deployed successfully

### Why tasmota-75 Has Issues ⚠️

1. **Firmware**: Custom **esp32s3geek** build has incomplete HASPmota support
2. **display.ini**: Loaded correctly (DisplayModel 17)
3. **GPIO**: I2C configured, 2x BME280 detected successfully
4. **pages.jsonl**: Exists but HASPmota labels not created by firmware
5. **autoexec.be**: Complex manual approach (263 lines) - can't work without labels
6. **HASPmota**: Available but labels (p1b30, p1b12, etc.) are nil
7. **LVGL Mirror**: Available in Web UI

**Status**: ⚠️ **Firmware limitation** - HASPmota label creation not working in esp32s3geek build

### Why tasmota-77 Has Issues ❌

1. **Firmware**: Custom **esp32s3geek** build (same as tasmota-75)
2. **display.ini**: Loaded correctly (DisplayModel 17) - **FIXED!**
3. **GPIO**: Template configured (GPIO 13 = DS18x20) but **no sensors detected**
4. **pages.jsonl**: Hybrid version uploaded, ready for sensors
5. **autoexec.be**: Hybrid approach uploaded (same as tasmota-101)
6. **HASPmota**: Available and working
7. **LVGL Mirror**: Available in Web UI

**Status**: ❌ **Hardware issue** - DS18B20 sensors not physically connected or wrong GPIO

## Solutions and Recommendations

### For tasmota-101 ✅
**Status**: Production ready, no changes needed.

**Current Configuration**:
- Firmware: tasmota32 (standard build)
- Approach: Hybrid (autoexec-final.be)
- Sensors: 5x DS18B20 auto-detected
- Display: Working perfectly

**Recommendation**: Use as reference for other devices.

### For tasmota-75 ⚠️
**Problem**: HASPmota labels not created in esp32s3geek firmware.

**Solutions**:

1. **Option A: Switch to tasmota32 firmware (RECOMMENDED)**
   - Flash standard tasmota32 build (like tasmota-101)
   - Use hybrid approach (autoexec-final.be)
   - Full HASPmota support guaranteed

2. **Option B: Use DisplayText instead of HASPmota**
   - Bypass HASPmota completely
   - Use DisplayText commands directly
   - No LVGL dependency

3. **Option C: Wait for firmware fix**
   - Wait for improved HASPmota support in esp32s3geek
   - Keep current configuration
   - Monitor Tasmota updates

**Recommendation**: Switch to tasmota32 firmware for production use.

### For tasmota-77 ❌
**Problem**: DS18B20 sensors not detected (hardware issue).

**Solutions**:

1. **Option A: Hardware inspection (IMMEDIATE)**
   - Physically identify which GPIO has DS18B20 sensors
   - Check wiring and connections
   - Test sensors with multimeter
   - Update GPIO template with correct pin

2. **Option B: Systematic GPIO testing**
   - Test all possible GPIOs one by one
   - Use template to set DS18x20 on each GPIO
   - Check sensor detection after each change

3. **Option C: Switch to tasmota32 firmware**
   - Flash standard tasmota32 build
   - Better hardware support
   - Same configuration as tasmota-101

**Recommendation**: Hardware inspection first, then consider firmware switch if needed.

## Firmware Update Results (2026-01-11)

### Custom Firmware Test - FAILED ❌

**Objective**: Build ESP32-S3 firmware with LVGL/HASPmota support

**Approach**:
- Modified platformio_override.ini for tasmota32s3-lvgl build
- Modified user_config_override.h with custom configuration
- Built firmware from Tasmota v15.0.1 source

**Result**:
- ❌ Both tasmota-75 and tasmota-77 went offline after OTA update
- ❌ Devices not responding to network requests
- ❌ Physical access required for recovery

**Root Cause**:
- Partition scheme mismatch between custom and standard builds
- Configuration conflicts (custom project name)
- No safeboot partition for automatic rollback

### Official Firmware Solution - RECOMMENDED ✅

**Firmware**: tasmota32-lvgl.bin 15.2.0
**Source**: http://ota.tasmota.com/tasmota32/release/tasmota32-lvgl.bin
**Size**: 2.6 MB

**Features**:
- ✅ Full LVGL support
- ✅ HASPmota working
- ✅ Works on ESP32-S3 (universal ESP32 build)
- ✅ Tested and stable
- ✅ Automatic rollback on failed boot

**Status**: Ready for deployment after device recovery

## Current Status Summary (2026-01-11 - After Firmware Tests)

### tasmota-101: ✅ PRODUCTION
```
Firmware:     tasmota32 (standard)
Display:      ✅ ST7789 (DisplayModel 17)
HASPmota:     ✅ Working
LVGL Mirror:  ✅ Available
Sensors:      ✅ 5x DS18B20 detected
Approach:     ✅ Hybrid (autoexec-final.be)
Files:        ✅ display.ini, pages.jsonl (generated), autoexec-final.be
Status:       ✅ PRODUCTION READY
```

### tasmota-75: ❌ OFFLINE (Recovery Required)
```
Firmware:     esp32s3geek (custom) - FAILED OTA UPDATE
Display:      Unknown (device offline)
HASPmota:     Unknown (device offline)
LVGL Mirror:  Unknown (device offline)
Sensors:      2x BME280 (before update)
Approach:     Hybrid (autoexec-final.be ready)
Files:        display.ini, autoexec-final.be (ready to upload)
Status:       ❌ OFFLINE - Needs serial recovery with tasmota32-lvgl-15.2.0.bin
```

### tasmota-77: ❌ OFFLINE (Recovery Required)
```
Firmware:     esp32s3geek (custom) - FAILED OTA UPDATE
Display:      Unknown (device offline)
HASPmota:     Unknown (device offline)
LVGL Mirror:  Unknown (device offline)
Sensors:      DS18B20 (hardware not detected before update)
Approach:     Hybrid (autoexec-final.be ready)
Files:        display.ini, autoexec-final.be (ready to upload)
Status:       ❌ OFFLINE - Needs serial recovery with tasmota32-lvgl-15.2.0.bin
```

## Deployment History

### v7 Release (2026-01-11)
- ✅ Hybrid approach (autoexec-final.be) developed
- ✅ Successfully deployed to tasmota-101
- ✅ All 5 DS18B20 sensors detected automatically
- ✅ pages.jsonl generated dynamically
- ✅ Display showing all sensors correctly
- ✅ Set as default configuration for project

### Next Steps
1. **tasmota-75**: Flash tasmota32 firmware, deploy hybrid approach
2. **tasmota-77**: Hardware inspection to find DS18B20 GPIO, then deploy hybrid approach
3. **Documentation**: Update all references to use hybrid as default
