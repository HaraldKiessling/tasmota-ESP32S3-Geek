import haspmota
import json
import string

# Startet die HASPmota Engine
haspmota.start()

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
        
        # --- DS18x20 Sensoren (p1b20-p1b29) DYNAMISCH ---
        var ds_labels = [
            global.p1b20, global.p1b21,
            global.p1b22, global.p1b23,
            global.p1b24, global.p1b25,
            global.p1b26, global.p1b27,
            global.p1b28, global.p1b29
        ]
        
        var ds_count = 0
        
        # Sammle alle DS18B20/DS18S20 Sensoren dynamisch
        var ds_sensors = []
        for key: m.keys()
            if string.find(key, 'DS18B20') == 0 || string.find(key, 'DS18S20') == 0
                var sensor = m[key]
                if sensor.contains('Temperature') && sensor.contains('Id')
                    ds_sensors.push({
                        'key': key,
                        'id': sensor['Id'],
                        'temp': sensor['Temperature']
                    })
                end
            end
        end
        
        # Sortiere Sensoren alphabetisch nach Key für konsistente Anzeige
        var i = 1
        while i < size(ds_sensors)
            var j = i
            while j > 0 && ds_sensors[j-1]['key'] > ds_sensors[j]['key']
                var temp = ds_sensors[j]
                ds_sensors[j] = ds_sensors[j-1]
                ds_sensors[j-1] = temp
                j -= 1
            end
            i += 1
        end
        
        # Zeige alle gefundenen DS18B20 Sensoren an
        for sensor: ds_sensors
            if ds_count >= 10 break end
            
            var id = sensor['id']
            var temp = sensor['temp']
            
            # Verwende die letzten 4 Zeichen der ID (wie im Original)
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
end

# Globale Instanz
global.dashboard = SensorDashboard()

# Registriere Driver
tasmota.add_driver(global.dashboard)
