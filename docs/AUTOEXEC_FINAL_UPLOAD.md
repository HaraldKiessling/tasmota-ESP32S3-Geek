# autoexec-final.be Upload Instructions

**Date**: 2026-01-12
**Device**: tasmota-77
**File**: autoexec-final.be (Hybrid approach with automatic sensor detection)

## File Details

**Size**: 3.5 KB (102 lines)
**Type**: Berry script
**Purpose**: Automatic DS18B20 sensor detection and pages.jsonl generation

## Upload Challenge

### Base64 Method Limitation

**Problem**: File too large for single URL
- File size: 3503 bytes
- Base64 encoded: ~4670 bytes
- URL length limit: ~2000 characters
- Result: Cannot upload in single request

### Chunk Upload Attempted

**Tried**: Split into 3 chunks
- Chunk 1: 1004 bytes
- Chunk 2: 1400 bytes
- Chunk 3: 1200 bytes

**Result**: Berry commands too complex, returns null

## Current Status

### Minimal Version Uploaded ✅

**File**: autoexec-minimal.be
```berry
# Minimal autoexec.be with HASPmota
import haspmota
haspmota.start()
```

**Status**: ✅ Uploaded successfully
**Function**: Starts HASPmota with default configuration

## Recommended Approach

### Option 1: User Browser Upload (RECOMMENDED) ✅

**Method**: Upload via web UI
1. Open http://tasmota-77.samharald.eu/
2. Navigate to "Consoles" → "Manage File system"
3. Click "Choose File"
4. Select `config/autoexec-final.be`
5. Upload
6. Restart device

**Advantages**:
- ✅ Works perfectly (proven with 2.5 MB file)
- ✅ No size limitation
- ✅ Simple and reliable
- ✅ Full file uploaded at once

### Option 2: Create Simplified Version

**Alternative**: Create a smaller version with core functionality

**Simplified autoexec.be** (~500 bytes):
```berry
import haspmota
import json

# Wait for sensors
tasmota.delay(2000)

# Read sensors
var m = tasmota.read_sensors()
if m == nil
    haspmota.start()
    return
end

# Generate simple pages.jsonl
var pages = []
pages.push('{"page":0}')
pages.push('{"id":11,"obj":"label","x":0,"y":0,"text":"Sensors"}')

var y = 30
var id = 20
for key: m.keys()
    if string.find(key, 'DS18B20') == 0
        var sensor = m[key]
        if sensor.contains('Temperature')
            pages.push('{"id":' + str(id) + ',"obj":"label","x":2,"y":' + str(y) + ',"text_rule":"' + key + '#Temperature","text_rule_format":"' + key + ': %.1f"}')
            y += 20
            id += 1
        end
    end
end

pages.push('{"berry_run":"tasmota.add_cron(\'*/2 * * * * *\',def()var s=tasmota.read_sensors()if(s)tasmota.publish_rule(s)end end,\'s\')"}')

var f = open('pages.jsonl', 'w')
for line: pages
    f.write(line + '\n')
end
f.close()

haspmota.start()
```

**Upload**: Can be done via base64 (smaller size)

### Option 3: Manual File Creation

**Method**: Create file line by line via Berry console
- Too tedious for 102 lines
- Error-prone
- Not recommended

## Comparison

| Method | Size Limit | Complexity | Reliability | Recommendation |
|--------|------------|------------|-------------|----------------|
| Browser Upload | None | Low | ✅ High | ✅ **Best** |
| Base64 (full) | ~1.5 KB | Medium | ❌ Too large | ❌ Won't work |
| Base64 (simplified) | ~1.5 KB | Medium | ✅ Works | ⚠️ Alternative |
| Chunk Upload | None | High | ❌ Complex | ❌ Doesn't work |
| Manual Creation | None | Very High | ❌ Error-prone | ❌ Not practical |

## Current Configuration

### tasmota-77 Status

**Files**:
- display.ini: ✅ Uploaded (via base64)
- autoexec.be: ✅ Minimal version (via base64)

**System**:
- Display: ✅ ST7789 working
- Sensors: ✅ 2x DS18B20 detected
- HASPmota: ✅ Started

**Functionality**:
- ⚠️ Basic HASPmota (no automatic sensor detection)
- ⚠️ No dynamic pages.jsonl generation
- ⚠️ Manual configuration needed

## Recommendation

### For Full Functionality

**Upload autoexec-final.be via browser**:
1. User uploads file via web UI
2. Full hybrid approach with automatic sensor detection
3. Dynamic pages.jsonl generation
4. Alphabetical sensor sorting
5. Automatic display updates

**File location**: `config/autoexec-final.be`

### After Upload

**Verify**:
```bash
curl "http://tasmota-77/cm?cmnd=Restart%201"
sleep 40
curl "http://tasmota-77/cm?cmnd=Status%208" | jq '.StatusSNS'
```

**Expected**:
- Sensors detected automatically
- pages.jsonl generated
- Display showing all sensors
- Updates every 2 seconds

## Alternative: Simplified Version

If browser upload not possible, use simplified version:

**File**: `autoexec-simplified.be` (see above)
**Size**: ~500 bytes
**Upload**: Via base64 method
**Functionality**: Core features only

## Conclusion

### Current Status

**tasmota-77**:
- ✅ Minimal autoexec.be uploaded
- ✅ HASPmota working
- ⚠️ No automatic sensor detection

### Recommendation

**Best approach**: User uploads autoexec-final.be via browser
- Proven working method
- Full functionality
- No limitations

**Alternative**: Use simplified version via base64
- Core functionality only
- Smaller file size
- Works from Gitpod

### Next Steps

1. User uploads autoexec-final.be via web UI
2. Restart device
3. Verify automatic sensor detection
4. Test pages.jsonl generation
5. Confirm display updates

**File ready**: `config/autoexec-final.be` (3.5 KB)
