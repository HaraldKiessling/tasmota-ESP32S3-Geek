/*
  user_config_override.h - Custom configuration for ESP32-S3 LVGL firmware v15.2.0
  FIXED VERSION - ohne USE_SCRIPT Konflikt
  
  Copyright (C) 2024 Harald Kiessling
*/

#ifndef _USER_CONFIG_OVERRIDE_H_
#define _USER_CONFIG_OVERRIDE_H_

#warning **** user_config_override.h: Using Settings from this File ****

// -- Project name --
#undef PROJECT
#define PROJECT                "tasmota32s3-lvgl"

#undef CODE_IMAGE_STR
#define CODE_IMAGE_STR         "tasmota32s3-lvgl"

#undef FIRMWARE_VERSION_CODE
#define FIRMWARE_VERSION_CODE  "ESP32S3-Geek-v15.2.0-fixed"

// -- WiFi Configuration --
#undef WIFI_CONFIG_TOOL
#define WIFI_CONFIG_TOOL       WIFI_MANAGER

// -- MQTT Configuration --
#undef MQTT_TOPIC
#define MQTT_TOPIC             PROJECT

#undef MQTT_FULLTOPIC
#define MQTT_FULLTOPIC         "%prefix%/%topic%/"

// -- Telemetry --
#undef TELE_PERIOD
#define TELE_PERIOD            60

// -- Web Server --
#undef WEB_SERVER
#define WEB_SERVER             2

// -- OTA --
#undef OTA_URL
#define OTA_URL                "https://github.com/HaraldKiessling/tasmota-ESP32S3-Geek/raw/main/firmware/tasmota32s3-lvgl-15.2.0-fixed.bin"

// -- Logging --
#undef SERIAL_LOG_LEVEL
#define SERIAL_LOG_LEVEL       LOG_LEVEL_INFO

#undef WEB_LOG_LEVEL
#define WEB_LOG_LEVEL          LOG_LEVEL_INFO

// -- Sensors --
#define USE_DS18x20                              // DS18B20 temperature sensors
#define DS18x20_USE_ID_AS_NAME                   // Use sensor ID as name
#define DS18B20_INTERNAL_PULLUP                  // Use internal pull-up

#define USE_I2C                                  // I2C support
#define USE_BME280                               // BME280 sensor
#define USE_BMP                                  // BMP085/BMP180/BMP280/BME280
#define USE_BME68X                               // BME680/BME688

// -- Display --
#define USE_DISPLAY                              // Display support
#define USE_DISPLAY_MODES1TO5                    // Enable display modes 1 to 5
#define USE_DISPLAY_LVGL_ONLY                    // LVGL only

// -- LVGL --
#define USE_LVGL                                 // LVGL graphics library
#define USE_LVGL_HASPMOTA                        // HASPmota support
#define USE_LVGL_OPENHASP                        // OpenHASP compatibility

// -- Berry --
#define USE_BERRY                                // Berry scripting
#define USE_BERRY_PSRAM                          // Use PSRAM for Berry
#define USE_BERRY_ULP                            // Berry ULP support

// -- File System --
#define USE_UFILESYS                             // Use file system

// -- ESP32-S3 Specific --
#define ESP32_S3                                 // ESP32-S3 chip
#define USE_ESP32_S3                             // ESP32-S3 support

// -- Memory --
#define USE_PSRAM                                // Use PSRAM

// -- Additional Features --
#define USE_WEBSERVER                            // Web server
#define USE_TIMERS                               // Timers
#define USE_RULES                                // Rules engine
// NOTE: USE_SCRIPT is NOT defined to avoid conflict with USE_RULES

// -- Disable unused features --
#undef USE_DOMOTICZ
#undef USE_HOME_ASSISTANT
#undef USE_TASMOTA_DISCOVERY
#undef USE_ZIGBEE
#undef USE_MATTER_DEVICE
#undef USE_SCRIPT                                // Explicitly disable to avoid conflict

// -- Custom branding --
#undef FRIENDLY_NAME
#define FRIENDLY_NAME          "ESP32S3-Geek"

#undef CODE_IMAGE
#define CODE_IMAGE             "tasmota32s3-lvgl"

#endif  // _USER_CONFIG_OVERRIDE_H_
