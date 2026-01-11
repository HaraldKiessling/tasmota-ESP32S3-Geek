# Installation Guide - Tasmota ESP32S3-Geek

## Übersicht

Diese Anleitung beschreibt die Installation der Tasmota Firmware auf dem Waveshare ESP32S3-Geek Stick.

## Voraussetzungen

### Hardware
- Waveshare ESP32S3-Geek Stick
- USB-C Kabel
- Optional: DS18B20 Temperatursensoren
- Optional: BME280 Sensoren (I2C)

### Software
- Python 3.x
- esptool.py (wird automatisch installiert)
- Webbrowser für Konfiguration

## Installation Methoden

### Methode 1: Automatisches Flash Script (Empfohlen)

1. **Firmware bauen** (falls noch nicht vorhanden):
   ```bash
   ./scripts/build.sh
   ```

2. **ESP32S3-Geek anschließen**:
   - USB-C Kabel mit Computer verbinden
   - Gerät sollte als /dev/ttyUSB0 oder /dev/ttyACM0 erkannt werden

3. **Firmware flashen**:
   ```bash
   ./scripts/flash.sh
   ```
   
   Wählen Sie:
   - Option 1: OTA Update (für bestehende Tasmota Installation)
   - Option 2: Factory Flash (für neues/leeres Gerät)

### Methode 2: Manuelles Flashen mit esptool

1. **esptool installieren**:
   ```bash
   pip3 install esptool
   ```

2. **Firmware herunterladen**:
   - Neuinstallation: `firmware/release/tasmota32s3geek-v15.0.1-factory.bin`
   - Update: `firmware/release/tasmota32s3geek-v15.0.1.bin`

3. **Flash löschen** (nur bei Neuinstallation):
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash
   ```

4. **Firmware flashen**:
   
   **Neuinstallation (Factory)**:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
     --before default_reset --after hard_reset write_flash \
     -z --flash_mode dio --flash_freq 80m --flash_size detect \
     0x0 firmware/release/tasmota32s3geek-v15.0.1-factory.bin
   ```
   
   **Update (OTA)**:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
     --before default_reset --after hard_reset write_flash \
     -z --flash_mode dio --flash_freq 80m --flash_size detect \
     0x0 firmware/release/tasmota32s3geek-v15.0.1.bin
   ```

### Methode 3: OTA Update über Web Interface

Für bestehende Tasmota Installation:

1. **Firmware hochladen**:
   - Tasmota Web Interface öffnen
   - Menü: "Firmware Upgrade"
   - Datei auswählen: `tasmota32s3geek-v15.0.1.bin`
   - "Start Upgrade" klicken

2. **Warten auf Neustart**:
   - Gerät startet automatisch neu
   - Nach ca. 30 Sekunden ist das Update abgeschlossen

## Erste Konfiguration

### 1. WiFi Konfiguration

Nach dem ersten Start:

1. **WiFi AP suchen**:
   - SSID: `tasmota-XXXXXX` (XXXXXX = MAC Adresse)
   - Mit Smartphone oder Computer verbinden

2. **Konfigurationsseite öffnen**:
   - Browser öffnet automatisch, oder
   - Manuell: http://192.168.4.1

3. **WiFi konfigurieren**:
   - SSID eingeben
   - Passwort eingeben
   - "Save" klicken

4. **Gerät findet sich im Netzwerk**:
   - Gerät startet neu
   - Verbindet sich mit WiFi
   - IP-Adresse wird auf Display angezeigt

### 2. Template Konfiguration

1. **Tasmota Console öffnen**:
   - Web Interface → Console

2. **Template anwenden**:
   ```
   Backlog Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}; Module 0; DeviceName ESP32S3-Geek; DisplayMode 0; DisplayRotate 1; TelePeriod 60; SaveData 1; Restart 1
   ```

3. **Gerät startet neu** mit korrekter GPIO Konfiguration

### 3. MQTT Konfiguration (Optional)

1. **MQTT Settings öffnen**:
   - Web Interface → Configuration → Configure MQTT

2. **MQTT Broker konfigurieren**:
   - Host: IP-Adresse des MQTT Brokers
   - Port: 1883 (Standard)
   - User: MQTT Username
   - Password: MQTT Passwort
   - Topic: tasmota_%06X (Standard)
   - Full Topic: %prefix%/%topic%/ (Standard)

3. **Save** klicken

### 4. Display Automation (autoexec.be)

1. **Berry Console öffnen**:
   - Web Interface → Consoles → Berry Scripting

2. **autoexec.be hochladen**:
   - Datei: `config/autoexec.be`
   - Über "Manage File System" hochladen, oder
   - Inhalt kopieren und in Berry Console einfügen

3. **Gerät neu starten**:
   ```
   Restart 1
   ```

4. **Display zeigt automatisch**:
   - Device Name
   - WiFi SSID und IP
   - Aktuelle Zeit
   - Sensor Daten (BME280, DS18B20)

## Sensor Anschluss

### DS18B20 Temperatursensoren

**GPIO 32 (Pin 32)**:
- VCC → 3.3V
- GND → GND
- DATA → GPIO 32
- Pull-up Resistor: 4.7kΩ zwischen DATA und VCC

**GPIO 33 (Pin 33)**:
- Gleicher Anschluss wie GPIO 32
- Bis zu 10 Sensoren pro GPIO möglich

### BME280 Sensoren (I2C)

**I2C Bus**:
- VCC → 3.3V
- GND → GND
- SDA → GPIO 16
- SCL → GPIO 17

**Adressen**:
- BME280-76: 0x76 (SDO → GND)
- BME280-77: 0x77 (SDO → VCC)

## Verifikation

### 1. Display Check
- Display sollte Informationen anzeigen
- WiFi SSID und IP sichtbar
- Zeit wird angezeigt

### 2. Sensor Check
1. **I2C Scan**:
   ```
   I2CScan
   ```
   Sollte zeigen: `Device(s) found on bus1 at 0x76 0x77`

2. **Sensor Status**:
   - Web Interface → Main Menu
   - Sensor Daten sollten angezeigt werden

### 3. MQTT Check (falls konfiguriert)
- MQTT Client (z.B. MQTT Explorer) öffnen
- Topic: `tele/tasmota_XXXXXX/SENSOR`
- Sensor Daten sollten alle 60 Sekunden erscheinen

## Troubleshooting

### Display bleibt schwarz
- Template korrekt angewendet?
- Display Rotation prüfen: `DisplayRotate 1`
- Display Mode prüfen: `DisplayMode 0`

### Sensoren werden nicht erkannt
- **DS18B20**: Pull-up Resistor vorhanden?
- **BME280**: I2C Adressen korrekt? `I2CScan` ausführen
- Verkabelung prüfen

### WiFi Verbindung schlägt fehl
- SSID und Passwort korrekt?
- WiFi Reset: `Reset 1` in Console
- Gerät neu starten

### MQTT funktioniert nicht
- Broker erreichbar?
- Credentials korrekt?
- MQTT Status prüfen: `Status 6`

## Weitere Informationen

- **Tasmota Dokumentation**: https://tasmota.github.io/docs/
- **GPIO Template**: `config/template.json`
- **Display Konfiguration**: `config/display-config.md`
- **Test Dokumentation**: `docs/testing.md`

## Support

Bei Problemen:
1. Log Level erhöhen: `WebLog 4`
2. Console Ausgabe prüfen
3. GitHub Issues: https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/issues
