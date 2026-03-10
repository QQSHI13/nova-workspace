#include "usb_hid.h"
#include <USB.h>
#include <USBCDC.h>

// Use USB CDC for reliable serial communication on ESP32-S3
static USBCDC USBSerial;

void USBHID::begin() {
    // Initialize USB with CDC
    USBSerial.begin();
    USB.begin();
    
    // Set USB device descriptors
    USB.productName("Pomodoro Button");
    USB.manufacturerName("Nova");
    USB.serialNumber("PB001");
    
    newSettings = false;
    inputBuffer = "";
    
    Serial.println("USB HID initialized (CDC mode)");
}

bool USBHID::isConnected() const {
    return USBSerial.connected;
}

bool USBHID::hasNewSettings() const {
    return newSettings;
}

TimerSettings USBHID::getSettings() {
    newSettings = false;
    return pendingSettings;
}

void USBHID::sendHello() {
    if (!isConnected()) return;
    USBSerial.println("HELLO:pomodoro_v2");
    USBSerial.flush();
}

void USBHID::sendAck(bool success) {
    if (!isConnected()) return;
    USBSerial.println(success ? "OK" : "ERR:failed");
    USBSerial.flush();
}

void USBHID::update() {
    // Read from USB CDC
    while (USBSerial.available()) {
        char c = USBSerial.read();
        
        if (c == '\n' || c == '\r') {
            if (inputBuffer.length() > 0) {
                processCommand(inputBuffer);
                inputBuffer = "";
            }
        } else {
            inputBuffer += c;
            // Prevent buffer overflow
            if (inputBuffer.length() > 256) {
                inputBuffer = "";
            }
        }
    }
    
    // Also check regular Serial for debug/development
    while (Serial.available()) {
        char c = Serial.read();
        
        if (c == '\n' || c == '\r') {
            if (inputBuffer.length() > 0) {
                processCommand(inputBuffer);
                inputBuffer = "";
            }
        } else {
            inputBuffer += c;
            if (inputBuffer.length() > 256) {
                inputBuffer = "";
            }
        }
    }
}

void USBHID::processCommand(const String& cmd) {
    Serial.printf("Received: %s\n", cmd.c_str());
    
    if (cmd.startsWith("SET:")) {
        pendingSettings = parseSettings(cmd.substring(4));
        newSettings = true;
    } else if (cmd == "GET") {
        // Return current settings
        String response = "SETTINGS:work=" + String(pendingSettings.workMinutes) +
                         ",break=" + String(pendingSettings.breakMinutes) +
                         ",longBreak=" + String(pendingSettings.longBreakMinutes) +
                         ",sessions=" + String(pendingSettings.workSessionsBeforeLongBreak) +
                         ",sound=" + String(pendingSettings.soundEnabled ? 1 : 0);
        if (isConnected()) {
            USBSerial.println(response);
        }
        Serial.println(response);
    } else if (cmd == "PING") {
        if (isConnected()) {
            USBSerial.println("PONG");
        }
        Serial.println("PONG");
    } else if (cmd == "RESET") {
        // Reset to defaults
        pendingSettings = TimerSettings();
        newSettings = true;
    }
}

TimerSettings USBHID::parseSettings(const String& data) {
    TimerSettings settings;
    
    // Parse format: "work=25,break=5,longBreak=15,sessions=4,sound=1"
    auto getValue = [&](const String& key) -> int {
        int idx = data.indexOf(key + "=");
        if (idx < 0) return -1;
        int start = idx + key.length() + 1;
        int end = data.indexOf(",", start);
        if (end < 0) end = data.length();
        return data.substring(start, end).toInt();
    };
    
    int work = getValue("work");
    int brk = getValue("break");
    int longBrk = getValue("longBreak");
    int sessions = getValue("sessions");
    int sound = getValue("sound");
    
    auto clamp = [](int val, int min, int max) -> int {
        return val < min ? min : (val > max ? max : val);
    };
    
    if (work > 0) settings.workMinutes = clamp(work, 1, 60);
    if (brk >= 0) settings.breakMinutes = clamp(brk, 1, 30);
    if (longBrk >= 0) settings.longBreakMinutes = clamp(longBrk, 1, 60);
    if (sessions > 0) settings.workSessionsBeforeLongBreak = clamp(sessions, 2, 10);
    if (sound >= 0) settings.soundEnabled = (sound != 0);
    
    return settings;
}