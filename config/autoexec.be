import json
import string

# Display Dashboard ohne HASPmota - verwendet DisplayText
class SensorDashboard : Driver
    var network_counter
    var display_y
    
    def init()
        self.network_counter = 0
        self.display_y = 0
        # Clear display
        tasmota.cmd("DisplayText [z]")
    end
    
    def every_second()
        # Liest alle Sensordaten als JSON-String
        var raw_json = tasmota.read_sensors()
        if raw_json == nil return end
        
        var m = json.load(raw_json)
        if m == nil return end
        
        # Update network info every 60 seconds
        self.network_counter += 1
        if self.network_counter >= 60
            self.network_counter = 0
            self.update_display(m)
        end
    end
    
    def update_display(sensors)
        # Clear display
        tasmota.cmd("DisplayText [z]")
        
        var y = 0
        
        # Header: IP Address
        var status5 = tasmota.cmd("Status 5", true)
        if status5 != nil && status5.contains("StatusNET")
            var net = status5["StatusNET"]
            if net.contains("IPAddress")
                var ip = net["IPAddress"]
                tasmota.cmd(string.format("DisplayText [x0y%d]%s", y, ip))
                y += 15
            end
        end
        
        # Header: SSID
        var status11 = tasmota.cmd("Status 11", true)
        if status11 != nil && status11.contains("StatusSTS")
            var sts = status11["StatusSTS"]
            if sts.contains("Wifi") && sts["Wifi"].contains("SSId")
                var ssid = sts["Wifi"]["SSId"]
                tasmota.cmd(string.format("DisplayText [x0y%d]%s", y, ssid))
                y += 15
            end
        end
        
        # Time
        var rtc = tasmota.rtc()
        if rtc != nil && rtc.contains('local')
            var time_str = tasmota.strftime("%H:%M:%S", rtc['local'])
            tasmota.cmd(string.format("DisplayText [x0y%d]%s", y, time_str))
            y += 15
        end
        
        # DS18B20 Sensors
        for key: sensors.keys()
            if string.find(key, 'DS18B20') == 0
                var sensor = sensors[key]
                if sensor.contains('Temperature') && sensor.contains('Id')
                    var temp = sensor['Temperature']
                    var id = sensor['Id']
                    var short_id = id[8..11]
                    var line = string.format("..%s %.1fC", short_id, temp)
                    tasmota.cmd(string.format("DisplayText [x0y%d]%s", y, line))
                    y += 15
                    if y > 120 break end
                end
            end
        end
    end
end

# Globale Instanz
global.dashboard = SensorDashboard()

# Registriere Driver
tasmota.add_driver(global.dashboard)

# Initial update nach 10 Sekunden
tasmota.set_timer(10000, /-> global.dashboard.update_display(json.load(tasmota.read_sensors())))
