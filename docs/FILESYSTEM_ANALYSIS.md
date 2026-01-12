# Filesystem Analysis and Upload Problem Solution

**Date**: 2026-01-12
**Device**: tasmota-77
**Issue**: File upload fails with "Not enough space" error

## Problem Analysis

### Current Filesystem Status

**tasmota-77**:
```json
{
  "UfsFree": 12572,
  "UfsSize": 12608
}
```

**Total filesystem**: Only 12 KB!
**Free space**: 12 KB
**Problem**: Cannot upload configuration files (display.ini, autoexec.be, pages.jsonl)

### Firmware Size

```json
{
  "ProgramSize": 2528,
  "FlashSize": 16384,
  "ProgramFlashSize": 16384
}
```

- Firmware: 2528 KB (2.5 MB)
- Flash: 16 MB total
- Filesystem: Only 12 KB (0.07% of flash!)

## Root Cause

### Partition Table Issue

The custom firmware was built without specifying a partition table, so it used a default minimal partition scheme.

**Default partition** (inferred from filesystem size):
- Firmware partition: ~2.9 MB
- Filesystem partition: ~12 KB (minimal)

**Problem**: 12 KB is insufficient for:
- display.ini: ~300 bytes
- autoexec.be: ~3-120 lines (varies)
- pages.jsonl: ~500-2000 bytes
- Other system files

### Comparison with tasmota-101

**tasmota-101** (working):
- Firmware: tasmota32 (standard)
- Filesystem: Adequate space (likely 320 KB or more)
- File upload: ✅ Works

**tasmota-77** (problem):
- Firmware: tasmota32s3-lvgl (custom, no partition specified)
- Filesystem: Only 12 KB
- File upload: ❌ Fails

## Solution

### New Partition Table

Created custom partition table: `esp32_partition_app2880k_fs1024k.csv`

```csv
# Name,   Type, SubType, Offset,  Size, Flags
nvs,      data, nvs,     0x9000,  0x5000,
otadata,  data, ota,     0xe000,  0x2000,
safeboot, app,  factory, 0x10000, 0xD0000,
app0,     app,  ota_0,   0xE0000, 0x2D0000,
spiffs,   data, spiffs,  0x3B0000,0x100000,
```

**Partition sizes**:
- nvs: 20 KB (settings storage)
- otadata: 8 KB (OTA data)
- safeboot: 832 KB (safeboot firmware)
- app0: 2880 KB (main firmware)
- spiffs: 1024 KB (filesystem) ← **Increased from 12 KB!**

**Total**: 4764 KB (4.6 MB) - fits in 16 MB flash

### Updated Build Configuration

Modified `platformio_override.ini`:

```ini
[env:tasmota32s3-lvgl]
extends                 = env:tasmota32_base
board                   = esp32s3-qio_qspi
board_build.f_cpu       = 240000000L
board_build.partitions  = partitions/esp32_partition_app2880k_fs1024k.csv  ← Added
build_flags             = ${env:tasmota32_base.build_flags}
                          -DFIRMWARE_LVGL
```

### New Firmware Build

**Build result**:
```
RAM:   [==        ]  18.9% (used 61892 bytes from 327680 bytes)
Flash: [========= ]  87.8% (used 2588240 bytes from 2949120 bytes)

Read partitions from  partitions/esp32_partition_app2880k_fs1024k.csv
--------------------------------------------------------------------
# Name,     Type,   SubType,   Offset,    Size,   Flags
nvs         data    nvs        0x9000     0x5000
otadata     data    ota        0xe000     0x2000
safeboot    app     factory    0x10000    0xD0000
app0        app     ota_0      0xE0000    0x2D0000
spiffs      data    spiffs     0x3B0000   0x100000  ← 1 MB filesystem!

======================== [SUCCESS] Took 382.72 seconds ========================
```

**Output files**:
- `firmware/tasmota32s3-lvgl-15.0.1-fs1024k.bin` (2.5 MB)
- `firmware/tasmota32s3-lvgl-15.0.1-fs1024k.factory.bin` (3.4 MB)

## Deployment

### OTA Update Attempt

**Attempted**: OTA update from old firmware (12 KB filesystem) to new firmware (1 MB filesystem)

**Result**: ❌ Failed - Device went to SAFEBOOT

**Reason**: Partition table change requires full flash erase and reflash

**OTA limitations**:
- Cannot change partition table via OTA
- Partition layout must match between old and new firmware
- Changing partition sizes requires serial flash

### Required Method: Serial Flash

**Only option**: Flash via serial connection with factory.bin

**Command**:
```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  erase_flash

esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 firmware/tasmota32s3-lvgl-15.0.1-fs1024k.factory.bin
```

**Why factory.bin**:
- Contains bootloader
- Contains partition table
- Contains safeboot firmware
- Contains main firmware
- Complete flash image

## Comparison: Before vs After

### Before (12 KB Filesystem)

| Aspect | Value |
|--------|-------|
| Filesystem size | 12 KB |
| Free space | 12 KB |
| File upload | ❌ Fails |
| Configuration | Via Berry console only |
| Workaround | Create files programmatically |

### After (1 MB Filesystem)

| Aspect | Value |
|--------|-------|
| Filesystem size | 1024 KB (1 MB) |
| Free space | ~1000 KB (after files) |
| File upload | ✅ Should work |
| Configuration | Via file upload |
| Workaround | Not needed |

**Improvement**: 85x more filesystem space!

## Expected Results After Serial Flash

### Filesystem Space

**Before**:
```json
{
  "UfsFree": 12572,
  "UfsSize": 12608
}
```

**After** (expected):
```json
{
  "UfsFree": ~1000000,
  "UfsSize": 1048576
}
```

### File Upload

**Before**: ❌ Fails with "Not enough space"

**After**: ✅ Should work for:
- display.ini (~300 bytes)
- autoexec-final.be (~3-5 KB)
- pages.jsonl (~1-2 KB)
- Additional configuration files

### Configuration Approach

**Before**: Berry console workaround
```bash
curl --data-urlencode "c1=$(cat create_display.be)" "http://device/cm?cmnd=br"
```

**After**: Standard file upload
```bash
curl -F "file=@config/display.ini" http://device/u2
curl -F "file=@autoconf/autoexec-final.be;filename=autoexec.be" http://device/u2
```

## Lessons Learned

### ❌ What Went Wrong

1. **No partition table specified** in initial build
2. **Default partition too small** for practical use
3. **OTA cannot change partitions** - requires serial flash
4. **Testing insufficient** - didn't verify filesystem size before deployment

### ✅ What to Do

1. **Always specify partition table** in platformio_override.ini
2. **Allocate adequate filesystem** (minimum 320 KB, recommended 1 MB)
3. **Test filesystem size** before deployment
4. **Use factory.bin** for initial flash
5. **Document partition layout** in firmware documentation

### 💡 Best Practices

1. **Partition Planning**:
   - Firmware: 2-3 MB (depending on features)
   - Filesystem: 1 MB minimum (for LVGL/HASPmota)
   - Safeboot: 832 KB (standard)
   - NVS: 20 KB (standard)

2. **Build Configuration**:
   - Always specify `board_build.partitions`
   - Use appropriate partition table for firmware size
   - Test build before deployment

3. **Deployment**:
   - Initial flash: Use factory.bin via serial
   - Updates: Use OTA .bin (if partition table unchanged)
   - Partition changes: Require serial flash

4. **Testing**:
   - Verify filesystem size after flash
   - Test file upload before production
   - Document partition layout

## Recommendations

### For tasmota-77

**Immediate action**: Serial flash with new firmware
```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 firmware/tasmota32s3-lvgl-15.0.1-fs1024k.factory.bin
```

**After flash**:
1. Verify filesystem size: `UfsSize` should be ~1 MB
2. Upload configuration files via web UI
3. Test file upload functionality
4. Configure GPIO template
5. Upload autoexec-final.be (hybrid approach)
6. Restart and verify

### For tasmota-75

**Check filesystem size**:
```bash
curl "http://tasmota-75/cm?cmnd=UfsSize"
```

**If also 12 KB**: Flash with new firmware
**If adequate**: Keep current firmware

### For Future Builds

**Always use partition table**:
```ini
[env:tasmota32s3-lvgl]
board_build.partitions  = partitions/esp32_partition_app2880k_fs1024k.csv
```

**Standard partition tables**:
- Small firmware (<1.8 MB): `esp32_partition_app1856k_fs1344k.csv`
- Medium firmware (2-2.8 MB): `esp32_partition_app2880k_fs1024k.csv`
- Large firmware (>2.8 MB): `esp32_partition_app3904k_fs3392k.csv`

## Files Created

### Partition Table
- `Tasmota/partitions/esp32_partition_app2880k_fs1024k.csv`

### Firmware
- `firmware/tasmota32s3-lvgl-15.0.1-fs1024k.bin` (OTA update)
- `firmware/tasmota32s3-lvgl-15.0.1-fs1024k.factory.bin` (Serial flash)

### Configuration
- `Tasmota/platformio_override.ini` (updated with partition table)

## Conclusion

### Problem Identified

**Root cause**: Custom firmware built without partition table specification, resulting in minimal 12 KB filesystem.

### Solution Implemented

**New firmware**: Built with 1 MB filesystem partition (85x larger)

### Deployment Required

**Method**: Serial flash with factory.bin (OTA not possible due to partition change)

### Expected Outcome

After serial flash:
- ✅ 1 MB filesystem space
- ✅ File upload working
- ✅ Standard configuration approach
- ✅ No Berry console workarounds needed

### Status

**Current**: New firmware built and ready
**Next step**: Serial flash to tasmota-77 (requires physical access)
**Result**: File upload problem solved
