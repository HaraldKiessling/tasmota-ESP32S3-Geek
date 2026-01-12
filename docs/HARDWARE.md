# Hardware Documentation - ESP32S3-Geek

Complete hardware specification and pinout for Waveshare ESP32S3-Geek stick.

**📚 Related Documentation**:
- [GPIO_PINOUT.md](GPIO_PINOUT.md) - Complete GPIO pin mapping with detailed descriptions
- [DS18X20_CONFIGURATION.md](DS18X20_CONFIGURATION.md) - DS18B20 temperature sensor configuration
- [DISPLAY_INI_REFERENCE.md](DISPLAY_INI_REFERENCE.md) - Display configuration reference
- [TEMPLATE_GUIDE.md](../config/TEMPLATE_GUIDE.md) - GPIO template configuration guide

## Board Specifications

### Waveshare ESP32S3-Geek

- **MCU**: ESP32-S3-WROOM-1-N16R8
- **CPU**: Dual-core Xtensa LX7 @ 240 MHz
- **Flash**: 16 MB
- **PSRAM**: 8 MB
- **WiFi**: 802.11 b/g/n (2.4 GHz)
- **Bluetooth**: BLE 5.0
- **USB**: USB-C (native USB support)
- **Display**: ST7789 240x135 TFT
- **Size**: Stick form factor

## GPIO Pinout

### Verified and Tested Pins

| GPIO | Function | Type | Notes |
|------|----------|------|-------|
| 0 | Button | Input | Boot button |
| 6 | DS18x20 | 1-Wire | DS18B20 temperature sensor |
| 13 | DS18x20 | 1-Wire | DS18B20 temperature sensor (tested) |
| 14 | DS18x20 | 1-Wire | DS18B20 temperature sensor |
| 16 | I2C SDA | I2C | For BME280, etc. |
| 17 | I2C SCL | I2C | For BME280, etc. |
| 43 | UART TX | UART | Serial transmit |
| 44 | UART RX | UART | Serial receive |

### Display Pins (Internal)

Configured via display.ini, not directly accessible:

| GPIO | Function | Notes |
|------|----------|-------|
| 3 | SPI CS | Display chip select |
| 7 | ? | Display related |
| 8 | SPI RST | Display reset |
| 9 | ? | Display related |
| 10 | SPI DC | Display data/command |
| 11 | SPI CLK | Display clock |
| 12 | SPI MOSI | Display data |
| 30 | Backlight | Display backlight PWM |

### Reserved/Internal Pins

| GPIO | Function | Notes |
|------|----------|-------|
| 19-20 | USB | USB D- and D+ |
| 26-32 | PSRAM | PSRAM interface (octal) |
| 33-37 | Flash | Flash interface (quad) |

## Sensor Connections

### DS18B20 Temperature Sensor

**Pinout:**
```
DS18B20
┌─────┐
│ 1 2 3│
└─────┘
  │ │ │
  │ │ └─ VCC (3.3V)
  │ └─── Data (GPIO 6, 13, or 14)
  └───── GND
```

**Wiring:**
- Pin 1 (GND) → GND
- Pin 2 (Data) → GPIO 6, 13, or 14
- Pin 3 (VCC) → 3.3V
- **Pull-up resistor**: 4.7kΩ between Data and VCC

**Multiple Sensors:**
- Connect all sensors in parallel to same GPIO
- Each sensor has unique 64-bit ID
- Up to 10 sensors per GPIO recommended
- Can use GPIO 6, 13, and 14 simultaneously (30 sensors total)

**Tested Configuration:**
- 2 sensors on GPIO 13
- Both detected and working
- IDs: 0000005329E2, 00000051C76D

### BME280 Environmental Sensor

**I2C Connection:**
```
BME280
┌──────┐
│VCC GND│
│SCL SDA│
└──────┘
  │   │
  │   └─ GPIO 16 (SDA)
  └───── GPIO 17 (SCL)
```

**Wiring:**
- VCC → 3.3V
- GND → GND
- SCL → GPIO 17
- SDA → GPIO 16

**I2C Addresses:**
- Default: 0x76 or 0x77
- Can connect 2 sensors with different addresses
- Pull-up resistors usually on module

**Not Tested:**
- Configuration verified
- No BME280 sensors available for testing
- Should work based on I2C configuration

## Display

### ST7789 TFT Display

**Specifications:**
- Resolution: 240x135 pixels
- Colors: 65K (16-bit)
- Interface: SPI
- Driver: ST7789
- Backlight: PWM controlled

**Configuration:**
- Configured via `display.ini`
- Universal Display Driver
- Automatic initialization on boot
- HASPmota support

**Display Initialization:**
```
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
```

Parameters:
- Model: ST7789
- Size: 135x240
- Color depth: 16-bit
- Interface: SPI
- GPIOs: 3,10,12,11,8,7,9 (CS,DC,MOSI,CLK,RST,etc.)
- Backlight: GPIO 30

## Power

### Power Supply

- **Input**: USB-C 5V
- **Consumption**: ~200-300 mA typical
- **Peak**: ~500 mA (WiFi transmit)

### Power Pins

- **3.3V**: Available for sensors
- **GND**: Multiple ground pins
- **5V**: USB voltage (not regulated)

**Sensor Power Budget:**
- DS18B20: ~1 mA per sensor
- BME280: ~3.6 µA (sleep) to 714 µA (active)
- Total available: ~500 mA from 3.3V regulator

## GPIO Configuration in Tasmota

### Template (v7)

```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,    // GPIO 0: Button
    1,     // GPIO 1-5: User
    1312,  // GPIO 6: DS18x20
    1,     // GPIO 7-12: User
    1312,  // GPIO 13: DS18x20
    1312,  // GPIO 14: DS18x20
    1,     // GPIO 15: User
    640,   // GPIO 16: I2C SDA
    608,   // GPIO 17: I2C SCL
    1,     // GPIO 18-20: User
    3840,  // GPIO 21: Output Hi
    6210,  // GPIO 22: Option A
    0,     // GPIO 23-31: None
    1,     // GPIO 32-33: User
    0,     // GPIO 34-37: None
    1,     // GPIO 38-42: User
    3200,  // GPIO 43: Serial Tx
    3232   // GPIO 44: Serial Rx
  ]
}
```

### GPIO Function Codes

| Code | Function | Description |
|------|----------|-------------|
| 0 | None | Not used |
| 1 | User | Available for user |
| 32 | Button | Physical button |
| 608 | I2C SCL | I2C clock |
| 640 | I2C SDA | I2C data |
| 1312 | DS18x20 | 1-Wire temperature sensor |
| 3200 | Serial Tx | UART transmit |
| 3232 | Serial Rx | UART receive |
| 3840 | Output Hi | Digital output (high) |
| 4864 | ADC Range | Analog input |
| 6210 | Option A | Special function |

## Wiring Examples

### Example 1: 2 DS18B20 Sensors

```
ESP32S3-Geek          DS18B20 #1        DS18B20 #2
┌──────────┐          ┌────────┐        ┌────────┐
│          │          │  1 2 3 │        │  1 2 3 │
│ GPIO 13 ─┼──────────┼────┼───┼────────┼────┼───┤
│          │          │    │   │        │    │   │
│ 3.3V ────┼──────────┼────┼───┼────────┼────┼───┤
│          │          │    │   │        │    │   │
│ GND ─────┼──────────┼────┘   │        │    │   │
│          │          │        │        │    │   │
└──────────┘          └────────┘        └────────┘
                           │                 │
                           └─────4.7kΩ──────┘
                                  │
                                3.3V
```

### Example 2: DS18B20 + BME280

```
ESP32S3-Geek          DS18B20           BME280
┌──────────┐          ┌────────┐        ┌────────┐
│          │          │  1 2 3 │        │VCC  GND│
│ GPIO 13 ─┼──────────┼────┼───┤        │        │
│          │          │    │   │        │        │
│ GPIO 16 ─┼──────────┼────┼───┼────────┤SDA     │
│ GPIO 17 ─┼──────────┼────┼───┼────────┤SCL     │
│          │          │    │   │        │        │
│ 3.3V ────┼──────────┼────┼───┼────────┤VCC     │
│ GND ─────┼──────────┼────┘   └────────┤GND     │
│          │          │                 │        │
└──────────┘          └────────┘        └────────┘
                           │
                           └─────4.7kΩ──────3.3V
```

### Example 3: Multiple DS18B20 on Different GPIOs

```
ESP32S3-Geek
┌──────────┐
│          │
│ GPIO 6  ─┼──── DS18B20 #1, #2, #3 (with 4.7kΩ pull-up)
│          │
│ GPIO 13 ─┼──── DS18B20 #4, #5, #6 (with 4.7kΩ pull-up)
│          │
│ GPIO 14 ─┼──── DS18B20 #7, #8, #9 (with 4.7kΩ pull-up)
│          │
│ 3.3V ────┼──── All VCC pins
│ GND ─────┼──── All GND pins
│          │
└──────────┘
```

## Troubleshooting

### Sensor Not Detected

1. **Check wiring**:
   - VCC to 3.3V (not 5V!)
   - GND to GND
   - Data to correct GPIO

2. **Check pull-up resistor**:
   - 4.7kΩ between Data and VCC
   - Required for DS18B20

3. **Check GPIO configuration**:
   - GPIO 6, 13, or 14 set to DS18x20 (1312)
   - Verify with: `Template` command

4. **Check sensor**:
   - Test with multimeter
   - Verify 3.3V on VCC pin
   - Check continuity

### Multiple Sensors Not Working

1. **Check parallel wiring**:
   - All Data pins connected together
   - All VCC pins connected together
   - All GND pins connected together

2. **Check pull-up resistor**:
   - One 4.7kΩ resistor per GPIO
   - Between Data and VCC

3. **Check power**:
   - Too many sensors can exceed power budget
   - Try fewer sensors first

### I2C Not Working

1. **Check I2C address**:
   - Scan with: `I2CScan` command
   - BME280 usually 0x76 or 0x77

2. **Check wiring**:
   - SDA to GPIO 16
   - SCL to GPIO 17
   - VCC to 3.3V
   - GND to GND

3. **Check pull-up resistors**:
   - Usually on sensor module
   - 4.7kΩ to 10kΩ typical

## Specifications Summary

| Feature | Specification |
|---------|--------------|
| MCU | ESP32-S3 |
| Flash | 16 MB |
| PSRAM | 8 MB |
| WiFi | 2.4 GHz 802.11 b/g/n |
| Bluetooth | BLE 5.0 |
| Display | ST7789 240x135 |
| DS18B20 GPIOs | 6, 13, 14 |
| I2C GPIOs | 16 (SDA), 17 (SCL) |
| UART GPIOs | 43 (TX), 44 (RX) |
| USB | USB-C native |
| Power | 5V USB, 3.3V regulated |

## References

- [ESP32-S3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
- [Waveshare ESP32S3-Geek](https://www.waveshare.com/wiki/ESP32-S3-Geek)
- [DS18B20 Datasheet](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)
- [BME280 Datasheet](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bme280-ds002.pdf)
- [ST7789 Datasheet](https://www.displayfuture.com/Display/datasheet/controller/ST7789.pdf)

## License

This documentation is part of the Tasmota ESP32S3-Geek project, licensed under GPL-3.0.
