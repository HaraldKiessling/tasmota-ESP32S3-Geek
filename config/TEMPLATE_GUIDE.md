# GPIO Template Configuration Guide

**Board**: Waveshare ESP32-S3 Geek  
**Template**: ESP32S3-Geek with DS18B20 sensors  

---

## Quick Setup

### Console Command

Copy and paste this command into the Tasmota console:

```
Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; Restart 1
```

**Wait 30 seconds for restart**

---

## Template Breakdown

### GPIO Configuration

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
    1312,  // GPIO 6:  DS18x20 ← Temperature Sensor #1
    0,     // GPIO 7:  None (Display RST - auto)
    0,     // GPIO 8:  None (Display SCLK - auto)
    0,     // GPIO 9:  None (Display BL - auto)
    0,     // GPIO 10: None (Display CS - auto)
    0,     // GPIO 11: None (Display MOSI - auto)
    0,     // GPIO 12: None (Display DC - auto)
    1312,  // GPIO 13: DS18x20 ← Temperature Sensor #2
    1312,  // GPIO 14: DS18x20 ← Temperature Sensor #3
    0,     // GPIO 15: None
    640,   // GPIO 16: I2C SDA ← BME280, etc.
    608,   // GPIO 17: I2C SCL ← BME280, etc.
    0,     // GPIO 18: None
    0,     // GPIO 19: None (USB D-)
    0,     // GPIO 20: None (USB D+)
    0,     // GPIO 21: None
    8896,  // GPIO 22: Option A1
    8960,  // GPIO 23: Option A2
    8800,  // GPIO 24: Option A3
    8832,  // GPIO 25: Option A4
    8864,  // GPIO 26: Option A5
    8928,  // GPIO 27: Option A6
    0,     // GPIO 28: None
    6210,  // GPIO 29: TuyaSend
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
| `1` | DS18x20 | Dallas temperature sensor (generic) |
| `1312` | DS18x20-1 | Dallas temperature sensor (direct) |
| `32` | User | User button/input |
| `608` | I2C SCL | I2C clock line |
| `640` | I2C SDA | I2C data line |
| `3200` | Output Hi | Digital output (high) |
| `3232` | Output Lo | Digital output (low) |
| `6210` | TuyaSend | Tuya protocol |
| `8800` | Option A3 | User-defined option |
| `8832` | Option A4 | User-defined option |
| `8864` | Option A5 | User-defined option |
| `8896` | Option A1 | User-defined option |
| `8928` | Option A6 | User-defined option |
| `8960` | Option A2 | User-defined option |

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

## Template Variants

### Minimal (Display Only)

```
Backlog Template {"NAME":"ESP32S3-Geek-Min","GPIO":[32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; Restart 1
```

**Features**:
- Display only
- No sensors
- Minimal configuration

### With I2C Only

```
Backlog Template {"NAME":"ESP32S3-Geek-I2C","GPIO":[32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,640,608,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; Restart 1
```

**Features**:
- Display
- I2C sensors (BME280, etc.)
- No DS18B20

### Full Configuration (Current)

```
Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; Restart 1
```

**Features**:
- Display
- 3x DS18B20 sensors (separate buses: 1312, 1313, 1314)
- I2C sensors
- User-defined options

---

## Troubleshooting

### Template Not Applied

**Symptoms**:
- GPIO command shows wrong configuration
- Sensors not detected

**Solution**:
```
Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1312,0,0,0,0,0,0,1313,1314,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; Restart 1
```

### Sensors Not Detected

**DS18B20**:
```
# Check GPIO configuration
GPIO

# Should show:
# GPIO 6:  DS18x20
# GPIO 13: DS18x20
# GPIO 14: DS18x20

# If not, reapply template
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
