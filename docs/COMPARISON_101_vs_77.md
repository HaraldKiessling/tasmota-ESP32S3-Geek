# Configuration Comparison: tasmota-101 vs tasmota-77

**Date**: 2026-01-11
**Purpose**: Detailed comparison of working configurations

## Executive Summary

| Feature | tasmota-101 | tasmota-77 |
|---------|-------------|------------|
| **Status** | ✅ Working | ✅ Working |
| **Firmware** | 15.0.1 (tasmota32) | 15.0.1 (tasmota32s3-lvgl) |
| **Sensors** | 5x DS18B20 | 2x DS18B20 |
| **Display** | ST7789 (17) | ST7789 (17) |
| **HASPmota** | ✅ Working | ⚠️ Unclear |
| **Approach** | Hybrid (auto) | Dynamic (manual) |

## Firmware Differences

### tasmota-101
```json
{
  "Version": "15.0.1(tasmota32)",
  "BuildDate": "2026-01-10T19:02:35",
  "Core": "3_1_3"
}
```

**Build**: Standard tasmota32 (ESP32 universal)
**Source**: Official Tasmota release
**Size**: ~2.1 MB

### tasmota-77
```json
{
  "Version": "15.0.1(tasmota32s3-lvgl)",
  "BuildDate": "2026-01-11T19:35:34",
  "Core": "3_1_3"
}
```

**Build**: Custom tasmota32s3-lvgl (ESP32-S3 specific)
**Source**: Custom build from source
**Size**: 2.5 MB

**Key Difference**: tasmota-101 uses standard tasmota32, tasmota-77 uses custom LVGL build

## GPIO Configuration

### tasmota-101 (Working)

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
    1,     // GPIO 7-12: User
    1312,  // GPIO 13: DS18x20 ← MAIN SENSOR GPIO
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

**Key GPIOs**:
- **GPIO 13**: DS18x20 (1312) - Primary sensor GPIO
- GPIO 17: I2C SCL (608)
- GPIO 18: I2C SDA (640)
- GPIO 4: ADC Range (4864)
- GPIO 21: Output Hi (3840)
- GPIO 22: Option A (6210)

### tasmota-77 (Working)

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0: Button
    0,     // GPIO 1-5: None
    1,     // GPIO 6: User
    0,     // GPIO 7-12: None
    1,     // GPIO 13: User
    1,     // GPIO 14: User
    0,     // GPIO 15: None
    640,   // GPIO 16: I2C SDA
    608,   // GPIO 17: I2C SCL
    0,     // GPIO 18-21: None
    8896,  // GPIO 22: SDIO D1
    8960,  // GPIO 23: SDIO D2
    8800,  // GPIO 24: SDIO CLK
    8832,  // GPIO 25: SDIO CMD
    8864,  // GPIO 26: SDIO D0
    8928,  // GPIO 27: SDIO D3
    0,     // GPIO 28: None
    6210,  // GPIO 29: Option A
    0,     // GPIO 30-31: None
    3200,  // GPIO 32: Serial Tx
    3232   // GPIO 33: Serial Rx
  ]
}
```

**Key GPIOs**:
- GPIO 6, 13, 14: User (1) - No DS18x20 configured!
- GPIO 16: I2C SDA (640)
- GPIO 17: I2C SCL (608)
- GPIO 22-27: SDIO (SD card support)
- GPIO 29: Option A (6210)
- GPIO 32-33: Serial Tx/Rx (3200/3232)

**Critical Difference**: tasmota-77 has NO DS18x20 GPIO configured in template!

## Sensor Configuration

### tasmota-101

**Sensors**: 5x DS18B20
```json
{
  "DS18B20-1": {"Id": "000000879D0A", "Temperature": 48.56},
  "DS18B20-2": {"Id": "6CF5D44624F6", "Temperature": 49.25},
  "DS18B20-3": {"Id": "4EEED446638B", "Temperature": 41.13},
  "DS18B20-4": {"Id": "0B34D4460EB7", "Temperature": 32.00},
  "DS18B20-5": {"Id": "0000006B190F", "Temperature": 41.19}
}
```

**GPIO**: GPIO 13 configured as DS18x20 (1312)
**Detection**: Automatic via GPIO configuration
**Status**: ✅ All 5 sensors working

### tasmota-77

**Sensors**: 2x DS18B20
```json
{
  "DS18B20-5329E2": {"Id": "0000005329E2", "Temperature": 22.4},
  "DS18B20-51C76D": {"Id": "00000051C76D", "Temperature": 22.1}
}
```

**GPIO**: NO DS18x20 configured in template!
**Detection**: Sensors detected despite missing GPIO configuration
**Status**: ✅ 2 sensors working (but GPIO not in template)

**Mystery**: How are sensors detected without GPIO configuration?

**Possible explanations**:
1. Previous GPIO configuration persisted in flash
2. Autodetection on common GPIOs (6, 13, 14)
3. Hardware default configuration
4. Berry script configuring GPIO at runtime

## Display Configuration

### tasmota-101

**DisplayModel**: 17 (ST7789)
**display.ini**: Present and loaded
**Status**: ✅ Working

### tasmota-77

**DisplayModel**: 17 (ST7789)
**display.ini**: Created via Berry console
**Status**: ✅ Working

**Same**: Both use ST7789 with DisplayModel 17

## HASPmota Configuration

### tasmota-101 (Hybrid Approach)

**autoexec.be**: autoexec-final.be (~120 lines)
```berry
# Hybrid approach
import haspmota
import json
import string

# Wait for sensors
tasmota.delay(2000)

# Read sensors
var m = tasmota.read_sensors()

# Detect DS18B20 dynamically
var ds_sensors = []
for key: m.keys()
    if string.find(key, 'DS18B20') == 0
        # Add to list
    end
end

# Sort alphabetically
# ... sorting code ...

# Generate pages.jsonl
var pages = []
# ... generation code ...

# Write pages.jsonl
var f = open('pages.jsonl', 'w')
for line: pages
    f.write(line + '\n')
end
f.close()

# Start HASPmota
haspmota.start()
```

**pages.jsonl**: Generated automatically at boot
**Features**:
- Automatic sensor detection
- Dynamic pages.jsonl generation
- Alphabetical sorting by sensor ID
- text_rule for automatic updates
- Berry cron for sensor refresh (every 2 seconds)

**Status**: ✅ Working perfectly

### tasmota-77 (Dynamic Approach)

**autoexec.be**: Uploaded by user (content unknown)
**pages.jsonl**: Uploaded by user (content unknown)

**Expected content** (if using standard approach):
```berry
import haspmota
haspmota.start()
```

**Status**: ⚠️ HASPmota not visible in Berry console
**Possible**: Files uploaded but not executing as expected

## File System

### tasmota-101

**Partition**: Standard tasmota32 partition scheme
**Filesystem**: Sufficient space for files
**Files**:
- display.ini: ✅ Present
- autoexec-final.be: ✅ Present (~120 lines)
- pages.jsonl: ✅ Generated automatically

**Free Space**: Adequate for configuration

### tasmota-77

**Partition**: Custom tasmota32s3-lvgl partition scheme
**Filesystem**: 320 KB partition, only ~12 KB free
**Files**:
- display.ini: ✅ Created via Berry console
- autoexec.be: ✅ Uploaded by user
- pages.jsonl: ✅ Uploaded by user

**Free Space**: Very limited (~12 KB)

**Key Difference**: tasmota-77 has much less filesystem space due to larger firmware

## Configuration Approach

### tasmota-101: Hybrid (Automatic)

**Method**: Automatic sensor detection and configuration
**Process**:
1. Boot → autoexec-final.be runs
2. Wait 2 seconds for sensors
3. Read all sensors via tasmota.read_sensors()
4. Detect DS18B20 sensors dynamically
5. Sort sensors alphabetically
6. Generate pages.jsonl with text_rule
7. Start HASPmota

**Advantages**:
- ✅ Fully automatic
- ✅ No manual configuration needed
- ✅ Works with any number of sensors
- ✅ Consistent sensor order (alphabetical)
- ✅ Plug and play

**Result**: ✅ All 5 sensors displayed and updating

### tasmota-77: Dynamic (Manual)

**Method**: Manual file upload
**Process**:
1. User uploads autoexec.be
2. User uploads pages.jsonl
3. Boot → autoexec.be runs
4. HASPmota starts with pages.jsonl

**Advantages**:
- ✅ Custom display layout possible
- ✅ Full control over configuration
- ✅ Can optimize for specific sensors

**Disadvantages**:
- ⚠️ Manual configuration required
- ⚠️ Must update when sensors change
- ⚠️ Limited filesystem space

**Result**: ✅ 2 sensors working, ⚠️ HASPmota status unclear

## Key Differences Summary

### 1. Firmware

| Aspect | tasmota-101 | tasmota-77 |
|--------|-------------|------------|
| Build | tasmota32 (standard) | tasmota32s3-lvgl (custom) |
| Size | ~2.1 MB | 2.5 MB |
| LVGL | Standard | Enhanced |
| Source | Official | Custom build |

### 2. GPIO Configuration

| GPIO | tasmota-101 | tasmota-77 |
|------|-------------|------------|
| 13 | DS18x20 (1312) | User (1) |
| 16 | User (1) | I2C SDA (640) |
| 17 | I2C SCL (608) | I2C SCL (608) |
| 18 | I2C SDA (640) | None (0) |
| 22-27 | Not configured | SDIO (SD card) |
| 32-33 | Not configured | Serial Tx/Rx |

**Critical**: tasmota-101 has DS18x20 on GPIO 13, tasmota-77 does not!

### 3. Sensor Detection

| Aspect | tasmota-101 | tasmota-77 |
|--------|-------------|------------|
| Sensors | 5x DS18B20 | 2x DS18B20 |
| GPIO Config | ✅ GPIO 13 = DS18x20 | ❌ No DS18x20 in template |
| Detection | Via GPIO config | Unknown method |
| Status | ✅ All working | ✅ Working (mystery) |

### 4. Configuration Approach

| Aspect | tasmota-101 | tasmota-77 |
|--------|-------------|------------|
| Method | Hybrid (automatic) | Dynamic (manual) |
| autoexec.be | ~120 lines | Unknown content |
| pages.jsonl | Generated at boot | Uploaded by user |
| Sensor detection | Automatic | Manual |
| Updates | Automatic | Manual |

### 5. Filesystem

| Aspect | tasmota-101 | tasmota-77 |
|--------|-------------|------------|
| Partition | Standard | Custom (320 KB) |
| Free space | Adequate | ~12 KB |
| File upload | ✅ Works | ❌ Fails (no space) |
| Configuration | Via files | Via Berry console |

## Mystery: tasmota-77 Sensor Detection

**Question**: How does tasmota-77 detect DS18B20 sensors without GPIO configuration?

**Template shows**:
- GPIO 6: User (1)
- GPIO 13: User (1)
- GPIO 14: User (1)
- NO DS18x20 (1312) configured!

**But sensors work**:
```json
{
  "DS18B20-5329E2": {"Temperature": 22.4},
  "DS18B20-51C76D": {"Temperature": 22.1}
}
```

**Possible explanations**:

1. **Previous configuration persisted**:
   - GPIO configuration stored in flash
   - Template shows default, not actual runtime config
   - Previous DS18x20 setting still active

2. **Autodetection**:
   - Tasmota may scan common GPIOs (6, 13, 14)
   - DS18B20 autodetection on boot
   - No explicit configuration needed

3. **Berry script configuration**:
   - autoexec.be may configure GPIO at runtime
   - Dynamic GPIO assignment
   - Not visible in template

4. **Hardware default**:
   - ESP32-S3 hardware default
   - Pull-up resistors on specific GPIOs
   - Automatic detection

**Most likely**: Previous GPIO configuration persisted in flash, template shows default but runtime uses stored config.

## Recommendations

### For tasmota-77

1. **Verify GPIO configuration**:
   ```bash
   # Check actual GPIO assignment
   curl "http://tasmota-77/cm?cmnd=GPIO"
   ```

2. **Set DS18x20 explicitly**:
   ```bash
   # Configure GPIO 13 as DS18x20
   curl "http://tasmota-77/cm?cmnd=GPIO13%201312"
   ```

3. **Save template**:
   ```bash
   # Save current configuration
   curl "http://tasmota-77/cm?cmnd=Template"
   ```

4. **Use hybrid approach**:
   - Replace manual files with autoexec-final.be
   - Automatic sensor detection
   - No manual configuration needed

### For consistency

**Make tasmota-77 match tasmota-101**:
1. Configure GPIO 13 as DS18x20 (1312)
2. Upload autoexec-final.be (hybrid approach)
3. Remove manual pages.jsonl (let it generate)
4. Restart and verify

**Result**: Both devices with same configuration approach

## Conclusion

### Main Differences

1. **Firmware**: tasmota-101 uses standard tasmota32, tasmota-77 uses custom tasmota32s3-lvgl
2. **GPIO**: tasmota-101 has DS18x20 configured, tasmota-77 does not (but works anyway)
3. **Approach**: tasmota-101 uses hybrid (automatic), tasmota-77 uses dynamic (manual)
4. **Filesystem**: tasmota-101 has more space, tasmota-77 is constrained
5. **HASPmota**: tasmota-101 confirmed working, tasmota-77 status unclear

### Both Working

Despite differences, both devices are functional:
- ✅ Sensors detected and reporting
- ✅ Display initialized
- ✅ Values updating

### Recommendation

**Standardize on hybrid approach**:
- Use autoexec-final.be on both devices
- Automatic sensor detection
- Consistent configuration
- No manual maintenance

**Current status**: Both working, but different approaches. Standardization would improve maintainability.
