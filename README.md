# Tasmota ESP32S3-Geek

Custom Tasmota firmware for Waveshare ESP32S3-Geek with ST7789 display, DS18B20 sensors, and I2C support.

![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Tasmota](https://img.shields.io/badge/Tasmota-15.0.1-orange)

---

## Quick Start

### 1. Flash Firmware

Download and flash the firmware:
- [tasmota32s3-lvgl-15.0.1.bin](firmware/tasmota32s3-lvgl-15.0.1.bin) (Recommended)
- [tasmota32s3-lvgl-15.2.0-fixed.bin](firmware/tasmota32s3-lvgl-15.2.0-fixed.bin) (Experimental)

### 2. Apply GPIO Template

Open Tasmota console and paste:

```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
Restart 1
```

### 3. Upload Display Configuration

Upload `autoconf/display.ini` to the device filesystem.

### 4. Connect Sensors

**DS18B20 Temperature Sensors**:
- GPIO 6, 13, 14 (with 4.7kΩ pull-up resistor)

**I2C Sensors** (BME280, etc.):
- GPIO 16 (SDA), GPIO 17 (SCL)

---

## Features

✅ **DS18B20 Temperature Sensors** - Up to 3 sensors on GPIO 6, 13, 14  
✅ **I2C Support** - BME280, BME680, BMP280, SHT3x, AHT2x  
✅ **ST7789 Display** - 240x135 TFT with HASPmota  
✅ **LVGL 9.4.0** - Modern UI framework  
✅ **MQTT Integration** - Real-time telemetry  
✅ **Berry Scripting** - Custom automation  

---

## Hardware

**Board**: Waveshare ESP32-S3 Geek  
**Display**: ST7789 240x135 TFT  
**MCU**: ESP32-S3-WROOM-1-N4R2  
**Flash**: 4 MB  
**PSRAM**: 2 MB  

### GPIO Configuration

| GPIO | Function | Description |
|------|----------|-------------|
| 0 | User | Boot button |
| 6 | DS18x20-1 | Temperature sensor #1 |
| 7-12 | Display | ST7789 (auto-configured) |
| 13 | DS18x20-1 | Temperature sensor #2 |
| 14 | DS18x20-1 | Temperature sensor #3 |
| 16 | I2C SDA | I2C data line |
| 17 | I2C SCL | I2C clock line |

See [GPIO_PINOUT.md](docs/GPIO_PINOUT.md) for complete pin mapping.

---

## Documentation

### Hardware Setup
- [GPIO Pin Mapping](docs/GPIO_PINOUT.md) - Complete GPIO reference
- [DS18B20 Configuration](docs/DS18X20_CONFIGURATION.md) - Temperature sensor setup
- [Display Configuration](docs/DISPLAY_INI_REFERENCE.md) - ST7789 display.ini reference
- [Hardware Overview](docs/HARDWARE.md) - Board specifications

### Configuration
- [Template Guide](config/TEMPLATE_GUIDE.md) - GPIO template with examples
- [Template JSON](config/template-with-ds18x20.json) - Ready-to-use template

### Firmware
- [Build Guide](docs/BUILD_GUIDE.md) - Build custom firmware
- [Installation Guide](docs/INSTALLATION.md) - Flash and configure
- [Firmware Update](docs/FIRMWARE_UPDATE_GUIDE.md) - OTA updates

---

## GPIO Template

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0:  User (Boot button)
    0,     // GPIO 1-5: None
    1312,  // GPIO 6:  DS18x20-1 (Temperature sensor #1)
    0,     // GPIO 7-12: Display (auto-configured)
    1312,  // GPIO 13: DS18x20-1 (Temperature sensor #2)
    1312,  // GPIO 14: DS18x20-1 (Temperature sensor #3)
    0,     // GPIO 15: None
    640,   // GPIO 16: I2C SDA
    608,   // GPIO 17: I2C SCL
    0,     // GPIO 18-21: None
    8896,  // GPIO 22: Option A1
    8960,  // GPIO 23: Option A2
    8800,  // GPIO 24: Option A3
    8832,  // GPIO 25: Option A4
    8864,  // GPIO 26: Option A5
    8928,  // GPIO 27: Option A6
    0,     // GPIO 28: None
    6210,  // GPIO 29: TuyaSend
    0,     // GPIO 30-31: None
    3200,  // GPIO 32: Output Hi
    3232,  // GPIO 33: Output Lo
    0      // GPIO 34-37: None
  ],
  "FLAG": 0,
  "BASE": 1
}
```

**Console Command**:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
```

---

## DS18B20 Sensor Setup

### Hardware Wiring

```
DS18B20 Sensor → ESP32S3-Geek
─────────────────────────────
VDD (Red)      → 3.3V
GND (Black)    → GND
DATA (Yellow)  → GPIO 6/13/14
                 ↓
              4.7kΩ pull-up to 3.3V
```

### Multiple Sensors

Connect up to 3 sensors on separate GPIOs (6, 13, 14) or up to 10 sensors on a single GPIO using 1-Wire bus.

### Verification

```
Status 10
```

**Expected Output**:
```json
{
  "DS18B20-5329E2": {
    "Id": "0000005329E2",
    "Temperature": 23.1
  },
  "DS18B20-51C76D": {
    "Id": "00000051C76D",
    "Temperature": 24.6
  }
}
```

See [DS18X20_CONFIGURATION.md](docs/DS18X20_CONFIGURATION.md) for detailed setup.

---

## Display Configuration

The ST7789 display is configured via `display.ini`:

```ini
:H,ST7789,240,135,16,SPI,1,*,*,*,*,*,*,*,40
:S,2,1,1,0,40,20
:I
EF,3,03,80,02
CF,3,00,C1,30
ED,4,64,03,12,81
E8,3,85,00,78
CB,5,39,2C,00,34,02
F7,1,20
EA,2,00,00
C0,1,23
C1,1,10
C5,2,3e,28
C7,1,86
36,1,48
3A,1,55
B1,2,00,18
B6,3,08,82,27
F2,1,00
26,1,01
E0,0F,0F,31,2B,0C,0E,08,4E,F1,37,07,10,03,0E,09,00
E1,0F,00,0E,14,03,11,07,31,C1,48,08,0F,0C,31,36,0F
21,0
11,80,78
29,80,78
:o,48
:A,28,34,28,86
:R,00,00,87,00,00,28,00,87
#
```

Upload via Tasmota web interface: **Consoles → Manage File System → Upload**

See [DISPLAY_INI_REFERENCE.md](docs/DISPLAY_INI_REFERENCE.md) for detailed explanation.

---

## Firmware Versions

### v15.0.1 (Recommended)
- **File**: tasmota32s3-lvgl-15.0.1.bin
- **Size**: 2.5 MB (87.8% flash)
- **Filesystem**: 1088 KB
- **Status**: ✅ Production Ready
- **Features**: LVGL 9.4.0, HASPmota, stable configuration

### v15.2.0-fixed (Experimental)
- **File**: tasmota32s3-lvgl-15.2.0-fixed.bin
- **Size**: 2.6 MB (90.3% flash)
- **Filesystem**: 320 KB
- **Status**: ⚠️ Experimental
- **Features**: Extension Manager, Matter support, requires exact configuration

---

## MQTT Integration

### Configuration

```
Backlog Topic esp32s3-geek; DeviceName ESP32S3-Geek; FriendlyName1 Geek
TelePeriod 60
```

### Topics

```
stat/esp32s3-geek/STATUS10    # Sensor data
tele/esp32s3-geek/SENSOR      # Telemetry
cmnd/esp32s3-geek/Power1      # Commands
```

### Example Payload

```json
{
  "Time": "2026-01-12T23:45:00",
  "DS18B20-5329E2": {
    "Id": "0000005329E2",
    "Temperature": 23.1
  },
  "TempUnit": "C"
}
```

---

## Berry Scripts

### Automatic Display Updates

Create `autoexec.be`:

```berry
import mqtt

def update_display()
  var sensors = tasmota.read_sensors()
  if sensors.contains("DS18B20")
    for key: sensors.keys()
      if key.startswith("DS18B20")
        var temp = sensors[key]["Temperature"]
        print(f"Sensor {key}: {temp}°C")
      end
    end
  end
end

tasmota.add_cron("*/2 * * * * *", update_display, "display_update")
```

See [DS18X20_CONFIGURATION.md](docs/DS18X20_CONFIGURATION.md) for more examples.

---

## Troubleshooting

### Sensors Not Detected

**Check GPIO configuration**:
```
GPIO
```

Should show:
```
GPIO 6:  DS18x20
GPIO 13: DS18x20
GPIO 14: DS18x20
```

**If not, reapply template**:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1312,1312,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
Restart 1
```

### Display Not Working

1. Check template applied: `GPIO`
2. Verify display.ini uploaded
3. Restart device: `Restart 1`
4. Check console for initialization messages

### I2C Devices Not Found

**Scan I2C bus**:
```
I2CScan
```

**Expected output**:
```json
{
  "I2CScan": "Device(s) found at 0x76 0x77"
}
```

---

## Build from Source

### Prerequisites

```bash
sudo apt-get install -y git python3 python3-pip python3-venv
```

### Clone and Build

```bash
git clone https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek.git
cd tasmota-ESP32S3-Geek
python3 -m venv .venv
source .venv/bin/activate
pip install -U platformio
cd Tasmota
platformio run -e tasmota32s3-lvgl
```

**Output**: `Tasmota/.pio/build/tasmota32s3-lvgl/firmware.bin`

See [BUILD_GUIDE.md](docs/BUILD_GUIDE.md) for detailed instructions.

---

## Project Structure

```
tasmota-ESP32S3-Geek/
├── README.md                          # This file
├── autoconf/
│   └── display.ini                    # Display configuration
├── config/
│   ├── TEMPLATE_GUIDE.md              # Template documentation
│   └── template-with-ds18x20.json     # GPIO template
├── docs/
│   ├── GPIO_PINOUT.md                 # GPIO reference
│   ├── DS18X20_CONFIGURATION.md       # Sensor setup
│   ├── DISPLAY_INI_REFERENCE.md       # Display reference
│   ├── HARDWARE.md                    # Hardware specs
│   ├── BUILD_GUIDE.md                 # Build instructions
│   ├── INSTALLATION.md                # Installation guide
│   └── FIRMWARE_UPDATE_GUIDE.md       # Update guide
├── firmware/
│   ├── tasmota32s3-lvgl-15.0.1.bin    # Stable firmware
│   └── tasmota32s3-lvgl-15.2.0-fixed.bin  # Experimental
└── Tasmota/                           # Tasmota source code
```

---

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

---

## License

This project uses Tasmota firmware which is licensed under GPL-3.0.

---

## References

- [Tasmota Documentation](https://tasmota.github.io/docs/)
- [Waveshare ESP32-S3 Geek](https://www.waveshare.com/wiki/ESP32-S3-Geek)
- [DS18B20 Datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/DS18B20.pdf)
- [ST7789 Datasheet](https://www.displayfuture.com/Display/datasheet/controller/ST7789.pdf)

---

**Last Updated**: 2026-01-12  
**Version**: 1.0  
**Maintainer**: Harald Kiessling
