# Scripts Guide - ESP32S3-Geek Display Configuration

Complete guide to autoexec.be and pages.jsonl configurations for ESP32S3-Geek.

## Overview

Three main approaches for display configuration:

1. **Hybrid (Recommended)** - Automatic sensor detection and pages.jsonl generation
2. **HASPmota Labels** - Manual label updates via Berry
3. **text_rule** - Automatic updates via LVGL text_rule

## Available Scripts

### autoexec.be Variants

| File | Lines | Approach | Status | Use Case |
|------|-------|----------|--------|----------|
| `autoexec-final.be` | 120 | Hybrid | ✅ Recommended | Auto-detects sensors, generates pages.jsonl |
| `autoexec-75-dynamic.be` | 156 | HASPmota Labels | ⚠️ Requires working HASPmota | Manual label updates |
| `autoexec-101.be` | 3 | Minimal | ✅ Simple | Requires pre-configured pages.jsonl |

### pages.jsonl Variants

| File | Approach | Status | Use Case |
|------|----------|--------|----------|
| `pages-final.jsonl` | text_rule | ✅ Recommended | Automatic sensor updates |
| `pages-101.jsonl` | text_rule | ✅ Working | tasmota-101 configuration |
| `pages-75-original.jsonl` | HASPmota Labels | ⚠️ Requires Berry updates | Manual updates |

## Recommended Configuration

### Option 1: Hybrid (Best for Dynamic Sensors)

**Use Case**: Unknown sensor IDs, sensors may change

**Files**:
- `autoexec-final.be` (or `autoexec-hybrid.be`)

**How it works**:
1. Detects all DS18B20 sensors at boot
2. Generates `pages.jsonl` with correct sensor names
3. Uses text_rule for automatic updates
4. No manual configuration needed

**Installation**:
```bash
# Upload to device
curl -F "ufsu=@config/autoexec-final.be" \
  "http://tasmota-77.local/ufsu?fsz=$(stat -c%s config/autoexec-final.be)"

# Rename to autoexec.be
# Via web interface or curl commands

# Restart device
curl "http://tasmota-77.local/cm?cmnd=Restart%201"
```

**Pros**:
- ✅ Fully automatic
- ✅ Works with any sensor IDs
- ✅ Add/remove sensors without reconfiguration
- ✅ Generates optimal pages.jsonl

**Cons**:
- ⚠️ Requires 2-3 second delay at boot
- ⚠️ Regenerates pages.jsonl on every boot

### Option 2: text_rule (Best for Fixed Sensors)

**Use Case**: Known sensor IDs, stable configuration

**Files**:
- `autoexec-101.be` (minimal)
- `pages-final.jsonl` (edit sensor names first!)

**How it works**:
1. Minimal autoexec.be just starts HASPmota
2. pages.jsonl uses text_rule to auto-update labels
3. Berry cron triggers sensor reads every 2 seconds

**Installation**:
```bash
# Edit pages-final.jsonl with your sensor names
# Replace DS18B20-1, DS18B20-2 with actual names

# Upload both files
curl -F "ufsu=@config/autoexec-101.be" ...
curl -F "ufsu=@config/pages-final.jsonl" ...

# Restart
curl "http://tasmota-77.local/cm?cmnd=Restart%201"
```

**Pros**:
- ✅ Fast boot (no generation delay)
- ✅ Simple and clean
- ✅ Automatic updates via text_rule

**Cons**:
- ❌ Requires manual sensor name configuration
- ❌ Must edit pages.jsonl for different sensors

### Option 3: HASPmota Labels (Advanced)

**Use Case**: Complex display logic, custom updates

**Files**:
- `autoexec-75-dynamic.be`
- `pages-75-original.jsonl`

**How it works**:
1. Berry script updates LVGL labels directly
2. Dynamic sensor detection
3. Manual control over display updates

**Installation**:
```bash
# Upload both files
curl -F "ufsu=@config/autoexec-75-dynamic.be" ...
curl -F "ufsu=@config/pages-75-original.jsonl" ...

# Restart
curl "http://tasmota-77.local/cm?cmnd=Restart%201"
```

**Pros**:
- ✅ Full control over display
- ✅ Dynamic sensor detection
- ✅ Custom update logic

**Cons**:
- ❌ Requires working HASPmota (firmware dependent)
- ❌ More complex code
- ❌ Labels may not be created (timing issues)

## Comparison Matrix

| Feature | Hybrid | text_rule | HASPmota Labels |
|---------|--------|-----------|-----------------|
| Auto sensor detection | ✅ | ❌ | ✅ |
| Boot time | Medium | Fast | Fast |
| Configuration | None | Manual | None |
| Firmware dependency | Low | Low | High |
| Code complexity | Medium | Low | High |
| Reliability | ✅ High | ✅ High | ⚠️ Medium |

## Sensor Name Formats

### Tasmota Sensor Names

**DS18B20**:
- Format: `DS18B20-XXXXXX` (last 6 chars of ID)
- Example: `DS18B20-5329E2`, `DS18B20-51C76D`
- Or: `DS18B20-1`, `DS18B20-2` (sequential)

**BME280**:
- Format: `BME280-XX` (I2C address)
- Example: `BME280-76`, `BME280-77`

### Display Format

**Hybrid/Dynamic**:
- Shows last 4-6 characters of ID
- Example: `5329E2: 23.4 C`

**text_rule**:
- Configurable format string
- Example: `text_rule_format:"1:%4.2f C"`

## Troubleshooting

### Sensors Not Displayed

**Hybrid approach**:
1. Check if pages.jsonl was generated:
   ```bash
   curl "http://tasmota-77.local/ufsd?download=/pages.jsonl"
   ```
2. Verify sensor names match
3. Check Berry console for errors

**text_rule approach**:
1. Verify sensor names in pages.jsonl match actual sensors
2. Check Berry cron is running:
   ```bash
   curl "http://tasmota-77.local/cm?cmnd=br%20print(tasmota.read_sensors())"
   ```

**HASPmota Labels**:
1. Check if labels exist:
   ```bash
   curl "http://tasmota-77.local/cm?cmnd=br%20print(global.p1b20)"
   ```
2. If nil, HASPmota didn't create labels
3. Try different firmware (tasmota32 vs esp32s3geek)

### Display Not Updating

1. Check DisplayModel:
   ```bash
   curl "http://tasmota-77.local/cm?cmnd=DisplayModel"
   ```
   Should return 17 (ST7789)

2. Verify display.ini exists and is loaded

3. Check Berry is enabled:
   ```bash
   curl "http://tasmota-77.local/cm?cmnd=SetOption36"
   ```
   Should return 1 (ON)

### HASPmota Not Working

**Symptoms**: Labels are nil, dashboard not created

**Causes**:
1. Firmware doesn't support HASPmota fully
2. pages.jsonl not loaded
3. Timing issue (labels not created yet)

**Solutions**:
1. Use tasmota32 firmware instead of esp32s3geek
2. Use hybrid or text_rule approach instead
3. Add delay before accessing labels

## Best Practices

### For Production

1. **Use Hybrid approach** for flexibility
2. **Test on tasmota32 firmware** for best HASPmota support
3. **Keep display.ini** for proper display initialization
4. **Monitor Berry console** for errors during development

### For Development

1. **Start with minimal** (autoexec-101.be + pages-final.jsonl)
2. **Test sensor detection** before adding display logic
3. **Use Berry console** to debug:
   ```bash
   curl "http://tasmota-77.local/cm?cmnd=br%20print(tasmota.read_sensors())"
   ```

### For Maintenance

1. **Document sensor IDs** in comments
2. **Keep original files** as backup
3. **Test after firmware updates**
4. **Version control** your configurations

## File Organization

```
config/
├── autoexec-final.be          # Recommended: Hybrid approach
├── autoexec-75-dynamic.be     # Alternative: HASPmota labels
├── autoexec-101.be            # Minimal: 3 lines
├── pages-final.jsonl          # Recommended: text_rule
├── pages-101.jsonl            # Reference: tasmota-101
├── pages-75-original.jsonl    # Reference: tasmota-75
├── autoexec-75-original.be    # Reference: Original from tasmota-75
└── autoexec-hybrid.be         # Same as autoexec-final.be
```

## Migration Guide

### From v6 to v7

1. **Backup current configuration**
2. **Upload new autoexec-final.be**
3. **Remove old pages.jsonl** (will be regenerated)
4. **Restart device**
5. **Verify sensors displayed**

### From Static to Dynamic

1. **Note current sensor IDs**
2. **Upload autoexec-final.be**
3. **Remove static pages.jsonl**
4. **Restart and verify**

### From HASPmota to text_rule

1. **Upload autoexec-101.be**
2. **Edit pages-final.jsonl** with sensor names
3. **Upload pages-final.jsonl**
4. **Restart and verify**

## Support

For issues:
1. Check this guide
2. Review [TASMOTA-77-SUCCESS.md](TASMOTA-77-SUCCESS.md)
3. Check [TASMOTA-75-DYNAMIC-TEST.md](TASMOTA-75-DYNAMIC-TEST.md)
4. Verify hardware connections in [HARDWARE.md](HARDWARE.md)

## License

Part of Tasmota ESP32S3-Geek project, licensed under GPL-3.0.
