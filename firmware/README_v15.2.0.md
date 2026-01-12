# Tasmota32 S3 LVGL v15.2.0 Firmware

**⚠️ Experimental Release - Use with caution**

## Quick Start

### Download

- **OTA**: `tasmota32s3-lvgl-15.2.0-fixed.bin` (2.6 MB)
- **Factory**: `tasmota32s3-lvgl-15.2.0-fixed.factory.bin` (3.5 MB)

### Flash

```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota32s3-lvgl-15.2.0-fixed.factory.bin
```

### Configure

1. WiFi: Connect to AP `tasmota-XXXXXX`
2. GPIO: Apply template from [RELEASE_v15.2.0.md](../RELEASE_v15.2.0.md)
3. Files: Upload `display.ini`, `autoexec.be`, `pages.jsonl`
4. **Important**: Use correct display.ini from `config/display-working-v15.2.0.ini`

## ⚠️ Important

**This version requires exact configuration!**

- Wrong display.ini causes boot loops
- Less tolerant than v15.0.1
- Recommended for advanced users only

**For production: Use v15.0.1 instead**

## Features

✅ Extension Manager  
✅ Matter Protocol  
✅ LVGL 9.4.0  
✅ HASPmota  
✅ Berry Scripting  

## Documentation

See [RELEASE_v15.2.0.md](../RELEASE_v15.2.0.md) for complete documentation.

## Support

- Issues: [GitHub](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues)
- Docs: [Tasmota](https://tasmota.github.io/docs/)

---

**Version**: 15.2.0-fixed  
**Date**: 2026-01-12  
**Status**: Experimental
