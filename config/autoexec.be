import json
import string

# Display Dashboard mit DisplayText - zeigt IP, SSID, Zeit, WiFi, BME280, DS18B20
class SensorDashboard : Driver
    var network_counter
    var sensor_counter
    var last_time
    var last_ip
    var last_ssid
    var last_rssi
    
    def init()
        self.network_counter = 0
        self.sensor_counter = 0
        self.last_time = ""
        self.last_ip = ""
        self.last_ssid = ""
        self.last_rssi = 0
        
        # Clear display
        tasmota.cmd("DisplayText [z]")
        
        # Initial update nach 5 Sekunden
        tasmota.set_timer(5000, /-> self.update_all())
    end
    
    def every_second()
        # Update Zeit jede Sekunde
        self.update_time()
        
        # Update Sensoren alle 5 Sekunden
        self.sensor_counter += 1
        if self.sensor_counter >= 5
            self.sensor_counter = 0
            self.update_sensors()
        end
        
        # Update Netzwerk alle 60 Sekunden
        self.network_counter += 1
        if self.network_counter >= 60
            self.network_counter = 0
            self.update_network()
        end
    end
    
    def update_time()
        var rtc = tasmota.rtc()
        if rtc != nil && rtc.contains('local')
            var time_str = tasmota.strftime("%H:%M:%S", rtc['local'])
            if time_str != self.last_time
                self.last_time = time_str
                # Zeit an Position (155, 4) - rechts oben
                tasmota.cmd(string.format("DisplayText [s1x155y4]%s", time_str))
            end
        end
    end
    
    def update_network()
        # IP Address
        var status5 = tasmota.cmd("Status 5", true)
        if status5 != nil && status5.contains("StatusNET")
            var net = status5["StatusNET"]
            if net.contains("IPAddress")
                var ip = net["IPAddress"]
                if ip != self.last_ip
                    self.last_ip = ip
                    # IP an Position (3, 4) - links oben
                    tasmota.cmd(string.format("DisplayText [s1x3y4]%s", ip))
                end
            end
        end
        
        # SSID und RSSI
        var status11 = tasmota.cmd("Status 11", true)
        if status11 != nil && status11.contains("StatusSTS")
            var sts = status11["StatusSTS"]
            if sts.contains("Wifi")
                var wifi = sts["Wifi"]
                if wifi.contains("SSId")
                    var ssid = wifi["SSId"]
                    if ssid != self.last_ssid
                        self.last_ssid = ssid
                        # SSID an Position (92, 4) - mitte oben
                        tasmota.cmd(string.format("DisplayText [s1x92y4]%s", ssid))
                    end
                end
                if wifi.contains("RSSI")
                    var rssi = wifi["RSSI"]
                    if rssi != self.last_rssi
                        self.last_rssi = rssi
                        # WiFi Signal als Text (215, 4) - rechts oben neben Zeit
                        # RSSI: 100=excellent, 80=good, 60=fair, <60=poor
                        var signal = "?"
                        if rssi >= 80 signal = "***"
                        elif rssi >= 60 signal = "** "
                        elif rssi >= 40 signal = "*  "
                        else signal = "   "
                        end
                        tasmota.cmd(string.format("DisplayText [s1x215y4]%s", signal))
                    end
                end
            end
        end
    end
    
    def update_sensors()
        var raw_json = tasmota.read_sensors()
        if raw_json == nil return end
        
        var m = json.load(raw_json)
        if m == nil return end
        
        var y = 29  # Start position for sensors (after header)
        
        # --- BME280 Sensoren (gelb) - 2 Spalten ---
        var bme_count = 0
        var bme_x = [5, 125]  # Linke und rechte Spalte
        
        for key: m.keys()
            if bme_count >= 2 break end
            if string.find(key, 'BME280') == 0
                var sensor = m[key]
                if sensor.contains('Temperature')
                    var temp = sensor['Temperature']
                    # Extrahiere I2C-Adresse (76 oder 77)
                    var addr = key[size(key)-2..]
                    var text = string.format("%s %.1fC", addr, temp)
                    # Gelbe Farbe für BME280
                    tasmota.cmd(string.format("DisplayText [s1x%dy%d]%s", bme_x[bme_count], y, text))
                    bme_count += 1
                end
            end
        end
        
        # Leere restliche BME Labels
        while bme_count < 2
            tasmota.cmd(string.format("DisplayText [s1x%dy%d]          ", bme_x[bme_count], y))
            bme_count += 1
        end
        
        y += 15  # Nächste Zeile
        
        # --- DS18B20 Sensoren (weiß) - 2 Spalten, bis zu 10 Sensoren ---
        var ds_count = 0
        var ds_x = [5, 125]  # Linke und rechte Spalte
        var ds_y = y
        
        # Durchsuche alle DS18B20 Sensoren
        for key: m.keys()
            if ds_count >= 10 break end
            if string.find(key, 'DS18B20') == 0 || string.find(key, 'DS18S20') == 0
                var sensor = m[key]
                if sensor.contains('Temperature') && sensor.contains('Id')
                    var temp = sensor['Temperature']
                    var id = sensor['Id']
                    # Verwende die letzten 4 Zeichen der ID
                    var short_id = id[size(id)-4..]
                    var text = string.format("..%s %.1fC", short_id, temp)
                    
                    # Position berechnen: 2 Spalten
                    var col = ds_count % 2
                    var row = ds_count / 2
                    var x = ds_x[col]
                    var y_pos = ds_y + (row * 15)
                    
                    tasmota.cmd(string.format("DisplayText [s1x%dy%d]%s", x, y_pos, text))
                    ds_count += 1
                end
            end
        end
        
        # Leere restliche DS Labels
        while ds_count < 10
            var col = ds_count % 2
            var row = ds_count / 2
            var x = ds_x[col]
            var y_pos = ds_y + (row * 15)
            tasmota.cmd(string.format("DisplayText [s1x%dy%d]          ", x, y_pos))
            ds_count += 1
        end
    end
    
    def update_all()
        self.update_network()
        self.update_time()
        self.update_sensors()
    end
end

# Globale Instanz
global.dashboard = SensorDashboard()

# Registriere Driver
tasmota.add_driver(global.dashboard)
