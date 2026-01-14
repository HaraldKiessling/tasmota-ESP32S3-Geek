#!/usr/bin/env python3
"""
Create a LittleFS filesystem image with Tasmota configuration files.

This script creates a filesystem image that can be flashed alongside
the Tasmota firmware to pre-configure the device.

Requirements:
    pip install littlefs-python

Usage:
    python create-filesystem.py
    
Then flash with:
    esptool.py --chip esp32s3 write_flash 0x310000 filesystem.bin
"""

import os
import sys

try:
    from littlefs import LittleFS
except ImportError:
    print("ERROR: littlefs-python not installed")
    print("Install with: pip install littlefs-python")
    sys.exit(1)

# Configuration
BLOCK_SIZE = 4096
BLOCK_COUNT = 3072  # 12MB filesystem
OUTPUT_FILE = "filesystem.bin"

# WiFi credentials - set via environment variables or edit here
WIFI_SSID = os.environ.get('WIFI_SSID', 'YOUR_WIFI_SSID')
WIFI_PASS = os.environ.get('WIFI_PASS', 'YOUR_WIFI_PASSWORD')

# Files to include
FILES = {
    "init.bat": f"""Backlog SSID1 {WIFI_SSID}; Password1 {WIFI_PASS}; Restart 1
""",
    "display.ini": """:H,ST7789,135,240,16,SPI,3,10,12,11,8,7,9,-1,40
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
#""",
}

def main():
    print("Creating LittleFS filesystem image...")
    print(f"Block size: {BLOCK_SIZE}")
    print(f"Block count: {BLOCK_COUNT}")
    print(f"Total size: {BLOCK_SIZE * BLOCK_COUNT / 1024 / 1024:.1f} MB")
    print()
    
    # Create filesystem
    fs = LittleFS(block_size=BLOCK_SIZE, block_count=BLOCK_COUNT)
    
    # Add files
    for filename, content in FILES.items():
        print(f"Adding: {filename} ({len(content)} bytes)")
        with fs.open(filename, 'w') as f:
            f.write(content)
    
    # Also try to add autoexec.be and pages.jsonl from config directory
    config_dir = os.path.join(os.path.dirname(__file__), '..', 'config')
    for filename in ['autoexec.be', 'pages.jsonl']:
        filepath = os.path.join(config_dir, filename)
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                content = f.read()
            print(f"Adding: {filename} ({len(content)} bytes)")
            with fs.open(filename, 'w') as f:
                f.write(content)
    
    # Write image
    print()
    print(f"Writing: {OUTPUT_FILE}")
    with open(OUTPUT_FILE, 'wb') as f:
        f.write(fs.context.buffer)
    
    print()
    print("Done!")
    print()
    print("Flash with:")
    print(f"  esptool.py --chip esp32s3 write_flash 0x310000 {OUTPUT_FILE}")
    print()
    print("Or flash everything together:")
    print("  esptool.py --chip esp32s3 write_flash \\")
    print("    0x0 tasmota32s3-lvgl-15.2.0.factory.bin \\")
    print(f"    0x310000 {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
