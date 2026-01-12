# DS18B20 Temperature Sensor Configuration

**Sensor**: Dallas DS18B20 Digital Temperature Sensor  
**Protocol**: 1-Wire  
**Accuracy**: ±0.5°C (-10°C to +85°C)  
**Resolution**: 9-12 bit (configurable)  

---

## Overview

The ESP32-S3 Geek supports up to 10 DS18B20 temperature sensors per GPIO pin. The current configuration uses three separate GPIOs for maximum flexibility.

### Configured Sensors

```
GPIO 6:  DS18B20 Sensor #1
GPIO 13: DS18B20 Sensor #2
GPIO 14: DS18B20 Sensor #3
```

---

## Hardware Setup

### DS18B20 Pinout

**TO-92 Package** (most common):
```
  Front View
   ___
  /   \
 | 1 2 3|
  \___/

Pin 1: GND    (Ground)
Pin 2: Data   (to GPIO)
Pin 3: VDD    (3.3V Power)
```

**Waterproof Version**:
```
Red:    VDD (3.3V)
Black:  GND
Yellow: Data (to GPIO)
```

### Required Components

**Per Sensor**:
- 1x DS18B20 sensor
- 1x 4.7kΩ resistor (pull-up)
- Wires

**Why 4.7kΩ?**
- Required for 1-Wire protocol
- Pulls data line high when idle
- Allows proper communication

---

## Wiring Diagrams

### Single Sensor (GPIO 6)

```
ESP32-S3 Geek          DS18B20
                        ___
3.3V --------+------> |VDD|
             |         |   |
            4.7kΩ      |   |
             |         |   |
GPIO 6 ------+------> |Data|
                       |   |
GND ----------------> |GND|
                       ‾‾‾
```

### Three Sensors (Separate GPIOs)

```
ESP32-S3 Geek

3.3V ----+----+----+
         |    |    |
       4.7kΩ 4.7kΩ 4.7kΩ
         |    |    |
GPIO 6 --+    |    |    DS18B20 #1
         |    |    |
GPIO 13 ------+    |    DS18B20 #2
         |         |
GPIO 14 -----------+    DS18B20 #3
         |         |
GND -----+---------+
```

### Multiple Sensors on One GPIO

**Alternative**: All sensors on GPIO 6:
```
ESP32-S3          DS18B20 #1    DS18B20 #2    DS18B20 #3
                   ___           ___           ___
3.3V ----+-----> |VDD|-------> |VDD|-------> |VDD|
         |        |   |         |   |         |   |
       4.7kΩ      |   |         |   |         |   |
         |        |   |         |   |         |   |
GPIO 6 --+-----> |Data|------> |Data|------> |Data|
                  |   |         |   |         |   |
GND -----------> |GND|-------> |GND|-------> |GND|
                  ‾‾‾           ‾‾‾           ‾‾‾
```

**Advantages**:
- Only one GPIO used
- Only one pull-up resistor needed
- Up to 10 sensors per GPIO

**Disadvantages**:
- All sensors share same bus
- One faulty sensor affects all
- Slightly slower reading

---

## Tasmota Configuration

### GPIO Template

**Current Configuration**:
```json
{
  "NAME": "ESP32S3-Geek",
  "GPIO": [
    32,0,0,0,0,0,
    1,              // GPIO 6:  DS18x20
    0,0,0,0,0,0,
    1,              // GPIO 13: DS18x20
    1,              // GPIO 14: DS18x20
    0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0
  ],
  "FLAG": 0,
  "BASE": 1
}
```

**Console Command**:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
Restart 1
```

### Manual GPIO Configuration

**Alternative Method**:
```
# Configure GPIOs
GPIO 6 DS18x20
GPIO 13 DS18x20
GPIO 14 DS18x20

# Save and restart
Restart 1
```

---

## Sensor Reading

### Console Commands

**Check Sensor Status**:
```
Status 10
```

**Example Output**:
```json
{
  "StatusSNS": {
    "Time": "2026-01-12T18:00:00",
    "DS18B20-5329E2": {
      "Id": "0000005329E2",
      "Temperature": 23.1
    },
    "DS18B20-51C76D": {
      "Id": "00000051C76D",
      "Temperature": 24.6
    },
    "DS18B20-XXXXXX": {
      "Id": "28XXXXXXXXXXXXXX",
      "Temperature": 22.8
    },
    "TempUnit": "C"
  }
}
```

### MQTT Messages

**Telemetry** (every 60 seconds):
```
Topic: tele/tasmota32s3-lvgl/SENSOR

Payload:
{
  "Time": "2026-01-12T18:00:00",
  "DS18B20-5329E2": {
    "Id": "0000005329E2",
    "Temperature": 23.1
  },
  "DS18B20-51C76D": {
    "Id": "00000051C76D",
    "Temperature": 24.6
  },
  "TempUnit": "C"
}
```

### Web Interface

**Information Page**:
- Shows all detected sensors
- Real-time temperature readings
- Sensor IDs displayed
- Auto-refresh every 10 seconds

---

## Sensor Identification

### ROM Code Structure

Each DS18B20 has a unique 64-bit ROM code:

```
Format: FF-XXXXXXXXXXXX-CC

FF: Family Code (28 = DS18B20)
XX: 48-bit Serial Number (unique)
CC: CRC Checksum
```

**Example**:
```
Full ROM:  28-0000005329E2-XX
Tasmota:   DS18B20-5329E2
```

### Sensor Naming

**Tasmota Format**:
```
DS18B20-<last 6 digits of serial>

Examples:
- 0000005329E2 → DS18B20-5329E2
- 00000051C76D → DS18B20-51C76D
```

### Using Sensor IDs

**Berry Script Example**:
```berry
var sensors = tasmota.read_sensors()

# Access specific sensor
var temp1 = sensors["DS18B20-5329E2"]["Temperature"]
var temp2 = sensors["DS18B20-51C76D"]["Temperature"]

print(f"Sensor 1: {temp1}°C")
print(f"Sensor 2: {temp2}°C")
```

**Rules Example**:
```
Rule1 ON DS18B20-5329E2#Temperature DO Publish stat/temp1 %value% ENDON
Rule1 1
```

---

## Advanced Configuration

### Temperature Resolution

**Set Resolution** (9-12 bit):
```
# Higher resolution = slower reading
# 9-bit:  0.5°C,   93.75 ms
# 10-bit: 0.25°C,  187.5 ms
# 11-bit: 0.125°C, 375 ms
# 12-bit: 0.0625°C, 750 ms (default)

TempRes 12
```

### Temperature Offset

**Calibrate Sensor**:
```
# Add offset in 0.1°C steps
# Example: +1.5°C offset
TempOffset 15

# Example: -0.8°C offset
TempOffset -8
```

### Temperature Unit

**Celsius or Fahrenheit**:
```
# Celsius (default)
TempUnit 0

# Fahrenheit
TempUnit 1
```

---

## Troubleshooting

### Sensor Not Detected

**Symptoms**:
- No sensor data in Status 10
- Missing from web interface

**Checks**:
1. **Wiring**:
   - VDD to 3.3V? ✓
   - GND to GND? ✓
   - Data to GPIO? ✓

2. **Pull-up Resistor**:
   - 4.7kΩ present? ✓
   - Between Data and 3.3V? ✓

3. **GPIO Configuration**:
   ```
   # Check GPIO settings
   GPIO
   
   # Should show:
   # GPIO 6:  DS18x20
   # GPIO 13: DS18x20
   # GPIO 14: DS18x20
   ```

4. **Sensor Working**:
   - Test with multimeter
   - Try different sensor
   - Check for shorts

### Incorrect Readings

**Symptoms**:
- Temperature shows 85°C (error value)
- Temperature shows -127°C (error value)
- Erratic readings

**Solutions**:

1. **Check Pull-up**:
   ```
   # Too weak pull-up (>10kΩ)
   # Too strong pull-up (<1kΩ)
   # Use 4.7kΩ!
   ```

2. **Check Power**:
   ```
   # Measure voltage at sensor VDD
   # Should be 3.3V ±0.1V
   ```

3. **Check Wiring**:
   ```
   # Long wires? (>3m)
   # Use shielded cable
   # Add capacitor (100nF) near sensor
   ```

4. **Enable Logging**:
   ```
   SerialLog 4
   WebLog 4
   
   # Check console for errors
   ```

### Multiple Sensors Issues

**Symptoms**:
- Only one sensor detected
- Sensors interfere with each other

**Solutions**:

1. **Separate GPIOs**:
   ```
   # Use different GPIO for each sensor
   # Current config: GPIO 6, 13, 14
   ```

2. **Check Pull-ups**:
   ```
   # Each GPIO needs its own 4.7kΩ
   # Don't share pull-up resistors
   ```

3. **Parasite Power**:
   ```
   # Don't use parasite power mode
   # Always connect VDD to 3.3V
   ```

---

## Best Practices

### Wiring

✅ **Do**:
- Use 4.7kΩ pull-up resistor
- Keep wires short (<3m)
- Use shielded cable for long runs
- Connect VDD to 3.3V (not parasite power)
- Twist Data and GND wires together

❌ **Don't**:
- Use wrong resistor value
- Exceed 3m wire length without precautions
- Use parasite power mode
- Share pull-up between GPIOs
- Run sensor wires parallel to power lines

### Sensor Placement

✅ **Do**:
- Mount away from heat sources
- Allow air circulation
- Protect from moisture (if not waterproof)
- Label sensors with IDs
- Document sensor locations

❌ **Don't**:
- Mount near hot components
- Seal in airtight enclosure
- Expose to direct sunlight
- Mix up sensor locations

### Configuration

✅ **Do**:
- Use separate GPIOs for critical sensors
- Document sensor IDs and locations
- Test sensors before deployment
- Set appropriate TempRes
- Calibrate if needed (TempOffset)

❌ **Don't**:
- Use all sensors on one GPIO in critical applications
- Forget to document sensor IDs
- Deploy without testing
- Use highest resolution if not needed

---

## Example Configurations

### Home Temperature Monitoring

```
GPIO 6:  Living Room (DS18B20-5329E2)
GPIO 13: Bedroom     (DS18B20-51C76D)
GPIO 14: Outside     (DS18B20-XXXXXX)
```

**Berry Script**:
```berry
# autoexec.be
def update_temps()
  var sensors = tasmota.read_sensors()
  
  var living = sensors["DS18B20-5329E2"]["Temperature"]
  var bedroom = sensors["DS18B20-51C76D"]["Temperature"]
  var outside = sensors["DS18B20-XXXXXX"]["Temperature"]
  
  # Display on screen
  print(f"Living: {living}°C")
  print(f"Bedroom: {bedroom}°C")
  print(f"Outside: {outside}°C")
end

# Update every 30 seconds
tasmota.add_cron("*/30 * * * * *", update_temps, "temps")
```

### Aquarium Monitoring

```
GPIO 6:  Water Temperature
GPIO 13: Room Temperature
GPIO 14: Heater Temperature
```

**Rules**:
```
# Alert if water too cold
Rule1 ON DS18B20-5329E2#Temperature<24 DO Publish alert/aquarium {"status":"cold","temp":%value%} ENDON

# Alert if water too hot
Rule2 ON DS18B20-5329E2#Temperature>28 DO Publish alert/aquarium {"status":"hot","temp":%value%} ENDON

Rule1 1
Rule2 1
```

### Server Room Monitoring

```
GPIO 6:  Rack 1 Temperature
GPIO 13: Rack 2 Temperature
GPIO 14: Ambient Temperature
```

**MQTT Integration**:
```
# Home Assistant auto-discovery
SetOption19 1

# Publish to custom topics
Rule1 ON DS18B20-5329E2#Temperature DO Publish server/rack1/temp %value% ENDON
Rule1 ON DS18B20-51C76D#Temperature DO Publish server/rack2/temp %value% ENDON
Rule1 1
```

---

## Specifications

### DS18B20 Specifications

| Parameter | Value |
|-----------|-------|
| **Temperature Range** | -55°C to +125°C |
| **Accuracy** | ±0.5°C (-10°C to +85°C) |
| **Resolution** | 9-12 bit (0.5°C to 0.0625°C) |
| **Conversion Time** | 93.75ms to 750ms |
| **Supply Voltage** | 3.0V to 5.5V |
| **Supply Current** | 1mA (active), 1µA (standby) |
| **Protocol** | 1-Wire |
| **Package** | TO-92, SO-8, µSOP |

### 1-Wire Protocol

| Parameter | Value |
|-----------|-------|
| **Data Rate** | 16.3 kbps (standard) |
| **Max Cable Length** | 100m (with proper wiring) |
| **Max Devices** | 10 per GPIO (Tasmota limit) |
| **Pull-up Resistor** | 4.7kΩ (recommended) |
| **Voltage Levels** | 0V (low), 3.3V (high) |

---

## References

### Datasheets

- [DS18B20 Datasheet](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)
- [1-Wire Protocol](https://www.maximintegrated.com/en/design/technical-documents/tutorials/1/1796.html)

### Tasmota Documentation

- [DS18x20 Sensors](https://tasmota.github.io/docs/DS18x20/)
- [GPIO Configuration](https://tasmota.github.io/docs/GPIO-Conversion/)
- [Sensor Commands](https://tasmota.github.io/docs/Commands/#sensors)

### Related Documents

- [GPIO_PINOUT.md](GPIO_PINOUT.md) - Complete GPIO mapping
- [HARDWARE.md](HARDWARE.md) - Hardware specifications

---

**Last Updated**: 2026-01-12  
**Sensor**: Dallas DS18B20  
**Configuration**: GPIO 6, 13, 14
