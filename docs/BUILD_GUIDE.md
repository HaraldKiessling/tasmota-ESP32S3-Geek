# Tasmota32 S3 LVGL Firmware Build Guide

Complete guide for building custom Tasmota firmware with LVGL support for ESP32-S3.

## Overview

This guide covers building a custom Tasmota firmware with:
- ✅ LVGL graphics library
- ✅ HASPmota display automation
- ✅ DS18B20 temperature sensors
- ✅ BME280 environmental sensors
- ✅ ST7789 TFT display support
- ✅ Berry scripting with PSRAM
- ✅ ESP32-S3 optimization

## Prerequisites

### System Requirements
- Linux, macOS, or Windows (WSL2)
- Python 3.8 or newer
- Git
- 4GB RAM minimum
- 10GB free disk space

### Software Dependencies
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y git python3 python3-pip python3-venv

# macOS
brew install python3 git

# Verify installation
python3 --version
git --version
```

## Quick Start

### Automated Build

Use the provided build script for a fully automated build:

```bash
cd /workspaces/tasmota-ESP32S3-Geek
./scripts/build-lvgl.sh
```

The script will:
1. Clone Tasmota repository (if needed)
2. Setup Python virtual environment
3. Install PlatformIO
4. Copy configuration files
5. Build firmware
6. Verify build output

**Build time**: ~5-10 minutes (first build), ~2-3 minutes (subsequent builds)

### Output Files

After successful build:
```
firmware/
├── tasmota32s3-lvgl-15.0.1.bin         # OTA firmware
└── tasmota32s3-lvgl-15.0.1.factory.bin # Factory firmware (includes bootloader)
```

## Manual Build Process

### Step 1: Clone Tasmota Repository

```bash
cd /workspaces/tasmota-ESP32S3-Geek
git clone --depth 1 --branch v15.0.1 https://github.com/arendst/Tasmota.git
cd Tasmota
```

### Step 2: Setup Build Environment

```bash
# Create Python virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate  # Linux/macOS
# or
.venv\Scripts\activate     # Windows

# Install PlatformIO
pip install --upgrade pip
pip install platformio
```

### Step 3: Configure Build

Copy configuration files:

```bash
# Copy user configuration
cp ../config/user_config_override.h tasmota/

# Copy PlatformIO configuration
cp ../config/platformio_override.ini .
```

### Step 4: Build Firmware

```bash
# Build tasmota32s3-lvgl environment
.venv/bin/pio run -e tasmota32s3-lvgl

# Or with verbose output
.venv/bin/pio run -e tasmota32s3-lvgl -v
```

### Step 5: Locate Build Output

```bash
# Firmware files are in:
.pio/build/tasmota32s3-lvgl/firmware.bin
.pio/build/tasmota32s3-lvgl/firmware.factory.bin

# Copy to project firmware directory
cp .pio/build/tasmota32s3-lvgl/firmware.bin \
   ../firmware/tasmota32s3-lvgl-15.0.1.bin
   
cp .pio/build/tasmota32s3-lvgl/firmware.factory.bin \
   ../firmware/tasmota32s3-lvgl-15.0.1.factory.bin
```

## Build Configurations

### Available Build Environments

#### 1. tasmota32s3-lvgl (Default)
Standard LVGL build with balanced partition scheme.

**Partition Scheme**: app2944k_fs1088k
- Application: 2944 KB
- Filesystem: 1088 KB
- Total: ~4 MB

**Features**:
- Full LVGL support
- HASPmota
- Berry scripting
- All sensors

#### 2. tasmota32s3-lvgl-fs1024k
LVGL build with 1024k filesystem.

**Partition Scheme**: app2944k_fs1024k
- Application: 2944 KB
- Filesystem: 1024 KB

#### 3. tasmota32s3-lvgl-minimal
Minimal LVGL build with small filesystem.

**Partition Scheme**: app3264k_fs320k
- Application: 3264 KB
- Filesystem: 320 KB

**Use case**: Maximum application space, minimal file storage

### Build Specific Environment

```bash
# Build specific environment
.venv/bin/pio run -e tasmota32s3-lvgl-fs1024k

# Build all environments
.venv/bin/pio run
```

## Configuration Files

### user_config_override.h

Located in `config/user_config_override.h`, this file defines:

```c
// Project identification
#define PROJECT                "tasmota32s3-lvgl"
#define CODE_IMAGE_STR         "tasmota32s3-lvgl"

// Enabled features
#define USE_LVGL                    // LVGL graphics
#define USE_LVGL_HASPMOTA           // HASPmota support
#define USE_DS18x20                 // DS18B20 sensors
#define USE_BME280                  // BME280 sensor
#define USE_DISPLAY                 // Display support
#define USE_BERRY                   // Berry scripting
#define USE_PSRAM                   // PSRAM support
```

### platformio_override.ini

Located in `config/platformio_override.ini`, this file defines:

```ini
[env:tasmota32s3-lvgl]
extends                 = env:tasmota32_base
board                   = esp32s3-qio_qspi
board_build.f_cpu       = 240000000L
board_build.partitions  = partitions/esp32_partition_app2944k_fs1088k.csv

build_flags             = ${env:tasmota32_base.build_flags}
                          -DFIRMWARE_LVGL
                          -DUSE_LVGL
                          -DUSE_LVGL_HASPMOTA
                          -DUSE_DISPLAY
                          -DUSE_BERRY
                          -DUSE_PSRAM
```

## Build Verification

### Check Firmware Size

```bash
ls -lh firmware/tasmota32s3-lvgl-15.0.1.bin
```

Expected size: ~2.5 MB

### Verify Features

```bash
# Check for LVGL
strings firmware/tasmota32s3-lvgl-15.0.1.bin | grep -i lvgl

# Check for HASPmota
strings firmware/tasmota32s3-lvgl-15.0.1.bin | grep -i haspmota

# Check firmware identifier
strings firmware/tasmota32s3-lvgl-15.0.1.bin | grep tasmota32s3-lvgl
```

Expected output:
```
LVGL initialized
HASPmota initialized
tasmota32s3-lvgl
```

### Build Statistics

Typical build results:
```
RAM:   [==        ]  18.9% (used 61892 bytes from 327680 bytes)
Flash: [========= ]  87.8% (used 2588240 bytes from 2949120 bytes)
```

## Troubleshooting

### Build Errors

#### Error: "platformio: command not found"

**Solution**: Activate virtual environment
```bash
source .venv/bin/activate
```

#### Error: "No module named 'platformio'"

**Solution**: Install PlatformIO
```bash
.venv/bin/pip install platformio
```

#### Error: "fatal: not a git repository"

**Solution**: Clone Tasmota repository
```bash
git clone --depth 1 --branch v15.0.1 https://github.com/arendst/Tasmota.git
```

#### Error: "board 'esp32s3-qio_qspi' is unknown"

**Solution**: Update PlatformIO
```bash
.venv/bin/pio upgrade
.venv/bin/pio platform update espressif32
```

### Build Warnings

#### Warning: "user_config_override.h not found"

This is expected if the file is not copied. The build will use default configuration.

**Solution**: Copy configuration file
```bash
cp config/user_config_override.h Tasmota/tasmota/
```

### Memory Issues

#### Error: "region 'iram0_0_seg' overflowed"

**Solution**: Disable unused features in `user_config_override.h`
```c
#undef USE_ZIGBEE
#undef USE_MATTER_DEVICE
#undef USE_HOME_ASSISTANT
```

#### Error: "section '.flash.rodata' will not fit in region 'drom0_0_seg'"

**Solution**: Use minimal build environment
```bash
.venv/bin/pio run -e tasmota32s3-lvgl-minimal
```

## Advanced Configuration

### Custom Partition Scheme

Create custom partition CSV in `Tasmota/partitions/`:

```csv
# Name,   Type, SubType, Offset,  Size,     Flags
nvs,      data, nvs,     0x9000,  0x5000,
otadata,  data, ota,     0xe000,  0x2000,
app0,     app,  ota_0,   0x10000, 0x2E0000,
app1,     app,  ota_1,   0x2F0000,0x2E0000,
spiffs,   data, spiffs,  0x5D0000,0x110000,
```

Reference in `platformio_override.ini`:
```ini
board_build.partitions = partitions/custom_partition.csv
```

### Enable Additional Features

Edit `user_config_override.h`:

```c
// Enable Matter support
#define USE_MATTER_DEVICE

// Enable Zigbee
#define USE_ZIGBEE

// Enable audio
#define USE_I2S_AUDIO
```

### Optimize Build Speed

```bash
# Use multiple cores
.venv/bin/pio run -e tasmota32s3-lvgl -j 4

# Skip dependency check
.venv/bin/pio run -e tasmota32s3-lvgl --disable-auto-clean
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build Tasmota Firmware

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    
    - name: Build firmware
      run: |
        chmod +x scripts/build-lvgl.sh
        ./scripts/build-lvgl.sh
    
    - name: Upload firmware
      uses: actions/upload-artifact@v3
      with:
        name: firmware
        path: firmware/*.bin
```

## Build Optimization Tips

1. **Use shallow clone**: `--depth 1` reduces download time
2. **Cache dependencies**: Reuse `.venv` and `.pio` directories
3. **Parallel builds**: Use `-j` flag with number of CPU cores
4. **Incremental builds**: Don't clean unless necessary
5. **Local mirror**: Clone Tasmota once, reuse for multiple builds

## Next Steps

After successful build:

1. **Flash firmware**: See [Installation Guide](installation.md)
2. **Configure device**: See [Configuration Guide](../README.md#quick-start)
3. **Test features**: See [Testing Guide](testing.md)

## Resources

- [Tasmota Documentation](https://tasmota.github.io/docs/)
- [PlatformIO Documentation](https://docs.platformio.org/)
- [ESP32-S3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
- [LVGL Documentation](https://docs.lvgl.io/)

## Support

- **Issues**: [GitHub Issues](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues)
- **Discussions**: [GitHub Discussions](https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/discussions)
- **Tasmota Support**: [Tasmota Discord](https://discord.gg/Ks2Kzd4)

## License

GPL-3.0 (same as Tasmota)

---

**Last Updated**: 2026-01-12  
**Tasmota Version**: 15.0.1  
**Author**: Harald Kiessling
