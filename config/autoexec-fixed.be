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
        
        # DS18B20 Sensors - iterate through all sensor keys
        var ds_count = 0
        for key: sensors.keys()
            if string.find(key, "DS18B20") == 0 && ds_count < 3
                var sensor = sensors[key]
                if type(sensor) == 'instance' && sensor.contains("Temperature")
                    var temp = sensor["Temperature"]
                    var sensor_id = sensor.find("Id", "")
                    # Extract last 4 chars of ID for display
                    var short_id = ""
                    if size(sensor_id) >= 4
                        short_id = sensor_id[-4..]
                    end
                    lines.push(string.format("[x0y%d][f1]DS%s: %.1fC", y_pos, short_id, temp))
                    y_pos += 15
                    ds_count += 1
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
