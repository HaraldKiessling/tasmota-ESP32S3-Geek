# GPIO Template Configuration Guide

**Board**: Waveshare ESP32-S3 Geek  
**Template**: ESP32S3-Geek with DS18B20 sensors  

---

## Quick Setup

### Console Commands

**Step 1: Apply base template** (sets display GPIOs):
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
```

**Step 2: Configure sensors** (after restart):
```
# DS18x20 temperature sensors only
Backlog gpio6 1312; gpio13 1313; gpio14 1314

# BME280 I2C sensors only
Backlog gpio16 640; gpio17 608

# Both sensor types
Backlog gpio6 1312; gpio13 1313; gpio14 1314; gpio16 640; gpio17 608
```

---

## Template Breakdown

### GPIO Configuration

The base template uses `1` (User) for sensor GPIOs, allowing flexible configuration via `gpio` command:

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0:  User (Boot button)
    0,     // GPIO 1:  None
    0,     // GPIO 2:  None
    0,     // GPIO 3:  None
    0,     // GPIO 4:  None
    0,     // GPIO 5:  None
    1,     // GPIO 6:  User ← configure via: gpio6 1312
    0,     // GPIO 7:  None
    0,     // GPIO 8:  None
    0,     // GPIO 9:  None
    0,     // GPIO 10: None
    0,     // GPIO 11: None
    0,     // GPIO 12: None
    1,     // GPIO 13: User ← configure via: gpio13 1313
    1,     // GPIO 14: User ← configure via: gpio14 1314
    0,     // GPIO 15: None
    1,     // GPIO 16: User ← configure via: gpio16 640
    1,     // GPIO 17: User ← configure via: gpio17 608
    0,     // GPIO 18: None
    0,     // GPIO 19: None (USB D-)
    0,     // GPIO 20: None (USB D+)
    0,     // GPIO 21: None
    8896,  // GPIO 22: SPI CLK (Display) - required
    8960,  // GPIO 23: SPI MOSI (Display) - required
    8800,  // GPIO 24: SPI DC (Display) - required
    8832,  // GPIO 25: SPI CS (Display) - required
    8864,  // GPIO 26: SPI RST (Display) - required
    8928,  // GPIO 27: SPI Backlight (Display) - required
    0,     // GPIO 28: None
    6210,  // GPIO 29: Neopixel
    0,     // GPIO 30: None
    0,     // GPIO 31: None
    3200,  // GPIO 32: Output Hi
    3232,  // GPIO 33: Output Lo
    0,     // GPIO 34: None
    0,     // GPIO 35: None
    0,     // GPIO 36: None
    0      // GPIO 37: None
  ],
  "FLAG": 0,
  "BASE": 1
}
```

---

## Sensor Configuration

### DS18B20 Temperature Sensors

**Configured GPIOs**:
```
GPIO 6:  DS18B20 Sensor #1
GPIO 13: DS18B20 Sensor #2
GPIO 14: DS18B20 Sensor #3
```

**Hardware Requirements**:
- 4.7kΩ pull-up resistor on each GPIO
- Connect to 3.3V, GND, and GPIO
- See [DS18X20_CONFIGURATION.md](../docs/DS18X20_CONFIGURATION.md)

**Verification**:
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

### I2C Sensors

**Configured GPIOs**:
```
GPIO 16: I2C SDA (Data)
GPIO 17: I2C SCL (Clock)
```

**Supported Sensors**:
- BME280: Temperature, Humidity, Pressure
- BME680: Temperature, Humidity, Pressure, Gas
- BMP280: Temperature, Pressure
- SHT3x: Temperature, Humidity
- AHT2x: Temperature, Humidity

**Verification**:
```
I2CScan
```

**Expected Output**:
```json
{
  "I2CScan": "Device(s) found at 0x76 0x77"
}
```

---

## Display Configuration

### Display Pins (Auto-configured)

**Managed by display.ini**:
```
GPIO 7:  Display RST (Reset)
GPIO 8:  Display SCLK (Clock)
GPIO 9:  Display BL (Backlight)
GPIO 10: Display CS (Chip Select)
GPIO 11: Display MOSI (Data)
GPIO 12: Display DC (Data/Command)
```

**Note**: These pins are set to `0` (None) in template because they are managed by the Universal Display Driver via display.ini.

**Display Configuration**:
- Upload `display.ini` to device
- See [DISPLAY_INI_REFERENCE.md](../docs/DISPLAY_INI_REFERENCE.md)

---

## GPIO Function Codes

### Common Functions

| Code | Function | Description |
|------|----------|-------------|
| `0` | None | Pin not used or auto-configured |
| `32` | User | User button/input |
| `608` | I2C SCL | I2C clock line |
| `640` | I2C SDA | I2C data line |
| `1312` | DS18x20-1 | Dallas temperature sensor bus 1 |
| `1313` | DS18x20-2 | Dallas temperature sensor bus 2 |
| `1314` | DS18x20-3 | Dallas temperature sensor bus 3 |
| `3200` | Output Hi | Digital output (high) |
| `3232` | Output Lo | Digital output (low) |
| `6210` | Neopixel | WS2812 RGB LED |
| `8800` | SPI DC | Display Data/Command |
| `8832` | SPI CS | Display Chip Select |
| `8864` | SPI RST | Display Reset |
| `8896` | SPI CLK | Display Clock |
| `8928` | SPI Backlight | Display Backlight |
| `8960` | SPI MOSI | Display Data Out |

### Finding Function Codes

**Console Command**:
```
GPIOs
```

**Output**: Lists all available GPIO functions with codes

---

## Verification

### Step 1: Check GPIO Configuration

**Console Command**:
```
GPIO
```

**Expected Output**:
```
GPIO 0:  User
GPIO 6:  DS18x20
GPIO 13: DS18x20
GPIO 14: DS18x20
GPIO 16: I2C SDA
GPIO 17: I2C SCL
...
```

### Step 2: Check Sensors

**DS18B20 Sensors**:
```
Status 10
```

**I2C Devices**:
```
I2CScan
```

### Step 3: Check Display

**Console Log**:
```
DSP: ST7789 initialized
LVG: LVGL initialized
HSP: HASPmota initialized
```

**Display should show device information**

---

## Customization

### Adding More DS18B20 Sensors

**Option 1: Use Available GPIOs**

Available GPIOs: 1, 2, 3, 4, 5, 15, 18, 21, 22-28, 30, 31

**Example**: Add sensor on GPIO 15
```
GPIO 15 DS18x20
Restart 1
```

**Option 2: Multiple Sensors on One GPIO**

Connect up to 10 sensors on GPIO 6:
```
All sensors share:
- Same GPIO (6)
- Same pull-up resistor (4.7kΩ)
- Parallel connection
```

### Changing I2C Pins

**Not Recommended** - GPIO 16/17 are standard I2C pins

If needed:
```
# Example: Move to GPIO 21/22
GPIO 21 I2C SDA
GPIO 22 I2C SCL
Restart 1
```

### Adding Digital Outputs

**Example**: Control relay on GPIO 22
```
GPIO 22 Relay1
Restart 1
```

**Control**:
```
Power1 On   # Turn on
Power1 Off  # Turn off
Power1 Toggle  # Toggle
```

---

## Sensor Configuration

The base template uses `1` (User) for sensor GPIOs. Configure sensors with `gpio` commands:

### DS18x20 Temperature Sensors

```
Backlog gpio6 1312; gpio13 1313; gpio14 1314
```

### BME280 I2C Sensors

```
Backlog gpio16 640; gpio17 608
```

### Both Sensor Types

```
Backlog gpio6 1312; gpio13 1313; gpio14 1314; gpio16 640; gpio17 608
```

### No Sensors (Display Only)

No additional configuration needed - base template works without sensors.

---

## Troubleshooting

### Template Not Applied

**Symptoms**:
- Display not working
- DisplayModel shows 0

**Solution**:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
```

### Sensors Not Detected

**DS18B20**:
```
# Check GPIO configuration
GPIO

# If DS18x20 not shown, configure:
Backlog gpio6 1312; gpio13 1313; gpio14 1314
```

**BME280**:
```
# If I2C not shown, configure:
Backlog gpio16 640; gpio17 608
```

**I2C**:
```
# Check GPIO configuration
GPIO

# Should show:
# GPIO 16: I2C SDA
# GPIO 17: I2C SCL

# Scan I2C bus
I2CScan
```

### Display Not Working

**Check**:
1. Template applied? (`GPIO` command)
2. display.ini uploaded?
3. Device restarted?

**Solution**:
- See [DISPLAY_FIXED_SOLUTION.md](../DISPLAY_FIXED_SOLUTION.md)

---

## Backup & Restore

### Backup Template

**Console Command**:
```
Template
```

**Output**:
```json
{"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
```

**Save this output!**

### Restore Template

**Paste saved template**:
```
Template <paste_template_here>
Module 0
Restart 1
```

---

## References

### Documentation

- [GPIO_PINOUT.md](../docs/GPIO_PINOUT.md) - Complete GPIO reference
- [DS18X20_CONFIGURATION.md](../docs/DS18X20_CONFIGURATION.md) - DS18B20 setup
- [DISPLAY_INI_REFERENCE.md](../docs/DISPLAY_INI_REFERENCE.md) - Display configuration

### Tasmota Documentation

- [Templates](https://tasmota.github.io/docs/Templates/)
- [GPIO Configuration](https://tasmota.github.io/docs/GPIO-Conversion/)
- [Components](https://tasmota.github.io/docs/Components/)

---

**Last Updated**: 2026-01-12  
**Template Version**: 1.0  
**Board**: ESP32-S3 Geek
