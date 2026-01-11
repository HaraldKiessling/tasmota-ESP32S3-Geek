# Configuration Comparison: tasmota-101 vs tasmota-75 vs tasmota-77

## Firmware Versions

| Device | Version | Build Date | Core |
|--------|---------|------------|------|
| tasmota-101 | 15.0.1 (tasmota32) | 2026-01-10T19:02:35 | 3_1_3 |
| tasmota-75 | 15.0.1 (esp32s3geek) | 2026-01-11T08:08:31 | ? |
| tasmota-77 | 15.0.1 (esp32s3geek) | 2026-01-11T10:52:47 | ? |

**Key Difference**: tasmota-101 uses **tasmota32** (standard ESP32 build), others use **esp32s3geek** (custom build)

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

### tasmota-101 (MINIMAL, WORKING)
```berry
# simple `autoexec.be` to run HASPmota using the default `pages.jsonl`
import haspmota
haspmota.start()
```

**3 lines total!** pages.jsonl does all the work with text_rule.

### tasmota-75 (COMPLEX, 263 lines)
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

**263 lines!** Manually updates all LVGL objects.

## Display Status

| Device | DisplayModel | DisplayType | HASPmota | LVGL Mirror | DS18B20 |
|--------|--------------|-------------|----------|-------------|---------|
| tasmota-101 | 17 (ST7789) | 0 | ✅ Works | ✅ Available | ✅ 5 sensors |
| tasmota-75 | 17 (ST7789) | 0 | ❌ Not working | ❓ Unknown | ❌ None |
| tasmota-77 | 0 (None) | 0 | ❌ Not working | ❌ Not available | ❌ None |

## Key Findings

### Why tasmota-101 Works

1. **Firmware**: Uses standard **tasmota32** build (not custom esp32s3geek)
2. **display.ini**: Loaded and initialized correctly
3. **GPIO 13**: DS18x20 configured correctly
4. **pages.jsonl**: Uses text_rule for automatic updates
5. **autoexec.be**: Minimal (3 lines), just starts HASPmota
6. **HASPmota**: Available and working

### Why tasmota-75/77 Don't Work

1. **Firmware**: Custom **esp32s3geek** build may have issues
2. **display.ini**: Not loaded/initialized
3. **GPIO**: Wrong or missing DS18B20 configuration
4. **pages.jsonl**: Requires manual Berry updates
5. **autoexec.be**: Complex (263 lines), tries to update manually
6. **HASPmota**: Not available or not working

## Solution for tasmota-77

### Option 1: Use tasmota-101 Configuration (RECOMMENDED)

1. **GPIO Template**: Copy from tasmota-101
   - Set GPIO 13 to DS18x20 (1312)
   - Set GPIO 17/18 to I2C (608/640)

2. **display.ini**: Use identical file (already have it)

3. **pages.jsonl**: Use tasmota-101 version with text_rule

4. **autoexec.be**: Use minimal 3-line version

5. **Firmware**: Consider using standard tasmota32 instead of esp32s3geek

### Option 2: Fix esp32s3geek Firmware

1. Rebuild firmware with proper LVGL support
2. Ensure display.ini is loaded at boot
3. Fix GPIO configuration
4. Test thoroughly

## Recommended Configuration for tasmota-77

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0: Button
    1,     // GPIO 1-12: User
    1312,  // GPIO 13: DS18x20 ← CRITICAL!
    33,    // GPIO 14: Button_n
    1,     // GPIO 15-16: User
    608,   // GPIO 17: I2C SCL
    640,   // GPIO 18: I2C SDA
    1,     // GPIO 19-20: User
    3840,  // GPIO 21: Output Hi
    6210   // GPIO 22: Option A
  ]
}
```

**Files**:
- display.ini: Use tasmota-101 version
- pages.jsonl: Use tasmota-101 version (with text_rule)
- autoexec.be: Use minimal 3-line version

**Expected Result**:
- ✅ Display initialized
- ✅ HASPmota working
- ✅ DS18B20 sensors detected
- ✅ LVGL Mirror available
- ✅ Automatic sensor updates
