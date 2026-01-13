# Autoexec.be Examples

Berry script examples for ESP32S3-Geek automatic execution on boot.

---

## Files

### autoexec-101.be
**Simple HASPmota starter**
- Minimal configuration
- Uses default pages.jsonl
- Best for static displays

**Usage**:
```bash
# Upload to device as autoexec.be
```

---

### autoexec-final.be / autoexec-hybrid.be
**Dynamic sensor detection**
- Detects DS18B20 sensors automatically
- Generates pages.jsonl dynamically
- Updates display every 2 seconds
- Network info (IP, SSID) every 60 seconds

**Features**:
- Auto-detects all DS18B20 sensors
- Creates sensor pages dynamically
- Real-time temperature updates
- Network status display

**Usage**:
```bash
# Upload to device as autoexec.be
# No pages.jsonl needed - generated automatically
```

---

### autoexec-75-dynamic.be
**Legacy dynamic dashboard**
- For older Tasmota versions
- Manual sensor configuration
- Fixed sensor IDs

---

### autoexec-75-original.be
**Original dashboard implementation**
- First version with manual updates
- Requires specific sensor IDs
- Reference implementation

---

### autoexec-v15.2.0.be
**Display test for Tasmota 15.2.0**
- Simple LVGL display test
- Verifies display initialization
- Shows display dimensions
- Useful for troubleshooting

**Usage**:
```bash
# Upload to test display functionality
# Check console for output
```

---

## Recommended Configuration

### For Production (with sensors)
Use **autoexec-final.be** or **autoexec-hybrid.be**:
- Automatic sensor detection
- Dynamic display updates
- No manual configuration needed

### For Testing
Use **autoexec-101.be**:
- Simple and reliable
- Uses static pages.jsonl
- Easy to debug

### For Display Testing
Use **autoexec-v15.2.0.be**:
- Verifies display works
- Shows basic LVGL functionality
- Minimal dependencies

---

## Installation

1. Choose appropriate autoexec file
2. Rename to `autoexec.be`
3. Upload via Tasmota web interface:
   - **Consoles → Manage File System → Upload**
4. Restart device: `Restart 1`

---

## Troubleshooting

### Sensors not showing
- Check GPIO configuration: `GPIO`
- Verify sensors detected: `Status 10`
- Check autoexec.be uploaded correctly
- Restart device

### Display not updating
- Check console for errors
- Verify HASPmota started: Look for "HASPmota started"
- Check display.ini uploaded
- Try autoexec-v15.2.0.be for basic test

### Network info not showing
- Wait 60 seconds for first update
- Check WiFi connected: `Status 5`
- Verify pages.jsonl has network elements

---

---

## Pages.jsonl Files

### pages-101.jsonl
**Static 5-sensor display**
- Fixed layout for 5 DS18B20 sensors
- WiFi status and clock
- Auto-refresh every 2 seconds
- Best for known sensor configuration

**Layout**:
- Header: Title, WiFi, Clock
- Page 1: 5 temperature sensors (DS18B20-1 to DS18B20-5)

**Usage**:
```bash
# Upload as pages.jsonl
# Use with autoexec-101.be
```

---

### pages-final.jsonl
**Production-ready display**
- Same as pages-101.jsonl
- Optimized for production use
- Tested configuration

---

### pages-75-original.jsonl
**Legacy manual update display**
- Requires manual updates via autoexec.be
- Fixed sensor IDs
- Network info display
- Reference implementation

---

## Choosing the Right Configuration

### Static Display (Recommended)
**Files**: `pages-101.jsonl` + `autoexec-101.be`
- Simple and reliable
- Fixed sensor layout
- Easy to customize
- Best for production

### Dynamic Display (Advanced)
**Files**: `autoexec-final.be` (no pages.jsonl needed)
- Auto-detects sensors
- Generates display dynamically
- Adapts to sensor changes
- Best for flexible setups

### Display Testing
**Files**: `autoexec-v15.2.0.be` (no pages.jsonl needed)
- Minimal LVGL test
- Verifies display works
- Shows dimensions
- Best for troubleshooting

---

## See Also

- [DS18X20_CONFIGURATION.md](../../docs/DS18X20_CONFIGURATION.md) - Sensor setup
- [DISPLAY_INI_REFERENCE.md](../../docs/DISPLAY_INI_REFERENCE.md) - Display configuration
- [GPIO_PINOUT.md](../../docs/GPIO_PINOUT.md) - GPIO reference
