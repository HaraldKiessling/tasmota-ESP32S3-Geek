# Backup: tasmota-78 Konfiguration

**Datum**: 2026-01-12 23:25 UTC  
**Gerät**: tasmota-78 (ESP32-S3 Geek)  
**URL**: https://tasmota-78.samharald.eu  
**Status**: ✅ Funktionierend

---

## Firmware

**Version**: 15.2.0(tasmota32s3-lvgl)  
**Build**: 2026-01-12T16:22:50  
**Core**: ESP32 Arduino 3.3.4  
**SDK**: 5.3.4.251205  
**Hardware**: ESP32-S3 v0.2 mit PSRAM

**Datei**: `tasmota-78-firmware-15.2.0-fixed.factory.bin` (3.5 MB)

### Flash-Befehl:
```bash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z 0x0 tasmota-78-firmware-15.2.0-fixed.factory.bin
```

---

## GPIO Template

**Datei**: `tasmota-78-template.txt`

### Console Befehle:
```
Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
Restart 1
```

### GPIO Mapping:
```
GPIO 0:  User
GPIO 6:  DS18x20 (Sensor 1)
GPIO 13: DS18x20 (Sensor 2)
GPIO 14: User
GPIO 16: I2C SDA
GPIO 17: I2C SCL
GPIO 22-27: Option A1-A6
GPIO 29: TuyaSend
GPIO 32: Output Hi
GPIO 33: Output Lo
```

---

## display.ini

**Datei**: `tasmota-78-display.ini` (244 bytes)

**Wichtig**: Diese spezifische display.ini funktioniert mit v15.2.0!

### Inhalt:
```ini
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40 
:S,2,1,3,0,80,30
:I,01,A0,11,A0,3A,81,55,36,81,00,21,80,13,80,29,A0
:o,28
:O,29
:A,2A,2B,2C
:R,36
:0,C0,35,28,00
:1,A0,28,34,01
:2,00,34,28,02
:3,60,28,35,03
:i,21,20
:B,30,5
#
```

### Upload:
1. Gehe zu https://tasmota-78.samharald.eu/ufsd
2. Upload `tasmota-78-display.ini` als `display.ini`
3. Restart

---

## autoexec.be

**Datei**: `tasmota-78-autoexec.be`

Berry Script für Display-Automation und Sensor-Anzeige.

### Upload:
1. Gehe zu https://tasmota-78.samharald.eu/ufsd
2. Upload `tasmota-78-autoexec.be` als `autoexec.be`
3. Restart

---

## pages.jsonl

**Datei**: `tasmota-78-pages.jsonl`

HASPmota Display-Seiten Konfiguration.

### Upload:
1. Gehe zu https://tasmota-78.samharald.eu/ufsd
2. Upload `tasmota-78-pages.jsonl` als `pages.jsonl`
3. Restart

---

## Netzwerk

**Hostname**: tasmota32s3-lvgl-7360  
**IP**: 192.168.0.78  
**WiFi SSID**: miVida2  
**WiFi Channel**: 5  
**RSSI**: 100 (Signal: -19 dBm)

---

## Sensoren

### DS18B20 Temperatursensoren:

**Sensor 1**:
- ID: 0000005329E2
- GPIO: 6
- Typ: DS18B20

**Sensor 2**:
- ID: 00000051C76D
- GPIO: 13
- Typ: DS18B20

### I2C Bus:
- SDA: GPIO 16
- SCL: GPIO 17

---

## Wiederherstellung

### Komplette Wiederherstellung:

1. **Flash Firmware**:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 \
     write_flash -z 0x0 tasmota-78-firmware-15.2.0-fixed.factory.bin
   ```

2. **WiFi konfigurieren**:
   - Verbinde mit AP `tasmota-XXXXXX`
   - Öffne http://192.168.4.1
   - WiFi Credentials eingeben

3. **GPIO Template anwenden**:
   ```
   Template {"NAME":"ESP32S3-Geek","GPIO":[32,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,640,608,0,0,0,0,8896,8960,8800,8832,8864,8928,0,6210,0,0,3200,3232,0,0,0,0],"FLAG":0,"BASE":1}
   Module 0
   Restart 1
   ```

4. **Dateien hochladen**:
   - display.ini
   - autoexec.be
   - pages.jsonl

5. **Neustart**:
   ```
   Restart 1
   ```

6. **Verifizieren**:
   - Display zeigt Informationen
   - Sensoren werden angezeigt
   - Keine Crashes

---

## Bekannte Probleme

### Display.ini ist kritisch!

**⚠️ Wichtig**: Nur diese spezifische display.ini verwenden!

Andere display.ini Varianten verursachen:
- Pixel-Schneegestöber
- Dunkles Display
- Boot-Loops und Crashes

### v15.2.0 ist empfindlich

v15.2.0 ist empfindlicher als v15.0.1 bei der Konfiguration.

**Alternative**: Bei Problemen auf v15.0.1 downgraden.

---

## Backup-Dateien

```
backups/
├── tasmota-78-config.json                    # Vollständige Konfiguration
├── tasmota-78-template.txt                   # GPIO Template
├── tasmota-78-display.ini                    # Display Konfiguration
├── tasmota-78-autoexec.be                    # Berry Script
├── tasmota-78-pages.jsonl                    # HASPmota Seiten
├── tasmota-78-firmware-15.2.0-fixed.factory.bin  # Firmware
└── TASMOTA-78-BACKUP-README.md               # Diese Datei
```

---

## Vergleich mit anderen Geräten

### tasmota-75, 77, 101:
- **Firmware**: v15.0.1
- **Status**: Stabil, funktionierend
- **Empfehlung**: Bei v15.0.1 bleiben

### tasmota-78:
- **Firmware**: v15.2.0-fixed
- **Status**: Funktionierend mit spezieller display.ini
- **Empfehlung**: Konfiguration nicht ändern

---

## Notizen

- Display funktioniert mit v15.2.0-fixed und der alten display.ini
- Andere display.ini Varianten verursachen Probleme
- v15.0.1 ist stabiler und toleranter
- Backup regelmäßig aktualisieren

---

**Backup erstellt**: 2026-01-12 23:25 UTC  
**Nächstes Backup**: Bei Änderungen  
**Status**: ✅ Vollständig
