# autoexec.be - Berry script for ESP32S3-Geek with pages.jsonl support
# Automatic display update with sensor data, IP, SSID, and time

import string
import json

class DisplayUpdate
    var display_timer
    
    def init()
        print("ESP32S3-Geek Display Update initialized")
        # Update every 5 seconds
        self.display_timer = tasmota.set_timer(5000, /-> self.update_display(), true)
        # Initial update
        self.update_display()
    end
    
    def update_display()
        var sensors = json.load(tasmota.read_sensors())
        var wifi = tasmota.wifi()
        var time_str = tasmota.time_str(tasmota.rtc()['local'])
        
        # Build display text
        var txt = "[z]"  # Clear display
        txt += "[x0y0][f1]ESP32S3-Geek"
        
        # WiFi Info
        var ssid = wifi.find("SSId", "N/A")
        var ip = wifi.find("IP", "N/A")
        txt += "[x0y15][f1]SSID: " + ssid
        txt += "[x0y30][f1]IP: " + ip
        
        # Time
        txt += "[x0y45][f1]" + time_str
        
        # DS18B20 Sensors
        var y = 65
        var ds_count = 0
        for key: sensors.keys()
            if string.find(key, "DS18B20") == 0 && ds_count < 2
                var s = sensors[key]
                if type(s) == 'instance' && s.contains("Temperature")
                    var temp = s["Temperature"]
                    var id = s.find("Id", "")
                    # Extract last 4 chars of ID
                    var short_id = size(id) >= 4 ? id[-4..] : id
                    txt += string.format("[x0y%d][f1]DS-%s: %.1fC", y, short_id, temp)
                    y += 15
                    ds_count += 1
                end
            end
        end
        
        # Send to display
        tasmota.cmd("DisplayText " + txt)
    end
end

# Start display update
var display_update = DisplayUpdate()
print("Display update started")
