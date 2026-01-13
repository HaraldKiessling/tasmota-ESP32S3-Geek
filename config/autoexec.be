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
    
    # Hilfsfunktion um HASPmota-Objekte zu holen
    def get_obj(name)
        return global.(name)
    end
    
    def every_second()
        # --- Header: IP-Adresse und SSID (nur alle 60 Sekunden) ---
        self.network_counter += 1
        if self.network_counter >= 60
            self.network_counter = 0
            
            var lbl_ip = self.get_obj('p1b12')
            if lbl_ip != nil
                var status5 = tasmota.cmd("Status 5", true)
                if status5 != nil && status5.contains("StatusNET")
                    var net = status5["StatusNET"]
                    if net.contains("IPAddress")
                        lbl_ip.text = net["IPAddress"]
                    end
                end
            end
            
            var lbl_ssid = self.get_obj('p1b13')
            if lbl_ssid != nil
                var status11 = tasmota.cmd("Status 11", true)
                if status11 != nil && status11.contains("StatusSTS")
                    var sts = status11["StatusSTS"]
                    if sts.contains("Wifi") && sts["Wifi"].contains("SSId")
                        lbl_ssid.text = sts["Wifi"]["SSId"]
                    end
                end
            end
        end
        
        # --- Header: Uhrzeit (jede Sekunde) ---
        var lbl_time = self.get_obj('p1b14')
        if lbl_time != nil
            var rtc = tasmota.rtc()
            if rtc != nil && rtc.contains('local')
                lbl_time.text = tasmota.strftime("%H:%M:%S", rtc['local'])
            end
        end
        
        # --- Sensordaten lesen (optional - funktioniert auch ohne Sensoren) ---
        var raw_json = tasmota.read_sensors()
        if raw_json == nil return end
        
        var m = json.load(raw_json)
        if m == nil return end
        
        # --- BME280 Sensoren zweispaltig (p1b30-p1b31) nur Temperatur ---
        var bme_count = 0
        var bme_labels = [self.get_obj('p1b30'), self.get_obj('p1b31')]
        
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
            self.get_obj('p1b20'), self.get_obj('p1b21'),
            self.get_obj('p1b22'), self.get_obj('p1b23'),
            self.get_obj('p1b24'), self.get_obj('p1b25'),
            self.get_obj('p1b26'), self.get_obj('p1b27'),
            self.get_obj('p1b28'), self.get_obj('p1b29')
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

# Initiale Netzwerk-Abfrage nach 5 Sekunden (damit WLAN verbunden ist)
tasmota.set_timer(5000, def ()
    var d = global.dashboard
    if d == nil return end
    
    var lbl_ip = d.get_obj('p1b12')
    if lbl_ip != nil
        var status5 = tasmota.cmd("Status 5", true)
        if status5 != nil && status5.contains("StatusNET")
            var net = status5["StatusNET"]
            if net.contains("IPAddress")
                lbl_ip.text = net["IPAddress"]
            end
        end
    end
    
    var lbl_ssid = d.get_obj('p1b13')
    if lbl_ssid != nil
        var status11 = tasmota.cmd("Status 11", true)
        if status11 != nil && status11.contains("StatusSTS")
            var sts = status11["StatusSTS"]
            if sts.contains("Wifi") && sts["Wifi"].contains("SSId")
                lbl_ssid.text = sts["Wifi"]["SSId"]
            end
        end
    end
end)
