# Display Konfiguration für ESP32S3-Geek

## Hardware
- Display: ST7789 TFT
- Auflösung: 240x135 Pixel
- Anschluss: SPI (GPIO 22-27)

## Tasmota Display Befehle

### Basis Konfiguration
```
DisplayMode 0          # 0 = User mode (Berry script control)
DisplayRotate 1        # Display Rotation (0-3)
DisplayCols 30         # Anzahl Spalten
DisplayRows 8          # Anzahl Zeilen
DisplayFont 1          # Font Größe (1-4)
DisplayDimmer 100      # Helligkeit (0-100)
```

### Display Text Befehle

#### Format
```
DisplayText [Befehle]Text
```

#### Befehle
- `[z]` - Display löschen
- `[x<pos>]` - X Position setzen (0-239)
- `[y<pos>]` - Y Position setzen (0-134)
- `[f<size>]` - Font Größe (1-4)
- `[c<color>]` - Farbe setzen (RGB565)
- `[l<line>]` - Zeile setzen (1-8)
- `[p<col>]` - Spalte setzen (1-30)

#### Farben (RGB565)
- Weiß: 65535
- Schwarz: 0
- Rot: 63488
- Grün: 2016
- Blau: 31
- Gelb: 65504
- Cyan: 2047
- Magenta: 63519

## Display Layout

### Zeile 1 (y=0): Header
```
ESP32S3-Geek
```

### Zeile 2-3 (y=20-35): WiFi Info
```
SSID: <WiFi Name>
IP: <IP Adresse>
```

### Zeile 4 (y=50): Zeit
```
<Datum> <Uhrzeit>
```

### Zeile 5-8 (y=70+): Sensoren
```
BME76: <Temp>°C <Hum>%
BME77: <Temp>°C <Hum>%
DS1: <Temp>°C
DS2: <Temp>°C
...
```

## Berry Script Integration

Das autoexec.be Script aktualisiert das Display automatisch alle 5 Sekunden mit:
- Device Name
- WiFi SSID und IP
- Aktuelle Zeit
- BME280 Sensordaten (Temperatur, Luftfeuchtigkeit)
- DS18B20 Sensordaten (bis zu 3 auf Display)

## Manuelle Display Tests

### Test 1: Display löschen
```
DisplayText [z]
```

### Test 2: Text anzeigen
```
DisplayText [z][x0y0][f2]Hello World
```

### Test 3: Sensor Daten
```
DisplayText [z][x0y0][f1]Temp: 22.5C
```

### Test 4: Mehrere Zeilen
```
DisplayText [z][x0y0][f1]Line 1[x0y20]Line 2[x0y40]Line 3
```
