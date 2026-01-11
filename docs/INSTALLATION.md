# Installation Guide - Tasmota ESP32S3-Geek v7

Complete step-by-step installation guide for Tasmota ESP32S3-Geek firmware v7.

## Prerequisites

### Hardware
- Waveshare ESP32S3-Geek stick
- USB-C cable
- Computer with USB port

### Software
- Python 3.x
- esptool.py
- curl (for verification)
- jq (optional, for JSON parsing)

### Install Tools

**Linux/macOS:**
```bash
pip3 install esptool
sudo apt install curl jq  # Ubuntu/Debian
brew install curl jq      # macOS
```

**Windows:**
```powershell
pip install esptool
# Download curl and jq from official websites
```

## Step 1: Download Firmware

### Option A: Clone Repository (Recommended)
```bash
git clone https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek.git
cd tasmota-ESP32S3-Geek/firmware/release/v7
```

### Option B: Direct Download
```bash
mkdir -p tasmota-esp32s3-geek
cd tasmota-esp32s3-geek

# Download firmware
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/v7/tasmota32s3geek-v15.0.1-v7-factory.bin

# Download configuration files
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/v7/template.json
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/v7/display.ini
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/v7/pages.jsonl
wget https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/release/v7/autoexec.be
```

## Step 2: Connect Hardware

1. Connect ESP32S3-Geek to computer via USB-C cable
2. Press and hold BOOT button
3. Press RESET button (while holding BOOT)
4. Release RESET button
5. Release BOOT button

Device is now in flash mode.

### Find Serial Port

**Linux:**
```bash
ls /dev/ttyUSB* /dev/ttyACM*
# Usually: /dev/ttyUSB0 or /dev/ttyACM0
```

**macOS:**
```bash
ls /dev/cu.usbserial-* /dev/cu.wchusbserial*
# Usually: /dev/cu.usbserial-XXXX
```

**Windows:**
```powershell
# Check Device Manager → Ports (COM & LPT)
# Usually: COM3, COM4, etc.
```

## Step 3: Flash Firmware

### Factory Install (First Time)

**Linux/macOS:**
```bash
esptool.py --chip esp32s3 \
  --port /dev/ttyUSB0 \
  --baud 921600 \
  --before default_reset \
  --after hard_reset \
  write_flash -z \
  --flash_mode dio \
  --flash_freq 80m \
  --flash_size detect \
  0x0 tasmota32s3geek-v15.0.1-v7-factory.bin
```

**Windows:**
```powershell
esptool.py --chip esp32s3 ^
  --port COM3 ^
  --baud 921600 ^
  --before default_reset ^
  --after hard_reset ^
  write_flash -z ^
  --flash_mode dio ^
  --flash_freq 80m ^
  --flash_size detect ^
  0x0 tasmota32s3geek-v15.0.1-v7-factory.bin
```

**Expected Output:**
```
Connecting....
Chip is ESP32-S3 (revision v0.1)
...
Writing at 0x00000000... (100%)
Hash of data verified.

Leaving...
Hard resetting via RTS pin...
```

### OTA Update (Existing Installation)

If you already have Tasmota installed:

```bash
# Via web interface
http://tasmota-77.local/up

# Or via curl
curl -F "u2=@tasmota32s3geek-v15.0.1-v7.bin" \
  http://tasmota-77.local/up
```

## Step 4: Configure WiFi

### First Boot

1. Device creates AP: `tasmota-XXXXXX`
2. Connect to this AP with your phone/computer
3. Browser opens automatically (or go to http://192.168.4.1)
4. Select your WiFi network
5. Enter WiFi password
6. Click "Save"

Device will restart and connect to your WiFi.

### Find Device IP

**Option A: Check Router**
Look for device named "ESP32S3-Geek" or "tasmota-XXXXXX"

**Option B: mDNS**
```bash
ping tasmota-77.local
# or
avahi-browse -rt _http._tcp
```

**Option C: Network Scan**
```bash
nmap -p 80 192.168.1.0/24
```

## Step 5: Upload Configuration Files

### Via Web Interface

1. Open http://tasmota-77.local (or IP address)
2. Go to: **Tools** → **Manage File system**
3. Upload files one by one:
   - `display.ini`
   - `pages.jsonl`
   - `autoexec.be`

### Via curl

```bash
# Set device IP or hostname
DEVICE="tasmota-77.local"

# Upload display.ini
curl -F "ufsu=@display.ini" \
  "http://${DEVICE}/ufsu?fsz=$(stat -c%s display.ini)"

# Upload pages.jsonl
curl -F "ufsu=@pages.jsonl" \
  "http://${DEVICE}/ufsu?fsz=$(stat -c%s pages.jsonl)"

# Upload autoexec.be
curl -F "ufsu=@autoexec.be" \
  "http://${DEVICE}/ufsu?fsz=$(stat -c%s autoexec.be)"
```

## Step 6: Apply GPIO Template

### Via Web Console

1. Open http://tasmota-77.local
2. Go to: **Console**
3. Paste and execute:

```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,1,1,0,4864,1,1312,1,1,1,1,1,1,1312,1312,1,640,608,1,1,1,3840,6210,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,3200,3232],"FLAG":0,"BASE":1}
```

4. Execute:
```
Module 0
```

5. Execute:
```
Restart 1
```

### Via curl

```bash
DEVICE="tasmota-77.local"

# Apply template
curl -s "http://${DEVICE}/cm" \
  -d "cmnd=Template $(cat template.json)"

# Activate module
curl -s "http://${DEVICE}/cm?cmnd=Module%200"

# Restart
curl -s "http://${DEVICE}/cm?cmnd=Restart%201"
```

## Step 7: Verify Installation

Wait ~30 seconds after restart, then verify:

### Check Sensors

```bash
curl -s "http://tasmota-77.local/cm?cmnd=Status%2010" | jq .
```

**Expected Output:**
```json
{
  "StatusSNS": {
    "Time": "2026-01-11T15:30:00",
    "DS18B20-XXXXXX": {
      "Id": "00000XXXXXXX",
      "Temperature": 22.5
    },
    "TempUnit": "C"
  }
}
```

### Check Display

```bash
curl -s "http://tasmota-77.local/cm?cmnd=DisplayModel" | jq .
```

**Expected Output:**
```json
{
  "DisplayModel": 17
}
```

### Check GPIO Configuration

```bash
curl -s "http://tasmota-77.local/cm?cmnd=Template" | jq .
```

Verify:
- GPIO 6, 13, 14: 1312 (DS18x20)
- GPIO 16: 640 (I2C SDA)
- GPIO 17: 608 (I2C SCL)

## Troubleshooting

### Flash Failed

**Error: "Failed to connect"**
- Check USB cable (must support data, not just charging)
- Try different USB port
- Reduce baud rate: `--baud 115200`
- Ensure device is in flash mode (BOOT + RESET)

**Error: "Chip not found"**
- Install USB drivers (CH340, CP2102, etc.)
- Check Device Manager (Windows) or `dmesg` (Linux)

### WiFi Connection Failed

1. Reset WiFi settings:
   - Press RESET button 4 times quickly
   - Device creates AP again

2. Check WiFi credentials:
   - SSID correct?
   - Password correct?
   - 2.4 GHz network? (ESP32 doesn't support 5 GHz)

### No Sensors Detected

1. **Check GPIO configuration:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=Template" | jq .GPIO
   ```

2. **Check physical connections:**
   - DS18B20 connected to GPIO 6, 13, or 14?
   - 4.7kΩ pull-up resistor installed?
   - VCC, GND, Data connections correct?

3. **Restart device:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=Restart%201"
   ```

### Display Not Working

1. **Check display.ini uploaded:**
   ```bash
   curl -s "http://tasmota-77.local/ufsd" | grep display.ini
   ```

2. **Check DisplayModel:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=DisplayModel" | jq .
   ```
   Should return: `{"DisplayModel": 17}`

3. **Restart to load display.ini:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=Restart%201"
   ```

### HASPmota Not Working

1. **Check all files uploaded:**
   - display.ini
   - pages.jsonl
   - autoexec.be

2. **Manually load autoexec.be:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=br%20load(%27autoexec.be%27)"
   ```

3. **Check Berry enabled:**
   ```bash
   curl -s "http://tasmota-77.local/cm?cmnd=SetOption36" | jq .
   ```
   Should return: `{"SetOption36": 1}`

## Advanced Configuration

### Add More Sensors

Connect additional DS18B20 sensors to GPIO 6, 13, or 14. They will be automatically detected after restart.

### Configure MQTT

```bash
# Via Console
Backlog MqttHost your-mqtt-broker; MqttUser username; MqttPassword password; MqttClient esp32s3geek; Topic tasmota_77
```

### Adjust Telemetry Period

```bash
# Via Console
TelePeriod 60  # Send telemetry every 60 seconds
```

### Customize Display

Edit `pages.jsonl` to add more sensors or change layout. See [v7 README](../firmware/release/v7/README.md) for details.

## Next Steps

- [Hardware Documentation](HARDWARE.md)
- [Configuration Comparison](CONFIGURATION_COMPARISON.md)
- [Success Story](TASMOTA-77-SUCCESS.md)
- [Tasmota Documentation](https://tasmota.github.io/docs/)

## Support

For issues:
1. Check this guide
2. Verify hardware connections
3. Check Tasmota console for errors
4. Review documentation in `docs/` folder

## License

This project uses Tasmota firmware which is licensed under GPL-3.0.
