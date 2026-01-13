import haspmota
import json
import string

# Startet die HASPmota Engine
haspmota.start()

# Keine parse_value() mehr - verwenden JSON direkt

# Definiert die Treiber-Klasse für zyklische Updates
class SensorDashboard : Driver
    var network_counter
    
    def init()
        self.network_counter = 0
    end
    
    def every_second()
        # Liest alle Sensordaten als JSON-String und parsed sie
        var raw_json = tasmota.read_sensors()
        if raw_json == nil return end
        
        var m = json.load(raw_json)
        if m == nil return end
        
        # --- Header: IP-Adresse und SSID (nur alle 60 Sekunden) ---
        self.network_counter += 1
        if self.network_counter >= 60
            self.network_counter = 0
            
            if global.p1b12 != nil
                var status5 = tasmota.cmd("Status 5", true)
                if status5 != nil && status5.contains("StatusNET")
                    var net = status5["StatusNET"]
                    if net.contains("IPAddress")
                        global.p1b12.text = net["IPAddress"]
                    end
                end
            end
            
            if global.p1b13 != nil
                var status11 = tasmota.cmd("Status 11", true)
                if status11 != nil && status11.contains("StatusSTS")
                    var sts = status11["StatusSTS"]
                    if sts.contains("Wifi") && sts["Wifi"].contains("SSId")
                        global.p1b13.text = sts["Wifi"]["SSId"]
                    end
                end
            end
        end
        
        # --- Header: Uhrzeit (jede Sekunde) ---
        if global.p1b14 != nil
            var rtc = tasmota.rtc()
            if rtc != nil && rtc.contains('local')
                global.p1b14.text = tasmota.strftime("%H:%M:%S", rtc['local'])
            end
        end
        
        # --- BME280 Sensoren zweispaltig (p1b30-p1b31) nur Temperatur ---
        var bme_count = 0
        var bme_labels = [global.p1b30, global.p1b31]
        
        # Durchsuche alle Keys nach BME280-*
        for key: m.keys()
            if bme_count >= 2 break end
            if string.find(key, 'BME280') == 0
                var sensor = m[key]
                if sensor.contains('Temperature')
                    var temp = sensor['Temperature']
                    if bme_labels[bme_count] != nil
                        # Extrahiere nur die letzten 2 Zeichen (I2C-Adresse: 76 oder 77)
                        var addr = key[size(key)-2..]
                        bme_labels[bme_count].text = string.format("%s %.1f°C", addr, temp)
                        bme_count += 1
                    end
                end
            end
        end
        
        # Leere restliche BME Labels
        while bme_count < 2
            if bme_labels[bme_count] != nil
                bme_labels[bme_count].text = ""
            end
            bme_count += 1
        end
        
        # --- DS18x20 Sensoren (p1b20-p1b29) ---
        var ds_labels = [
            global.p1b20, global.p1b21,
            global.p1b22, global.p1b23,
            global.p1b24, global.p1b25,
            global.p1b26, global.p1b27,
            global.p1b28, global.p1b29
        ]
        
        var ds_count = 0
        
        # DS18B20-1
        if m.contains('DS18B20-1') && ds_count < 10
            var sensor = m['DS18B20-1']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-2
        if m.contains('DS18B20-2') && ds_count < 10
            var sensor = m['DS18B20-2']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-3
        if m.contains('DS18B20-3') && ds_count < 10
            var sensor = m['DS18B20-3']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-4
        if m.contains('DS18B20-4') && ds_count < 10
            var sensor = m['DS18B20-4']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-5
        if m.contains('DS18B20-5') && ds_count < 10
            var sensor = m['DS18B20-5']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-6
        if m.contains('DS18B20-6') && ds_count < 10
            var sensor = m['DS18B20-6']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-7
        if m.contains('DS18B20-7') && ds_count < 10
            var sensor = m['DS18B20-7']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-8
        if m.contains('DS18B20-8') && ds_count < 10
            var sensor = m['DS18B20-8']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-9
        if m.contains('DS18B20-9') && ds_count < 10
            var sensor = m['DS18B20-9']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # DS18B20-10
        if m.contains('DS18B20-10') && ds_count < 10
            var sensor = m['DS18B20-10']
            var id = sensor['Id']
            var temp = sensor['Temperature']
            var short_id = id[8..11]
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = string.format("..%s %.1f°C", short_id, temp)
            end
            ds_count += 1
        end
        
        # Leere restliche DS Labels
        while ds_count < 10
            if ds_labels[ds_count] != nil
                ds_labels[ds_count].text = ""
            end
            ds_count += 1
        end
    end
    
    # Initiale Netzwerk-Abfrage beim Start
    def update_network()
        if global.p1b12 != nil
            var status5 = tasmota.cmd("Status 5", true)
            if status5 != nil && status5.contains("StatusNET")
                var net = status5["StatusNET"]
                if net.contains("IPAddress")
                    global.p1b12.text = net["IPAddress"]
                end
            end
        end
        
        if global.p1b13 != nil
            var status11 = tasmota.cmd("Status 11", true)
            if status11 != nil && status11.contains("StatusSTS")
                var sts = status11["StatusSTS"]
                if sts.contains("Wifi") && sts["Wifi"].contains("SSId")
                    global.p1b13.text = sts["Wifi"]["SSId"]
                end
            end
        end
    end
end

# Globale Instanz des Dashboards
global.dashboard = SensorDashboard()

# Registriere den Driver
tasmota.add_driver(global.dashboard)

# Zusätzlich: Cron-Job als Backup (läuft jede Sekunde)
tasmota.add_cron("*/1 * * * * *", /-> global.dashboard.every_second(), "sensor_update")

# Initiale Netzwerk-Abfrage nach 10 Sekunden (damit WLAN verbunden ist)
tasmota.set_timer(10000, /-> global.dashboard.update_network())
