# Hybrid autoexec.be - generates pages.jsonl dynamically based on detected sensors
import haspmota
import json
import string

# Detect all DS18B20 sensors and generate pages.jsonl
def generate_pages()
    print("Detecting DS18B20 sensors...")
    
    # Wait for sensors to be ready
    tasmota.delay(2000)
    
    # Read sensors
    var raw_json = tasmota.read_sensors()
    if raw_json == nil
        print("No sensors detected yet, using default pages.jsonl")
        haspmota.start()
        return
    end
    
    var sensors = json.load(raw_json)
    if sensors == nil
        print("Failed to parse sensors, using default pages.jsonl")
        haspmota.start()
        return
    end
    
    # Find all DS18B20 sensors
    var ds_sensors = []
    for key: sensors.keys()
        if string.find(key, 'DS18B20') == 0 || string.find(key, 'DS18S20') == 0
            var sensor = sensors[key]
            if sensor.contains('Temperature') && sensor.contains('Id')
                ds_sensors.push({
                    'name': key,
                    'id': sensor['Id']
                })
            end
        end
    end
    
    print(string.format("Found %d DS18B20 sensors", size(ds_sensors)))
    
    # Generate pages.jsonl content
    var pages = []
    
    # Header page
    pages.push('{"page":0,"comment":"---------- Upper stat line ----------"}')
    pages.push('')
    pages.push('{"id":11,"obj":"label","x":0,"y":0,"w":240,"pad_right":90,"h":22,"bg_color":"#D00000","bg_opa":255,"radius":0,"border_side":0,"text":"Temperatur","text_font":"montserrat-20"}')
    pages.push('')
    pages.push('{"id":15,"obj":"lv_wifi_arcs","x":211,"y":0,"w":29,"h":22,"radius":0,"border_side":0,"bg_color":"#000000","line_color":"#FFFFFF"}')
    pages.push('{"id":16,"obj":"lv_clock","x":132,"y":3,"w":55,"h":16,"radius":0,"border_side":0}')
    pages.push('')
    
    # Main page
    pages.push('{"page":1,"comment":"---------- Page 1 ----------"}')
    pages.push('{"id":0,"bg_color":"#0000A0","bg_grad_color":"#000000","bg_grad_dir":1,"text_color":"#FFFFFF"}')
    pages.push('')
    
    # Add sensor labels dynamically
    var y = 25
    var label_id = 11
    for sensor: ds_sensors
        if label_id > 20 break end  # Max 10 sensors (id 11-20)
        
        # Extract last 6 characters of ID
        var id_str = sensor['id']
        var short_id = id_str[size(id_str)-6..]
        
        # Create label with text_rule
        var label = string.format('{"id":%d,"obj":"label","x":2,"y":%d,"w":220,"text":"%s=","align":0,"text_rule":"%s#Temperature","text_rule_format":"%s:%%4.2f C","text_rule_formula":"val","text_font":"montserrat-20"}',
            label_id, y, short_id, sensor['name'], short_id)
        pages.push(label)
        
        y += 25
        label_id += 1
    end
    
    # Add cron job for sensor updates
    pages.push('')
    pages.push('{"comment":"--- Trigger sensors every 2 seconds ---","berry_run":"tasmota.add_cron(\'*/2 * * * * *\', def () var s = tasmota.read_sensors() if (s) tasmota.publish_rule(s) end end, \'sensor_update\')"}')
    
    # Write pages.jsonl
    var f = open("pages.jsonl", "w")
    if f
        for line: pages
            f.write(line)
            f.write("\n")
        end
        f.close()
        print("Generated pages.jsonl with " + str(size(ds_sensors)) + " sensors")
    else
        print("Failed to write pages.jsonl")
    end
    
    # Start HASPmota
    haspmota.start()
end

# Generate pages and start
generate_pages()
