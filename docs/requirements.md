# Projektanforderungen - Tasmota ESP32S3-Geek

## Projekt: tasmota32s3geek

### Hardware Anforderungen

#### Waveshare ESP32S3-Geek Stick
- **MCU**: ESP32-S3 @ 240MHz
- **Flash**: 16MB
- **PSRAM**: 8MB
- **Display**: ST7789 TFT 240x135 Pixel
- **USB**: USB-C für Programmierung und Stromversorgung

#### Sensoren

**DS18B20 Temperatursensoren**:
- Bis zu 10 Sensoren pro GPIO
- 3 GPIO Anschlüsse verfügbar (GPIO 32, 33, weitere)
- 4.7kΩ Pull-up Resistor erforderlich
- Versorgung: 3.3V

**BME280 Sensoren (I2C)**:
- 2 Geräte auf I2C Bus
- Adressen: 0x76 und 0x77
- Messwerte: Temperatur, Luftfeuchtigkeit, Luftdruck
- Versorgung: 3.3V

### Software Anforderungen

#### Tasmota Firmware
- **Version**: 15.0.1
- **Grund**: Kompatibilität mit ESP32S3-Geek Stick
- **Build**: tasmota32s3
- **Features**:
  - DS18B20 Support
  - BME280 Support (I2C)
  - Display Support (ST7789)
  - MQTT Support
  - Berry Scripting
  - Web Interface
  - OTA Updates

#### Custom Branding
- Firmware Name: "esp32s3geek"
- Build Information: Datum/Zeit
- Credits: "by Harald"

### Funktionale Anforderungen

#### 1. Sensor Unterstützung

**DS18B20**:
- Auslesen von bis zu 10 Sensoren pro GPIO
- 3 GPIO Anschlüsse nutzbar
- Automatische Sensor-Erkennung
- Temperatur in °C
- Sensor ID als Name

**BME280**:
- Auslesen von 2 Sensoren über I2C
- Adresse 0x76 (BME280-76)
- Adresse 0x77 (BME280-77)
- Messwerte:
  - Temperatur (°C)
  - Luftfeuchtigkeit (%)
  - Luftdruck (hPa)
  - Taupunkt (°C)

#### 2. Display Funktionalität

**Anzeige**:
- Device Name / Hostname
- WiFi SSID
- IP Adresse
- Aktuelle Uhrzeit
- Sensor Daten (BME280 und DS18B20)

**Update**:
- Automatische Aktualisierung alle 5 Sekunden
- Berry Script gesteuert (autoexec.be)

**Layout**:
```
Zeile 1: ESP32S3-Geek
Zeile 2: SSID: <WiFi Name>
Zeile 3: IP: <IP Adresse>
Zeile 4: <Datum> <Uhrzeit>
Zeile 5+: Sensor Daten
```

#### 3. MQTT Integration

**Funktionen**:
- Verbindung zu MQTT Broker
- Telemetrie Daten alle 60 Sekunden
- Status Updates
- Command & Control

**Topics**:
- `tele/<topic>/SENSOR` - Sensor Daten
- `stat/<topic>/STATUS` - Status
- `cmnd/<topic>/*` - Befehle

**Daten Format**: JSON

#### 4. Konfiguration

**GPIO Template**:
- Vordefiniertes Template für ESP32S3-Geek
- Einfache Anwendung via Tasmota Console
- Alle Pins korrekt zugewiesen

**WiFi**:
- AP Mode für Erstkonfiguration
- Station Mode für Betrieb
- Automatische Reconnect

**MQTT**:
- Konfigurierbar via Web Interface
- Host, Port, User, Password
- Optional (nicht zwingend erforderlich)

#### 5. Web Interface

**Funktionen**:
- Konfiguration (WiFi, MQTT, etc.)
- Sensor Monitoring
- Display Kontrolle
- Firmware Update (OTA)
- Berry Script Management
- File System Management

**Zugriff**:
- HTTP auf Port 80
- Responsive Design
- Standard Tasmota Interface

### Qualitätsanforderungen

#### 1. Automatisierte Tests

**Test Umgebung**:
- **tasmota-75** (https://tasmota-75.samharald.eu):
  - Update Installation Test
  - 2x BME280 Sensoren
  - WiFi und MQTT konfiguriert
  
- **tasmota-77** (https://tasmota-77.samharald.eu):
  - Neuinstallation Test
  - 2x DS18B20 Sensoren
  - Basis Konfiguration

**Test Bereiche**:
- Device Erreichbarkeit
- Web Interface Verfügbarkeit
- Tasmota Version Verifikation
- Template Konfiguration
- WiFi Verbindung
- I2C Sensor Erkennung
- Sensor Daten Verfügbarkeit
- Display Konfiguration
- MQTT Status (falls konfiguriert)
- Uptime und Memory Status

**Test Automation**:
- Script: `tests/test-device.sh`
- Alle Tests: `tests/run-all-tests.sh`
- Ergebnisse: `tests/results/`

#### 2. OTA Update

**Anforderungen**:
- Firmware temporär auf OTA Server
- Update via Web Interface
- Update via MQTT Command
- Automatischer Neustart
- Konfiguration bleibt erhalten

**Test**:
- Update von bestehender Installation (tasmota-75)
- Verifikation nach Update
- Sensor Funktion nach Update
- Display Funktion nach Update

#### 3. Konfiguration Tests

**Stick Konfiguration**:
- Template Anwendung
- GPIO Funktion
- Display Aktivierung
- Sensor Erkennung

**Sensor Tests**:
- BME280 Daten korrekt
- DS18B20 Daten korrekt
- Anzeige auf Display
- MQTT Übertragung (falls konfiguriert)

### Dokumentations Anforderungen

#### 1. Projekt Dokumentation

**README.md**:
- Projekt Übersicht
- Features
- Schnellstart
- Projektstruktur
- Links zu allen Dateien

**docs/requirements.md** (diese Datei):
- Vollständige Anforderungen
- Hardware Spezifikationen
- Software Anforderungen
- Funktionale Anforderungen
- Qualitätsanforderungen

**docs/installation.md**:
- Detaillierte Installationsanleitung
- Mehrere Installationsmethoden
- Konfigurationsschritte
- Sensor Anschluss
- Troubleshooting

**docs/testing.md**:
- Test Strategie
- Test Durchführung
- Test Ergebnisse
- Qualitätssicherung

#### 2. Konfigurations Dokumentation

**config/gpio-mapping.md**:
- GPIO Pin Belegung
- Sensor Anschlüsse
- Display Pins
- I2C Konfiguration

**config/display-config.md**:
- Display Befehle
- Layout Beschreibung
- Berry Script Integration
- Manuelle Tests

**config/template-commands.txt**:
- Tasmota Console Befehle
- Template Anwendung
- Basis Konfiguration

#### 3. Script Dokumentation

**scripts/build.sh**:
- Firmware Build Prozess
- Voraussetzungen
- Output Dateien
- Fehlerbehandlung

**scripts/flash.sh**:
- Flash Prozess
- Geräte Erkennung
- Factory vs. OTA Flash
- Anleitung

**tests/test-device.sh**:
- Test Durchführung
- Test Cases
- Ergebnis Interpretation

### Installations Anforderungen

#### 1. Firmware Dateien

**Verfügbarkeit**:
- Alle Dateien im Git Repository
- Direkte Download Links in README
- Release Verzeichnis: `firmware/release/`

**Dateien**:
- `tasmota32s3geek-v15.0.1-factory.bin` - Neuinstallation
- `tasmota32s3geek-v15.0.1.bin` - OTA Update
- `version.txt` - Build Informationen
- `README.md` - Firmware Dokumentation

#### 2. Konfigurations Dateien

**Verfügbarkeit**:
- Im Git Repository: `config/`
- Direkte Download Links in README

**Dateien**:
- `autoexec.be` - Berry Display Script
- `template.json` - GPIO Template
- `template-commands.txt` - Tasmota Befehle

#### 3. Installation Workflow

**Neuinstallation**:
1. Firmware Download
2. Flash mit esptool oder Script
3. WiFi Konfiguration
4. Template Anwendung
5. autoexec.be Upload
6. Sensor Anschluss
7. Verifikation

**Update Installation**:
1. Firmware Download
2. OTA Update via Web Interface oder MQTT
3. Automatischer Neustart
4. Verifikation
5. Konfiguration prüfen

### Test Anforderungen

#### 1. Neuinstallation Test (tasmota-77)

**Vorbereitung**:
- Factory Firmware flashen
- WiFi konfigurieren
- Template anwenden
- 2x DS18B20 anschließen

**Tests**:
- Device erreichbar
- Web Interface funktioniert
- Template korrekt
- DS18B20 erkannt
- Display zeigt Daten
- Sensor Werte plausibel

#### 2. Update Test (tasmota-75)

**Vorbereitung**:
- Bestehende Installation
- 2x BME280 angeschlossen
- WiFi und MQTT konfiguriert

**Tests**:
- OTA Update erfolgreich
- Konfiguration erhalten
- BME280 funktioniert weiter
- Display funktioniert
- MQTT funktioniert
- Sensor Werte plausibel

#### 3. MQTT Test (tasmota-75)

**Anforderungen**:
- MQTT Broker erreichbar
- Credentials konfiguriert

**Tests**:
- MQTT Verbindung aktiv
- Telemetrie Daten empfangen
- Sensor Daten im JSON Format
- Update Intervall 60 Sekunden
- Commands funktionieren

### Erfolgs Kriterien

#### Firmware Build
- ✅ Build erfolgreich ohne Fehler
- ✅ Firmware Größe < 2MB (OTA)
- ✅ Factory Firmware enthält Bootloader
- ✅ Version 15.0.1 korrekt
- ✅ Custom Branding vorhanden

#### Installation
- ✅ Flash Prozess erfolgreich
- ✅ Gerät startet nach Flash
- ✅ WiFi AP verfügbar
- ✅ Web Interface erreichbar
- ✅ Template anwendbar

#### Sensoren
- ✅ DS18B20 erkannt (bis zu 10 pro GPIO)
- ✅ BME280 erkannt (0x76 und 0x77)
- ✅ Sensor Daten plausibel
- ✅ Sensor Daten auf Display
- ✅ Sensor Daten via MQTT (optional)

#### Display
- ✅ Display zeigt Informationen
- ✅ WiFi SSID sichtbar
- ✅ IP Adresse sichtbar
- ✅ Zeit wird angezeigt
- ✅ Sensor Daten sichtbar
- ✅ Update alle 5 Sekunden

#### MQTT (optional)
- ✅ Verbindung zum Broker
- ✅ Telemetrie alle 60 Sekunden
- ✅ JSON Format korrekt
- ✅ Commands funktionieren

#### Tests
- ✅ Alle automatisierten Tests bestanden
- ✅ tasmota-75 Tests erfolgreich
- ✅ tasmota-77 Tests erfolgreich
- ✅ Test Ergebnisse dokumentiert

#### Dokumentation
- ✅ README vollständig
- ✅ Installation Guide vorhanden
- ✅ Alle Dateien verlinkt
- ✅ Troubleshooting Guide
- ✅ Test Dokumentation
- ✅ Script Dokumentation

## Zusammenfassung

Das Projekt erfüllt alle Anforderungen wenn:

1. **Firmware** erfolgreich gebaut und getestet
2. **Installation** auf beiden Test-Geräten erfolgreich
3. **Sensoren** funktionieren korrekt (DS18B20 und BME280)
4. **Display** zeigt alle Informationen automatisch
5. **MQTT** funktioniert (auf tasmota-75)
6. **Tests** alle bestanden
7. **Dokumentation** vollständig und verlinkt
8. **Dateien** im Git verfügbar zum Download
