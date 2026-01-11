# GPIO Mapping für ESP32S3-Geek

Basierend auf Template von tasmota-75.samharald.eu

## GPIO Konfiguration

| GPIO | Pin | Funktion | Wert | Beschreibung |
|------|-----|----------|------|--------------|
| 0    | 32  | Button 1 | 32   | Taster |
| 6    | 1   | None     | 1    | Nicht verwendet |
| 13   | 1   | None     | 1    | Nicht verwendet |
| 14   | 1   | None     | 1    | Nicht verwendet |
| 16   | 640 | I2C SDA 1| 640  | I2C Datenleitung |
| 17   | 608 | I2C SCL 1| 608  | I2C Taktleitung |
| 22   | 8896| SPI MISO | 8896 | Display SPI |
| 23   | 8960| SPI MOSI | 8960 | Display SPI |
| 24   | 8800| SPI CLK  | 8800 | Display SPI |
| 25   | 8832| SPI CS   | 8832 | Display Chip Select |
| 26   | 8864| SPI DC   | 8864 | Display Data/Command |
| 27   | 8928| Backlight| 8928 | Display Hintergrundbeleuchtung |
| 29   | 6210| LedLink  | 6210 | Status LED |
| 32   | 3200| DS18x20 1| 3200 | Dallas DS18B20 Sensor Bus 1 |
| 33   | 3232| DS18x20 2| 3232 | Dallas DS18B20 Sensor Bus 2 |

## I2C Geräte

- BME280-76: Adresse 0x76 (Temperatur, Luftfeuchtigkeit, Luftdruck)
- BME280-77: Adresse 0x77 (Temperatur, Luftfeuchtigkeit, Luftdruck)

## DS18B20 Sensoren

- GPIO 32: Bis zu 10 DS18B20 Sensoren
- GPIO 33: Bis zu 10 DS18B20 Sensoren
- Zusätzlich GPIO 6, 13, 14 verfügbar für weitere Sensor-Busse

## Display

- Typ: ST7789 TFT Display
- Auflösung: 240x135 Pixel
- Anschluss: SPI (GPIO 22-27)
