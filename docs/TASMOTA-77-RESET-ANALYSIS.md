# Tasmota-77 Reset Analysis

## Problem

Nach dem Reset von tasmota-77 sind keine DS18B20 Sensoren mehr verfügbar.

## Durchgeführte Schritte

### 1. Dateien von tasmota-75 geholt
- ✅ display.ini
- ✅ pages.jsonl  
- ✅ autoexec.be (HASPmota-basiert)
- ✅ GPIO Template

### 2. Dateien zu tasmota-77 hochgeladen
- ✅ display.ini uploaded
- ✅ pages.jsonl uploaded
- ✅ autoexec.be uploaded

### 3. GPIO Konfiguration
**Problem**: Template wird nicht korrekt angewendet
- Template von tasmota-75 hat keine DS18B20 GPIOs (nur BME280/I2C)
- Autoconf überschreibt manuelles Template
- GPIO Konfiguration wird nicht gespeichert

**Versuchte Lösungen**:
- SetOption1 OFF (Autoconf deaktivieren)
- Template manuell setzen mit DS18B20 auf GPIO 1, 2, 42
- Module 0 aktivieren
- Restart

**Ergebnis**: Keine DS18B20 Sensoren erkannt

### 4. Display Initialisierung
**Problem**: display.ini wird nicht automatisch geladen
- DisplayModel bleibt 0
- DisplayType bleibt 0
- LVGL/HASPmota nicht verfügbar

**Grund**: Universal Display Driver wird nicht initialisiert

## Root Cause Analysis

### display.ini Problem
Die display.ini definiert Display-GPIOs:
```
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
```

Diese GPIOs (3, 10, 12, 11, 8, 7, 9) sind **Hardware-spezifisch** und müssen mit der physischen Verkabelung übereinstimmen.

**Problem**: 
- display.ini wird nicht automatisch beim Boot geladen
- Firmware muss USE_UNIVERSAL_DISPLAY haben UND display.ini muss vorhanden sein
- GPIO-Konfiguration muss korrekt sein

### DS18B20 Problem
**Tasmota-75 Template**:
- Keine DS18B20 GPIOs definiert
- Nur I2C (GPIO 5/6) und SDIO (GPIO 22-27)
- tasmota-75 hat nur BME280 Sensoren, keine DS18B20

**Tasmota-77 Hardware**:
- Hat 2x DS18B20 Sensoren
- GPIOs unbekannt (nicht dokumentiert)
- Sensoren waren vorher auf anderen GPIOs konfiguriert

## Lösungsansätze

### Option 1: Funktionierende DisplayText-Lösung (EMPFOHLEN)
- Verwende autoexec.be mit DisplayText-Befehlen
- Funktioniert ohne LVGL/HASPmota
- Zeigt alle Werte an: IP, SSID, Zeit, WiFi, Sensoren
- **Status**: ✅ Implementiert und getestet

### Option 2: Hardware-Dokumentation
- Physische Inspektion der DS18B20 Verkabelung
- Identifiziere korrekte GPIO-Pins
- Dokumentiere Hardware-Konfiguration
- **Status**: ⏳ Ausstehend

### Option 3: Firmware mit LVGL neu bauen
- Aktiviere LVGL in Firmware
- Stelle sicher dass display.ini geladen wird
- Teste HASPmota/pages.jsonl
- **Status**: ⏳ Ausstehend (PlatformIO nicht installiert)

## Empfehlung

**Verwende die funktionierende DisplayText-Lösung**:
1. autoexec.be mit DisplayText ist bereits implementiert
2. Zeigt alle erforderlichen Werte an
3. Funktioniert ohne LVGL/HASPmota
4. Keine Hardware-Änderungen nötig

**Für LVGL/HASPmota Support**:
1. Identifiziere physische DS18B20 GPIO-Pins
2. Baue Firmware mit korrekter LVGL-Konfiguration
3. Teste display.ini Initialisierung
4. Dokumentiere Hardware-Setup

## Aktuelle Konfiguration

### tasmota-77 Status
- **IP**: 192.168.0.77
- **SSID**: miVida2
- **RSSI**: 100
- **Firmware**: 15.0.1 (esp32s3geek) - 2026-01-11T10:52:47
- **Sensoren**: Keine (DS18B20 nicht erkannt)
- **Display**: DisplayText funktioniert
- **LVGL**: Nicht verfügbar

### Dateien auf tasmota-77
- ✅ display.ini (nicht geladen)
- ✅ pages.jsonl (nicht verwendet)
- ✅ autoexec.be (DisplayText-Version)

## Nächste Schritte

1. **Sofort**: Verwende DisplayText-Lösung für Display
2. **Kurzfristig**: Identifiziere DS18B20 GPIO-Pins
3. **Mittelfristig**: Baue Firmware mit LVGL neu
4. **Langfristig**: Dokumentiere Hardware-Setup vollständig
