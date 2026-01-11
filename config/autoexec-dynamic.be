# Dynamic autoexec.be - automatically finds and displays all DS18B20 sensors
import haspmota
import json
import string

# Start HASPmota
haspmota.start()

# Dashboard class with dynamic sensor detection
class SensorDashboard : Driver
    var sensor_counter
    var last_sensors
    
    def init()
        self.sensor_counter = 0
        self.last_sensors = {}
        print("SensorDashboard initialized - dynamic DS18B20 detection")
    end
    
    def every_second()
        # Update sensors every 2 seconds
        self.sensor_counter += 1
        if self.sensor_counter >= 2
            self.sensor_counter = 0
            self.update_sensors()
        end
    end
    
    def update_sensors()
        # Read all sensor data
        var raw_json = tasmota.read_sensors()
        if raw_json == nil return end
        
        var sensors = json.load(raw_json)
        if sensors == nil return end
        
        # Find all DS18B20 sensors dynamically
        var ds_sensors = []
        for key: sensors.keys()
            if string.find(key, 'DS18B20') == 0 || string.find(key, 'DS18S20') == 0
                var sensor = sensors[key]
                if sensor.contains('Temperature') && sensor.contains('Id')
                    ds_sensors.push({
                        'name': key,
                        'id': sensor['Id'],
                        'temp': sensor['Temperature']
                    })
                end
            end
        end
        
        # Sort sensors by name for consistent display
        # (Berry doesn't have built-in sort, so we use insertion sort)
        var i = 1
        while i < size(ds_sensors)
            var j = i
            while j > 0 && ds_sensors[j-1]['name'] > ds_sensors[j]['name']
                var temp = ds_sensors[j]
                ds_sensors[j] = ds_sensors[j-1]
                ds_sensors[j-1] = temp
                j -= 1
            end
            i += 1
        end
        
        # Update display labels (p1b11-p1b20 for up to 10 sensors)
        var label_ids = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
        var i = 0
        
        # Update labels with sensor data
        while i < size(ds_sensors) && i < 10
            var sensor = ds_sensors[i]
            var label_id = string.format("p1b%d", label_ids[i])
            var label = global.get(label_id)
            
            if label != nil
                # Extract last 6 characters of ID for display
                var id_str = sensor['id']
                var short_id = id_str[size(id_str)-6..]
                var text = string.format("%s: %.1f C", short_id, sensor['temp'])
                
                # Only update if changed
                var sensor_key = sensor['name']
                if !self.last_sensors.contains(sensor_key) || self.last_sensors[sensor_key] != text
                    label.text = text
                    self.last_sensors[sensor_key] = text
                end
            end
            i += 1
        end
        
        # Clear unused labels
        while i < 10
            var label_id = string.format("p1b%d", label_ids[i])
            var label = global.get(label_id)
            if label != nil && label.text != ""
                label.text = ""
            end
            i += 1
        end
        
        # Publish sensor data for text_rule updates
        tasmota.publish_rule(sensors)
    end
end

# Create and register dashboard
global.dashboard = SensorDashboard()
tasmota.add_driver(global.dashboard)

# Add cron job for regular updates
tasmota.add_cron("*/2 * * * * *", def () 
    var s = tasmota.read_sensors() 
    if s 
        tasmota.publish_rule(s) 
    end 
end, 'sensor_update')

print("Dynamic sensor dashboard started")
