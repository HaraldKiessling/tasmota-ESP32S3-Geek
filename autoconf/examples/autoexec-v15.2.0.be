# autoexec.be for ESP32-S3 Geek with Tasmota 15.2.0
# Simple display test that works with v15.2.0

import display
import lvgl as lv

# Wait for display to be ready
if !display.started()
    print("Display not started, waiting...")
    tasmota.delay(1000)
end

if display.started()
    print("Display started successfully")
    
    # Get display dimensions
    var w = display.get_width()
    var h = display.get_height()
    print(f"Display size: {w}x{h}")
    
    # Create a simple label to test
    var scr = lv.scr_act()
    
    # Clear any existing objects
    scr.clean()
    
    # Set background color to white
    scr.set_style_bg_color(lv.color(0xFFFFFF), 0)
    
    # Create title label
    var title = lv.label(scr)
    title.set_text("ESP32-S3 Geek")
    title.set_style_text_color(lv.color(0x000000), 0)
    title.set_style_text_font(lv.font_montserrat_20, 0)
    title.align(lv.ALIGN_TOP_MID, 0, 10)
    
    # Create info label
    var info = lv.label(scr)
    info.set_text("Tasmota 15.2.0\nLVGL Display Test")
    info.set_style_text_color(lv.color(0x000000), 0)
    info.set_style_text_align(lv.TEXT_ALIGN_CENTER, 0)
    info.align(lv.ALIGN_CENTER, 0, 0)
    
    # Create sensor label
    var sensor_label = lv.label(scr)
    sensor_label.set_text("Loading sensors...")
    sensor_label.set_style_text_color(lv.color(0x0000FF), 0)
    sensor_label.align(lv.ALIGN_BOTTOM_MID, 0, -10)
    
    print("Display initialized with test pattern")
    
    # Function to update sensor display
    def update_display()
        var sensors = tasmota.read_sensors()
        if sensors
            var text = ""
            
            # Get DS18B20 sensors
            for key: sensors.keys()
                if key.startswith("DS18B20")
                    var temp = sensors[key]["Temperature"]
                    var id = sensors[key]["Id"]
                    text += f"{key}: {temp}°C\n"
                end
            end
            
            if text != ""
                sensor_label.set_text(text)
            else
                sensor_label.set_text("No sensors found")
            end
        end
    end
    
    # Update display every 5 seconds
    tasmota.add_cron("*/5 * * * * *", update_display, "update_display")
    
    # Initial update
    update_display()
    
else
    print("ERROR: Display failed to start!")
end
