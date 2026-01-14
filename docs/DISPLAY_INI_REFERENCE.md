# display.ini Reference Guide

**File**: display.ini  
**Purpose**: Universal Display Driver configuration  
**Display**: ST7789 TFT 240x135  
**Board**: ESP32-S3 Geek  

---

## Overview

The `display.ini` file configures the Universal Display Driver in Tasmota. It defines how Tasmota communicates with the ST7789 display controller.

**⚠️ Critical**: This file must be exact! Wrong configuration causes:
- Boot loops
- Display showing only noise
- System crashes

---

## Working Configuration (v15.2.0)

### Complete File

```ini
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
:S,2,1,3,0,80,30
:I,01,A0,11,A0,3A,81,55,36,81,00,21,80,13,80,29,A0
:o,28
:O,29
:A,2A,2B,2C
:R,36
:0,C0,35,28,00
:1,A0,28,34,01
:2,00,34,28,02
:3,60,28,35,03
:i,21,20
:B,30,5
#
```

**File Size**: ~220 bytes  
**Line Ending**: Unix (LF)  
**Encoding**: ASCII

---

## Common Mistakes

### ❌ Multi-line Initialization (causes snow/noise)

```ini
:I
01,A0
11,A0
3A,81,55
```

This format causes the display to show random noise ("snow"). The initialization commands are not parsed correctly when split across multiple lines.

### ✅ Correct Single-line Initialization

```ini
:I,01,A0,11,A0,3A,81,55,36,81,00,21,80,13,80,29,A0
```

All initialization commands must be on a single line after `:I,`.

### Other Common Errors

| Error | Symptom | Fix |
|-------|---------|-----|
| Trailing spaces | Parsing errors | Remove spaces at end of lines |
| Unknown directives (`:TI2`, `:r`) | Ignored or errors | Remove non-standard lines |
| Windows line endings (CRLF) | Display malfunction | Convert to Unix (LF) |  

---

## Line-by-Line Explanation

### Header Line (:H)

```ini
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
```

**Format**:
```
:H,<controller>,<width>,<height>,<bpp>,<interface>,<bus>,<cs>,<dc>,<mosi>,<sclk>,<rst>,<bl>,<miso>,<freq>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:H` | Header | Line identifier |
| `ST7789` | Controller | Display controller chip |
| `135` | Width | Display width in pixels |
| `240` | Height | Display height in pixels |
| `16` | BPP | Bits per pixel (RGB565) |
| `SPI` | Interface | Communication interface |
| `3` | Bus | SPI bus number (HSPI) |
| `10` | CS | Chip Select GPIO |
| `12` | DC | Data/Command GPIO |
| `11` | MOSI | Data Out GPIO |
| `8` | SCLK | Clock GPIO |
| `7` | RST | Reset GPIO |
| `9` | BL | Backlight GPIO |
| `-1` | MISO | Not used (write-only) |
| `40` | Freq | SPI frequency (MHz) |

**Why 135,240 not 240,135?**
- Display is physically 240x135
- But configured as 135x240
- Tasmota handles rotation internally
- **Do not change** - causes issues!

---

### SPI Settings (:S)

```ini
:S,2,1,3,0,80,30
```

**Format**:
```
:S,<mode>,<msb>,<speed>,<3wire>,<bpw>,<dc_low>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:S` | SPI | Line identifier |
| `2` | Mode | SPI Mode 2 (CPOL=1, CPHA=0) |
| `1` | MSB | MSB first (1=yes) |
| `3` | Speed | Speed divider |
| `0` | 3-wire | 3-wire mode (0=disabled) |
| `80` | BPW | Bits per word |
| `30` | DC Low | DC low time (ns) |

**SPI Modes**:
- Mode 0: CPOL=0, CPHA=0
- Mode 1: CPOL=0, CPHA=1
- Mode 2: CPOL=1, CPHA=0 ← Used
- Mode 3: CPOL=1, CPHA=1

---

### Initialization Sequence (:I)

```ini
:I,01,A0,11,A0,3A,81,55,36,81,00,21,80,13,80,29,A0
```

**Format**:
```
:I,<cmd>,<delay>,<cmd>,<delay>,...
```

**Decoded Commands**:

| Hex | Command | Description |
|-----|---------|-------------|
| `01` | SWRESET | Software reset |
| `A0` | Delay | 160ms delay |
| `11` | SLPOUT | Sleep out |
| `A0` | Delay | 160ms delay |
| `3A` | COLMOD | Color mode |
| `81` | Data | 1 byte follows |
| `55` | Data | 16-bit color (RGB565) |
| `36` | MADCTL | Memory access control |
| `81` | Data | 1 byte follows |
| `00` | Data | Normal orientation |
| `21` | INVON | Inversion on |
| `80` | Delay | 128ms delay |
| `13` | NORON | Normal display on |
| `80` | Delay | 128ms delay |
| `29` | DISPON | Display on |
| `A0` | Delay | 160ms delay |

**Delay Encoding**:
- `80` = 128ms
- `A0` = 160ms
- High bit set = delay in ms

---

### Display Off Command (:o)

```ini
:o,28
```

**Format**:
```
:o,<cmd>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:o` | Off | Line identifier |
| `28` | DISPOFF | Display off command |

**Usage**: Sent when display is turned off

---

### Display On Command (:O)

```ini
:O,29
```

**Format**:
```
:O,<cmd>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:O` | On | Line identifier |
| `29` | DISPON | Display on command |

**Usage**: Sent when display is turned on

---

### Address Set Commands (:A)

```ini
:A,2A,2B,2C
```

**Format**:
```
:A,<col_cmd>,<row_cmd>,<data_cmd>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:A` | Address | Line identifier |
| `2A` | CASET | Column address set |
| `2B` | RASET | Row address set |
| `2C` | RAMWR | Memory write |

**Usage**: Commands for setting drawing area

---

### Rotation Command (:R)

```ini
:R,36
```

**Format**:
```
:R,<cmd>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:R` | Rotation | Line identifier |
| `36` | MADCTL | Memory access control |

**Usage**: Command for changing display rotation

---

### Rotation Values (:0, :1, :2, :3)

```ini
:0,C0,35,28,00
:1,A0,28,34,01
:2,00,34,28,02
:3,60,28,35,03
```

**Format**:
```
:<rotation>,<madctl>,<width>,<height>,<offset>
```

**Rotation 0** (Portrait):
```
:0,C0,35,28,00
```
- MADCTL: 0xC0
- Width: 53 (0x35 = 53 decimal)
- Height: 40 (0x28 = 40 decimal)
- Offset: 0

**Rotation 1** (Landscape):
```
:1,A0,28,34,01
```
- MADCTL: 0xA0
- Width: 40 (0x28)
- Height: 52 (0x34)
- Offset: 1

**Rotation 2** (Portrait inverted):
```
:2,00,34,28,02
```
- MADCTL: 0x00
- Width: 52 (0x34)
- Height: 40 (0x28)
- Offset: 2

**Rotation 3** (Landscape inverted):
```
:3,60,28,35,03
```
- MADCTL: 0x60
- Width: 40 (0x28)
- Height: 53 (0x35)
- Offset: 3

**MADCTL Bits**:
```
Bit 7: MY  (Row address order)
Bit 6: MX  (Column address order)
Bit 5: MV  (Row/Column exchange)
Bit 4: ML  (Vertical refresh order)
Bit 3: BGR (RGB/BGR order)
Bit 2: MH  (Horizontal refresh order)
```

---

### Inversion Commands (:i)

```ini
:i,21,20
```

**Format**:
```
:i,<on_cmd>,<off_cmd>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:i` | Inversion | Line identifier |
| `21` | INVON | Inversion on |
| `20` | INVOFF | Inversion off |

**Usage**: Commands for color inversion

---

### Backlight Control (:B)

```ini
:B,30,5
```

**Format**:
```
:B,<max>,<min>
```

**Parameters**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `:B` | Backlight | Line identifier |
| `30` | Max | Maximum brightness (48 decimal) |
| `5` | Min | Minimum brightness (5 decimal) |

**Brightness Range**: 5-48 (0-100%)

**Console Commands**:
```
# Set brightness (0-100)
Dimmer 50

# Turn backlight off
Dimmer 0

# Turn backlight on
Dimmer 100
```

---

### End Marker (#)

```ini
#
```

**Purpose**: Marks end of configuration file

**Required**: Yes, must be last line

---

## ST7789 Command Reference

### Common Commands

| Hex | Command | Description |
|-----|---------|-------------|
| `00` | NOP | No operation |
| `01` | SWRESET | Software reset |
| `11` | SLPOUT | Sleep out |
| `13` | NORON | Normal display mode on |
| `20` | INVOFF | Display inversion off |
| `21` | INVON | Display inversion on |
| `28` | DISPOFF | Display off |
| `29` | DISPON | Display on |
| `2A` | CASET | Column address set |
| `2B` | RASET | Row address set |
| `2C` | RAMWR | Memory write |
| `36` | MADCTL | Memory data access control |
| `3A` | COLMOD | Interface pixel format |

### Color Modes (COLMOD)

| Value | Mode | Description |
|-------|------|-------------|
| `03` | 12-bit | 4096 colors |
| `05` | 16-bit | 65536 colors (RGB565) ← Used |
| `06` | 18-bit | 262144 colors |

---

## Troubleshooting

### Display Shows Noise

**Cause**: Incorrect display.ini

**Solution**:
1. Delete display.ini
2. Upload correct version
3. Verify file size (226 bytes)
4. Check line endings (Unix LF)
5. Restart device

### Boot Loop

**Cause**: Invalid initialization sequence

**Solution**:
1. Wait for device to boot (after 4 crashes)
2. Delete display.ini
3. Upload working version
4. Restart

### Display Rotated Wrong

**Cause**: Incorrect rotation values

**Solution**:
```
# Try different rotation
DisplayRotate 0  # Portrait
DisplayRotate 1  # Landscape
DisplayRotate 2  # Portrait inverted
DisplayRotate 3  # Landscape inverted
```

### Colors Inverted

**Cause**: Inversion setting wrong

**Solution**:
```
# Toggle inversion
DisplayInvert 0  # Normal
DisplayInvert 1  # Inverted
```

### Backlight Not Working

**Cause**: Backlight GPIO or settings wrong

**Solution**:
```
# Check backlight
Dimmer 100

# If still not working:
# - Check GPIO 9 in template
# - Check :B line in display.ini
# - Verify hardware connection
```

---

## Creating Custom display.ini

### Step 1: Identify Display

**Required Information**:
- Controller chip (ST7789, ILI9341, etc.)
- Resolution (width x height)
- Interface (SPI, I2C, parallel)
- GPIO pins

### Step 2: Find Datasheet

**Sources**:
- Manufacturer website
- Display module documentation
- Controller datasheet

### Step 3: Define Header

```ini
:H,<controller>,<width>,<height>,<bpp>,<interface>,<bus>,<cs>,<dc>,<mosi>,<sclk>,<rst>,<bl>,<miso>,<freq>
```

**Example**:
```ini
:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
```

### Step 4: Configure SPI

```ini
:S,<mode>,<msb>,<speed>,<3wire>,<bpw>,<dc_low>
```

**Typical Values**:
```ini
:S,2,1,3,0,80,30
```

### Step 5: Initialization Sequence

**From Datasheet**:
1. Software reset
2. Sleep out
3. Set color mode
4. Set orientation
5. Display on

**Example**:
```ini
:I,01,A0,11,A0,3A,81,55,36,81,00,21,80,13,80,29,A0
```

### Step 6: Define Commands

```ini
:o,28          # Display off
:O,29          # Display on
:A,2A,2B,2C    # Address commands
:R,36          # Rotation command
```

### Step 7: Rotation Values

**Calculate from MADCTL**:
```ini
:0,C0,35,28,00  # Portrait
:1,A0,28,34,01  # Landscape
:2,00,34,28,02  # Portrait inverted
:3,60,28,35,03  # Landscape inverted
```

### Step 8: Backlight

```ini
:B,30,5  # Max 48, Min 5
```

### Step 9: End Marker

```ini
#
```

### Step 10: Test

1. Upload to device
2. Restart
3. Check console for errors
4. Verify display works
5. Test all rotations
6. Test backlight

---

## Version Differences

### Version History

**v15.0.1**:
- More tolerant of errors
- Auto-corrects some issues
- Wider compatibility

**v15.2.0**:
- Stricter validation
- Exact configuration required
- Less forgiving

**Recommendation**: Use exact configuration for both versions

---

## Best Practices

### File Management

✅ **Do**:
- Keep backup of working display.ini
- Document any changes
- Test on non-production device first
- Verify file size after upload
- Check line endings (Unix LF)

❌ **Don't**:
- Modify without understanding
- Use Windows line endings (CRLF)
- Upload corrupted files
- Test on production devices

### Configuration

✅ **Do**:
- Use proven configurations
- Match GPIO pins exactly
- Follow datasheet specifications
- Test thoroughly

❌ **Don't**:
- Guess values
- Mix configurations from different displays
- Skip testing
- Deploy without verification

---

## References

### Datasheets

- [ST7789 Datasheet](https://www.waveshare.com/w/upload/a/ae/ST7789_Datasheet.pdf)
- [ESP32-S3 Geek Schematic](https://www.waveshare.com/wiki/ESP32-S3-Geek)

### Tasmota Documentation

- [Universal Display Driver](https://tasmota.github.io/docs/Universal-Display-Driver/)
- [Display Commands](https://tasmota.github.io/docs/Commands/#displays)

### Related Documents

- [GPIO_PINOUT.md](GPIO_PINOUT.md) - GPIO pin mapping
- [DISPLAY_FIXED_SOLUTION.md](../DISPLAY_FIXED_SOLUTION.md) - Troubleshooting

---

**Last Updated**: 2026-01-12  
**Display**: ST7789 240x135  
**Board**: ESP32-S3 Geek  
**File Size**: 226 bytes
