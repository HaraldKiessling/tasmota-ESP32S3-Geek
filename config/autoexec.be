# autoexec.be - Berry script for ESP32S3-Geek
# Automatic display update with sensor data, IP, SSID, and time

import string
import json

class DisplayUpdate
    var display_timer
    
    def init()
        print("ESP32S3-Geek Display Update initialized")
        self.display_timer = tasmota.set_timer(5000, /-> self.update_display(), true)
    end
    
    def update_display()
        var sensors = json.load(tasmota.read_sensors())
        var wifi = tasmota.wifi()
        var time = tasmota.time_str(tasmota.rtc()['local'])
        
        var lines = []
        
        # Header with device name
        lines.push("[z]")  # Clear display
        lines.push("[x0y0][f1]ESP32S3-Geek")
        
        # WiFi Info
        var ssid = wifi.find("SSId", "N/A")
        var ip = wifi.find("IP", "N/A")
        lines.push("[x0y20][f1]SSID: " + ssid)
        lines.push("[x0y35][f1]IP: " + ip)
        
        # Time
        lines.push("[x0y50][f1]" + time)
        
        # Sensors
        var y_pos = 70
        
        # BME280 Sensors
        if sensors.contains("BME280-76")
            var bme76 = sensors["BME280-76"]
            lines.push(string.format("[x0y%d][f1]BME76: %.1fC %.0f%%", y_pos, bme76.find("Temperature", 0), bme76.find("Humidity", 0)))
            y_pos += 15
        end
        
        if sensors.contains("BME280-77")
            var bme77 = sensors["BME280-77"]
            lines.push(string.format("[x0y%d][f1]BME77: %.1fC %.0f%%", y_pos, bme77.find("Temperature", 0), bme77.find("Humidity", 0)))
            y_pos += 15
        end
        
        # DS18B20 Sensors
        if sensors.contains("DS18B20")
            var ds_sensors = sensors["DS18B20"]
            if type(ds_sensors) == 'instance'
                # Single sensor
                var temp = ds_sensors.find("Temperature", 0)
                var id = ds_sensors.find("Id", "")
                lines.push(string.format("[x0y%d][f1]DS: %.1fC", y_pos, temp))
                y_pos += 15
            else
                # Multiple sensors
                var sensor_count = 0
                for key: ds_sensors.keys()
                    if sensor_count >= 3  # Limit to 3 DS18B20 sensors on display
                        break
                    end
                    var sensor = ds_sensors[key]
                    if type(sensor) == 'instance' && sensor.contains("Temperature")
                        var temp = sensor["Temperature"]
                        lines.push(string.format("[x0y%d][f1]DS%d: %.1fC", y_pos, sensor_count + 1, temp))
                        y_pos += 15
                        sensor_count += 1
                    end
                end
            end
        end
        
        # Send to display
        var display_text = ""
        for line: lines
            display_text += line
        end
        
        tasmota.cmd("DisplayText " + display_text)
    end
end

# Start display update
var display_update = DisplayUpdate()
