# ESP32-S3 Geek GPIO Pinout & Configuration

**Board**: Waveshare ESP32-S3 Geek  
**MCU**: ESP32-S3-WROOM-1-N16R8  
**Flash**: 16 MB  
**PSRAM**: 8 MB  

---

## GPIO Pin Overview

### Complete Pin Mapping

| GPIO | Function | Tasmota Config | Description | Notes |
|------|----------|----------------|-------------|-------|
| **GPIO 0** | User Button | User (32) | Boot button | Pull-up, active low |
| **GPIO 1** | - | None | Reserved | - |
| **GPIO 2** | - | None | Reserved | - |
| **GPIO 3** | - | None | Reserved | - |
| **GPIO 4** | - | None | Reserved | - |
| **GPIO 5** | - | None | Reserved | - |
| **GPIO 6** | DS18B20 #1 | DS18x20 (1) | Temperature sensor | 1-Wire, 4.7kΩ pull-up |
| **GPIO 7** | Display RST | - | ST7789 Reset | Display control |
| **GPIO 8** | Display SCLK | - | ST7789 Clock | SPI clock |
| **GPIO 9** | Display BL | - | ST7789 Backlight | PWM capable |
| **GPIO 10** | Display CS | - | ST7789 Chip Select | SPI CS |
| **GPIO 11** | Display MOSI | - | ST7789 Data | SPI MOSI |
| **GPIO 12** | Display DC | - | ST7789 Data/Cmd | Display control |
| **GPIO 13** | DS18B20 #2 | User (1) | Temperature sensor | 1-Wire, 4.7kΩ pull-up |
| **GPIO 14** | DS18B20 #3 | User (1) | Temperature sensor | 1-Wire, 4.7kΩ pull-up |
| **GPIO 15** | - | None | Reserved | - |
| **GPIO 16** | I2C SDA | I2C SDA (640) | I2C Data | BME280, etc. |
| **GPIO 17** | I2C SCL | I2C SCL (608) | I2C Clock | BME280, etc. |
| **GPIO 18** | - | None | Reserved | - |
| **GPIO 19** | USB D- | - | USB Data | USB CDC |
| **GPIO 20** | USB D+ | - | USB Data | USB CDC |
| **GPIO 21** | - | None | Reserved | - |
| **GPIO 22** | SPI CLK | SPI CLK (8896) | ST7789 Display | Required |
| **GPIO 23** | SPI MOSI | SPI MOSI (8960) | ST7789 Display | Required |
| **GPIO 24** | SPI DC | SPI DC (8800) | ST7789 Display | Required |
| **GPIO 25** | SPI CS | SPI CS (8832) | ST7789 Display | Required |
| **GPIO 26** | SPI RST | SPI RST (8864) | ST7789 Display | Required |
| **GPIO 27** | SPI BL | SPI Backlight (8928) | ST7789 Display | Required |
| **GPIO 28** | - | None | Reserved | - |
| **GPIO 29** | - | TuyaSend (6210) | User defined | - |
| **GPIO 30** | - | None | Reserved | - |
| **GPIO 31** | - | None | Reserved | - |
| **GPIO 32** | - | Output Hi (3200) | User output | - |
| **GPIO 33** | - | Output Lo (3232) | User output | - |
| **GPIO 34-37** | - | None | Reserved | - |

---

## Display Pins (ST7789)

### Pin Configuration

```
ST7789 TFT Display (240x135 pixels)
├── CS   (Chip Select):    GPIO 10
├── DC   (Data/Command):   GPIO 12
├── MOSI (Data Out):       GPIO 11
├── SCLK (Clock):          GPIO 8
├── RST  (Reset):          GPIO 7
└── BL   (Backlight):      GPIO 9
```

### SPI Configuration

- **SPI Bus**: HSPI (SPI2)
- **Mode**: SPI Mode 0
- **Frequency**: 40 MHz
- **Bit Order**: MSB First

### Display Specifications

- **Controller**: ST7789V
- **Resolution**: 240 x 135 pixels
- **Color Depth**: 16-bit (RGB565)
- **Interface**: 4-wire SPI
- **Backlight**: PWM controlled via GPIO 9

---

## DS18B20 Temperature Sensors

### Pin Configuration

```
DS18B20 Sensors (1-Wire Protocol)
├── Sensor #1: GPIO 6
├── Sensor #2: GPIO 13
└── Sensor #3: GPIO 14
```

### Hardware Requirements

**Pull-up Resistor**: 4.7kΩ required on each GPIO!

```
        3.3V
         |
        4.7kΩ
         |
GPIO ----+---- DS18B20 Data
         |
        GND
```

### Wiring Diagram

```
DS18B20 Pinout (TO-92 Package):
  ___
 /   \
|  1  |  1 = GND
|  2  |  2 = Data (to GPIO)
|  3  |  3 = VDD (3.3V)
 \___/
```

### Connection Example

**Sensor #1 (GPIO 6)**:
```
ESP32-S3          DS18B20
GPIO 6  --------> Data (Pin 2)
3.3V    --------> VDD  (Pin 3)
GND     --------> GND  (Pin 1)
         |
        4.7kΩ to 3.3V
```

### Multiple Sensors

All DS18B20 sensors can share the same GPIO (1-Wire bus):

**Option A: All on one GPIO**:
```
GPIO 6 ----+---- DS18B20 #1 Data
           |
           +---- DS18B20 #2 Data
           |
           +---- DS18B20 #3 Data
           |
          4.7kΩ to 3.3V
```

**Option B: Separate GPIOs** (current configuration):
```
GPIO 6  ---- DS18B20 #1 (with 4.7kΩ pull-up)
GPIO 13 ---- DS18B20 #2 (with 4.7kΩ pull-up)
GPIO 14 ---- DS18B20 #3 (with 4.7kΩ pull-up)
```

### Sensor Identification

Each DS18B20 has a unique 64-bit ROM code:

```
Example IDs:
- Sensor #1: 0000005329E2
- Sensor #2: 00000051C76D
- Sensor #3: 28XXXXXXXXXXXXXX
```

### Tasmota Configuration

**Console Commands**:
```
# Enable DS18B20 on GPIO 6, 13, 14
GPIO 6 DS18x20
GPIO 13 DS18x20
GPIO 14 DS18x20

# Or use template (see below)
```

**Reading Sensors**:
```
# Check sensor status
Status 10

# Output example:
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

---

## I2C Bus

### Pin Configuration

```
I2C Bus (for BME280, BME680, etc.)
├── SDA (Data):  GPIO 16
└── SCL (Clock): GPIO 17
```

### I2C Specifications

- **Speed**: 100 kHz (Standard) or 400 kHz (Fast)
- **Pull-ups**: Internal pull-ups enabled
- **Voltage**: 3.3V
- **Max Devices**: Multiple devices on same bus

### Supported Sensors

**Environmental Sensors**:
- BME280: Temperature, Humidity, Pressure
- BME680: Temperature, Humidity, Pressure, Gas
- BMP280: Temperature, Pressure
- SHT3x: Temperature, Humidity
- AHT2x: Temperature, Humidity

**Other Sensors**:
- VEML6070: UV sensor
- BH1750: Light sensor
- Various I2C displays

### I2C Scan

**Console Command**:
```
I2CScan

# Output example:
{
  "I2CScan": "Device(s) found at 0x76 0x77"
}
```

**Common I2C Addresses**:
- BME280: 0x76 or 0x77
- BME680: 0x76 or 0x77
- BMP280: 0x76 or 0x77

---

## USB Interface

### Pin Configuration

```
USB CDC (Console/Programming)
├── D-: GPIO 19
└── D+: GPIO 20
```

### Features

- **USB CDC**: Serial console over USB
- **Programming**: Direct firmware upload
- **Debugging**: Serial monitor
- **Speed**: 115200 baud (fixed)

---

## Power Pins

### Power Supply

```
Power Configuration
├── VIN:  5V input (USB or external)
├── 3V3:  3.3V regulated output
├── GND:  Ground
└── VBAT: Battery input (optional)
```

### Power Specifications

- **Input Voltage**: 5V via USB or VIN
- **3.3V Output**: Max 500mA
- **Battery**: 3.7V LiPo (optional)
- **Charging**: Built-in charger (if battery connected)

---

## Tasmota GPIO Template

### Complete Template

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
    1,     // GPIO 6:  User (DS18x20 via gpio command)
    0,     // GPIO 7:  None
    0,     // GPIO 8:  None
    0,     // GPIO 9:  None
    0,     // GPIO 10: None
    0,     // GPIO 11: None
    0,     // GPIO 12: None
    1,     // GPIO 13: User (DS18x20 via gpio command)
    1,     // GPIO 14: User (DS18x20 via gpio command)
    0,     // GPIO 15: None
    1,     // GPIO 16: User (I2C SDA via gpio command)
    1,     // GPIO 17: User (I2C SCL via gpio command)
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

### Console Commands

**Apply base template** (sets display GPIOs):
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
```

**Configure sensors** (after template restart):
```
# DS18x20 only
Backlog gpio6 1312; gpio13 1313; gpio14 1314

# BME280 I2C only
Backlog gpio16 640; gpio17 608

# Both sensor types
Backlog gpio6 1312; gpio13 1313; gpio14 1314; gpio16 640; gpio17 608
```

### GPIO Function Codes

| Code | Function | Description |
|------|----------|-------------|
| 0 | None | Pin not used |
| 32 | User | User button/input |
| 608 | I2C SCL | I2C clock line |
| 640 | I2C SDA | I2C data line |
| 1312 | DS18x20-1 | Dallas temperature sensor bus 1 |
| 1313 | DS18x20-2 | Dallas temperature sensor bus 2 |
| 1314 | DS18x20-3 | Dallas temperature sensor bus 3 |
| 3200 | Output Hi | Digital output (high) |
| 3232 | Output Lo | Digital output (low) |
| 6210 | Neopixel | WS2812 RGB LED |
| 8800 | SPI DC | Display Data/Command |
| 8832 | SPI CS | Display Chip Select |
| 8864 | SPI RST | Display Reset |
| 8896 | SPI CLK | Display Clock |
| 8928 | SPI Backlight | Display Backlight |
| 8960 | SPI MOSI | Display Data Out |

---

## Pin Usage Guidelines

### Reserved Pins

**Do NOT use these pins**:
- GPIO 19, 20: USB interface
- GPIO 7-12: Display interface (managed by display.ini)

### Safe to Use

**Available for sensors/peripherals**:
- GPIO 6, 13, 14: DS18B20 (configured)
- GPIO 16, 17: I2C (configured)
- GPIO 22-27: User-defined
- GPIO 32, 33: Digital outputs

### Pull-up/Pull-down

**Internal Pull-ups**:
- GPIO 0: Built-in pull-up (boot button)
- I2C pins: Internal pull-ups enabled

**External Pull-ups Required**:
- DS18B20: 4.7kΩ to 3.3V on each GPIO

---

## Hardware Modifications

### Adding DS18B20 Sensors

**Required Components**:
- DS18B20 sensor (TO-92 or waterproof)
- 4.7kΩ resistor (per GPIO)
- Wires

**Connection Steps**:
1. Connect DS18B20 GND to ESP32 GND
2. Connect DS18B20 VDD to ESP32 3.3V
3. Connect DS18B20 Data to GPIO (6, 13, or 14)
4. Add 4.7kΩ resistor between Data and 3.3V
5. Apply GPIO template in Tasmota
6. Verify with `Status 10`

### Adding I2C Sensors

**Example: BME280**:
1. Connect BME280 VCC to ESP32 3.3V
2. Connect BME280 GND to ESP32 GND
3. Connect BME280 SDA to GPIO 16
4. Connect BME280 SCL to GPIO 17
5. Run `I2CScan` to verify
6. Sensor auto-detected by Tasmota

---

## Troubleshooting

### DS18B20 Not Detected

**Check**:
- 4.7kΩ pull-up resistor present?
- Correct wiring (VDD, GND, Data)?
- GPIO configured in template?
- Sensor working? (test with multimeter)

**Console Commands**:
```
# Check GPIO configuration
GPIO

# Check sensor status
Status 10

# Enable debug logging
SerialLog 4
WebLog 4
```

### I2C Device Not Found

**Check**:
- Correct I2C address?
- SDA/SCL wiring correct?
- Sensor powered (3.3V)?
- Run I2CScan

**Console Commands**:
```
# Scan I2C bus
I2CScan

# Check I2C configuration
I2CDriver
```

### Display Not Working

**Check**:
- display.ini uploaded?
- Correct display.ini for your version?
- GPIO template applied?
- See [DISPLAY_FIXED_SOLUTION.md](../DISPLAY_FIXED_SOLUTION.md)

---

## References

### Datasheets

- [ESP32-S3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
- [ST7789 Display Controller](https://www.waveshare.com/wiki/ESP32-S3-Geek)
- [DS18B20 Temperature Sensor](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)
- [BME280 Sensor](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bme280-ds002.pdf)

### Tasmota Documentation

- [GPIO Configuration](https://tasmota.github.io/docs/GPIO-Conversion/)
- [DS18x20 Sensors](https://tasmota.github.io/docs/DS18x20/)
- [I2C Devices](https://tasmota.github.io/docs/I2CDEVICES/)
- [Templates](https://tasmota.github.io/docs/Templates/)

---

**Last Updated**: 2026-01-12  
**Board**: Waveshare ESP32-S3 Geek  
**Tasmota**: 15.2.0
