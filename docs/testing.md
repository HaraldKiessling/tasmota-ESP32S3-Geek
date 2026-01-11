# Test Dokumentation - Tasmota ESP32S3-Geek

## Test Strategie

### Übersicht

Die Test-Strategie umfasst automatisierte Tests auf zwei physischen Geräten:

1. **tasmota-75** (https://tasmota-75.samharald.eu)
   - Update Installation Test
   - 2x BME280 Sensoren (I2C)
   - WiFi und MQTT konfiguriert
   - Produktiv-ähnliche Umgebung

2. **tasmota-77** (https://tasmota-77.samharald.eu)
   - Neuinstallation Test
   - 2x DS18B20 Sensoren (GPIO)
   - Basis Konfiguration
   - Fresh Install Szenario

### Test Kategorien

1. **Connectivity Tests**: Netzwerk und Erreichbarkeit
2. **Configuration Tests**: Template und Einstellungen
3. **Sensor Tests**: Hardware und Daten
4. **Display Tests**: Anzeige Funktionalität
5. **MQTT Tests**: Message Broker Integration
6. **System Tests**: Uptime, Memory, Performance

## Test Umgebung

### Hardware Setup

#### tasmota-75 (Update Test)
```
Device: Waveshare ESP32S3-Geek
IP: 192.168.0.75
URL: https://tasmota-75.samharald.eu
Firmware: Tasmota 15.0.1 (tasmota32)

Sensoren:
- BME280-76 (I2C 0x76)
  - Temperatur: ~4-10°C
  - Luftfeuchtigkeit: ~30-65%
  - Luftdruck: ~990 hPa
  
- BME280-77 (I2C 0x77)
  - Temperatur: ~9-11°C
  - Luftfeuchtigkeit: ~60-65%
  - Luftdruck: ~990 hPa

MQTT:
- Broker: 192.168.0.12:1883
- User: mqtthome
- Topic: tasmota_F82084
```

#### tasmota-77 (Neuinstallation Test)
```
Device: Waveshare ESP32S3-Geek
IP: 192.168.0.77
URL: https://tasmota-77.samharald.eu
Firmware: Tasmota 15.0.1 (tasmota32)

Sensoren:
- DS18B20 #1 (GPIO 32)
  - Temperatur: ~20-25°C
  
- DS18B20 #2 (GPIO 32 oder 33)
  - Temperatur: ~20-25°C

MQTT: Optional
```

### Software Setup

**Test Scripts**:
- `tests/test-device.sh` - Einzelgerät Test
- `tests/run-all-tests.sh` - Alle Geräte Test

**Abhängigkeiten**:
- bash
- curl
- ping
- grep, awk, cut

## Test Cases

### 1. Device Reachability Test

**Ziel**: Prüfen ob Gerät im Netzwerk erreichbar ist

**Methode**:
```bash
ping -c 1 -W 2 <device_ip>
```

**Erwartetes Ergebnis**:
- ✅ PASS: Ping erfolgreich
- ❌ FAIL: Timeout oder unreachable

**Fehlerbehandlung**:
- Netzwerk Verbindung prüfen
- IP Adresse verifizieren
- Gerät Neustart

### 2. Web Interface Test

**Ziel**: Prüfen ob Web Interface verfügbar ist

**Methode**:
```bash
curl -s -o /dev/null -w "%{http_code}" http://<device_ip>/
```

**Erwartetes Ergebnis**:
- ✅ PASS: HTTP 200
- ❌ FAIL: HTTP 4xx oder 5xx

**Fehlerbehandlung**:
- Web Server Status prüfen
- Firewall Regeln prüfen
- Gerät Neustart

### 3. Tasmota Version Test

**Ziel**: Prüfen ob korrekte Firmware Version läuft

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%200"
```

**Erwartetes Ergebnis**:
- ✅ PASS: Version enthält "15.0.1"
- ❌ FAIL: Andere Version

**Fehlerbehandlung**:
- Firmware Update durchführen
- Build Version prüfen

### 4. Device Name Test

**Ziel**: Prüfen ob Device Name konfiguriert ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%200" | grep DeviceName
```

**Erwartetes Ergebnis**:
- ✅ PASS: DeviceName enthält "Tasmota" oder "ESP32S3"
- ❌ FAIL: Kein oder falscher Name

**Fehlerbehandlung**:
```bash
DeviceName ESP32S3-Geek
```

### 5. Module Template Test

**Ziel**: Prüfen ob GPIO Template korrekt konfiguriert ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Template"
```

**Erwartetes Ergebnis**:
- ✅ PASS: Template NAME = "ESP32S3-Geek"
- ❌ FAIL: Anderes oder kein Template

**Fehlerbehandlung**:
```bash
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
```

### 6. WiFi Connection Test

**Ziel**: Prüfen ob WiFi Verbindung stabil ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%200" | grep SSId
curl -s "http://<device_ip>/cm?cmnd=Status%200" | grep RSSI
```

**Erwartetes Ergebnis**:
- ✅ PASS: SSId vorhanden, RSSI > 0
- ❌ FAIL: Keine SSID oder RSSI = 0

**Fehlerbehandlung**:
- WiFi Konfiguration prüfen
- Signal Stärke verbessern
- Router Neustart

### 7. I2C Sensors Test

**Ziel**: Prüfen ob I2C Sensoren erkannt werden

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=I2CScan"
```

**Erwartetes Ergebnis** (tasmota-75):
- ✅ PASS: "0x76" und "0x77" gefunden
- ⚠️ PARTIAL: Nur einer gefunden
- ❌ FAIL: Keine gefunden

**Erwartetes Ergebnis** (tasmota-77):
- ℹ️ INFO: Keine I2C Sensoren (DS18B20 verwendet)

**Fehlerbehandlung**:
- Verkabelung prüfen (SDA, SCL)
- Pull-up Resistoren prüfen
- Sensor Adressen prüfen

### 8. Sensor Data Test

**Ziel**: Prüfen ob Sensor Daten verfügbar sind

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%208"
```

**Erwartetes Ergebnis** (tasmota-75):
- ✅ PASS: BME280-76 und BME280-77 Daten vorhanden
- ❌ FAIL: Keine Sensor Daten

**Erwartetes Ergebnis** (tasmota-77):
- ✅ PASS: DS18B20 Daten vorhanden
- ❌ FAIL: Keine Sensor Daten

**Daten Validierung**:
- Temperatur: -40°C bis +85°C (plausibel)
- Luftfeuchtigkeit: 0% bis 100%
- Luftdruck: 300 hPa bis 1100 hPa

**Fehlerbehandlung**:
- Sensor Anschluss prüfen
- Sensor Typ prüfen
- Pull-up Resistor (DS18B20)

### 9. Display Configuration Test

**Ziel**: Prüfen ob Display konfiguriert ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=DisplayMode"
```

**Erwartetes Ergebnis**:
- ✅ PASS: DisplayMode vorhanden
- ❌ FAIL: Kein Display Mode

**Fehlerbehandlung**:
```bash
DisplayMode 0
DisplayRotate 1
```

### 10. MQTT Status Test

**Ziel**: Prüfen ob MQTT konfiguriert und verbunden ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%206"
```

**Erwartetes Ergebnis** (tasmota-75):
- ✅ PASS: MqttHost vorhanden, MqttCount > 0
- ⚠️ INFO: Konfiguriert aber nicht verbunden
- ❌ FAIL: Nicht konfiguriert

**Erwartetes Ergebnis** (tasmota-77):
- ℹ️ INFO: MQTT optional, nicht erforderlich

**Fehlerbehandlung**:
- Broker Erreichbarkeit prüfen
- Credentials prüfen
- Firewall prüfen

### 11. Uptime Test

**Ziel**: Prüfen ob Gerät stabil läuft

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%200" | grep Uptime
```

**Erwartetes Ergebnis**:
- ✅ PASS: Uptime vorhanden
- ❌ FAIL: Keine Uptime

**Interpretation**:
- Kurze Uptime: Kürzlich neu gestartet
- Lange Uptime: Stabil laufend

### 12. Memory Status Test

**Ziel**: Prüfen ob genug Speicher verfügbar ist

**Methode**:
```bash
curl -s "http://<device_ip>/cm?cmnd=Status%200" | grep Heap
```

**Erwartetes Ergebnis**:
- ✅ PASS: Heap > 100 KB
- ⚠️ WARNING: Heap < 100 KB
- ❌ FAIL: Heap < 50 KB

**Fehlerbehandlung**:
- Unnötige Features deaktivieren
- Berry Scripts optimieren
- Gerät Neustart

## Test Durchführung

### Manueller Test

**Einzelnes Gerät**:
```bash
./tests/test-device.sh 192.168.0.75
```

**Alle Geräte**:
```bash
./tests/run-all-tests.sh
```

### Automatisierter Test

**CI/CD Integration** (zukünftig):
```yaml
test:
  script:
    - ./tests/run-all-tests.sh
  only:
    - main
    - develop
```

### Test Ergebnisse

**Ausgabe Format**:
```
[TEST] Test Name
[PASS] Test erfolgreich
[FAIL] Test fehlgeschlagen
[INFO] Zusätzliche Information
```

**Log Datei**:
```
tests/results/test_<ip>_<timestamp>.log
```

**Beispiel**:
```
tests/results/test_192.168.0.75_20260111_123456.log
```

## Test Ergebnisse Interpretation

### Success Rate

**100%**: Alle Tests bestanden
- Gerät voll funktionsfähig
- Keine Probleme erkannt

**90-99%**: Meiste Tests bestanden
- Gerät funktionsfähig
- Kleinere Probleme (z.B. MQTT optional)

**80-89%**: Einige Tests fehlgeschlagen
- Gerät teilweise funktionsfähig
- Probleme müssen behoben werden

**< 80%**: Viele Tests fehlgeschlagen
- Gerät nicht funktionsfähig
- Dringende Probleme

### Typische Fehler

**Sensor nicht erkannt**:
- Verkabelung prüfen
- Pull-up Resistor (DS18B20)
- I2C Adressen (BME280)

**Display bleibt schwarz**:
- Template prüfen
- DisplayMode setzen
- Berry Script hochladen

**MQTT nicht verbunden**:
- Broker Erreichbarkeit
- Credentials
- Firewall

**Niedriger Heap**:
- Zu viele Features
- Berry Script Speicherleck
- Neustart erforderlich

## Test Protokoll

### Test Durchführung Protokoll

**Datum**: 2026-01-11  
**Tester**: Harald Kiessling  
**Firmware Version**: 15.0.1  

#### tasmota-75 (Update Test)

| Test | Ergebnis | Bemerkung |
|------|----------|-----------|
| Device Reachability | ✅ PASS | Ping erfolgreich |
| Web Interface | ✅ PASS | HTTP 200 |
| Tasmota Version | ✅ PASS | 15.0.1 |
| Device Name | ✅ PASS | Tasmota-75 |
| Module Template | ✅ PASS | ESP32S3-Geek |
| WiFi Connection | ✅ PASS | miVida2, RSSI 98 |
| I2C Sensors | ✅ PASS | 0x76, 0x77 |
| Sensor Data | ✅ PASS | BME280-76, BME280-77 |
| Display Config | ✅ PASS | Mode 0 |
| MQTT Status | ✅ PASS | Connected |
| Uptime | ✅ PASS | 11h 36m |
| Memory Status | ✅ PASS | 216 KB |

**Gesamt**: 12/12 (100%)

#### tasmota-77 (Neuinstallation Test)

| Test | Ergebnis | Bemerkung |
|------|----------|-----------|
| Device Reachability | ⏳ PENDING | Noch nicht installiert |
| Web Interface | ⏳ PENDING | Noch nicht installiert |
| Tasmota Version | ⏳ PENDING | Noch nicht installiert |
| Device Name | ⏳ PENDING | Noch nicht installiert |
| Module Template | ⏳ PENDING | Noch nicht installiert |
| WiFi Connection | ⏳ PENDING | Noch nicht installiert |
| I2C Sensors | ℹ️ N/A | DS18B20 verwendet |
| Sensor Data | ⏳ PENDING | Noch nicht installiert |
| Display Config | ⏳ PENDING | Noch nicht installiert |
| MQTT Status | ℹ️ N/A | Optional |
| Uptime | ⏳ PENDING | Noch nicht installiert |
| Memory Status | ⏳ PENDING | Noch nicht installiert |

**Gesamt**: Noch nicht getestet

## Qualitätssicherung

### Akzeptanzkriterien

**Minimum Anforderungen**:
- ✅ Device erreichbar
- ✅ Web Interface funktioniert
- ✅ Korrekte Firmware Version
- ✅ Template konfiguriert
- ✅ Mindestens 1 Sensor funktioniert
- ✅ Display konfiguriert

**Empfohlene Anforderungen**:
- ✅ Alle Sensoren funktionieren
- ✅ Display zeigt Daten
- ✅ MQTT verbunden (falls konfiguriert)
- ✅ Uptime > 1 Stunde
- ✅ Heap > 150 KB

### Regression Tests

Nach jedem Update:
1. Alle Tests erneut durchführen
2. Sensor Daten vergleichen
3. Display Funktion prüfen
4. MQTT Funktion prüfen
5. Performance vergleichen

### Performance Benchmarks

**Sensor Reading**:
- BME280: < 100ms
- DS18B20: < 750ms (12-bit)

**Display Update**:
- Refresh: 5 Sekunden
- Render: < 200ms

**MQTT Publish**:
- Interval: 60 Sekunden
- Latency: < 100ms

**Memory Usage**:
- Free Heap: > 150 KB
- Berry Heap: < 50 KB

## Zusammenfassung

Die Test-Strategie stellt sicher, dass:

1. **Firmware** korrekt funktioniert
2. **Sensoren** Daten liefern
3. **Display** Informationen anzeigt
4. **MQTT** kommuniziert (optional)
5. **System** stabil läuft

Alle Tests sind automatisiert und reproduzierbar.
