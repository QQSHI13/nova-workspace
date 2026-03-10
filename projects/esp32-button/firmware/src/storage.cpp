#include "storage.h"
#include <EEPROM.h>

void Storage::begin() {
    EEPROM.begin(EEPROM_SIZE);
}

TimerSettings Storage::load() {
    TimerSettings settings;
    
    StoredData data;
    EEPROM.get(SETTINGS_ADDR, data);
    
    // Validate magic number and checksum
    bool valid = false;
    if ((data.magic == MAGIC_V2 || data.magic == MAGIC) && 
        data.checksum == calculateChecksum(data)) {
        valid = true;
    }
    
    if (valid) {
        settings.workMinutes = data.workMinutes;
        settings.breakMinutes = data.breakMinutes;
        settings.longBreakMinutes = data.longBreakMinutes;
        settings.workSessionsBeforeLongBreak = data.workSessionsBeforeLongBreak;
        settings.soundEnabled = data.soundEnabled;
        
        // If old format (MAGIC v1), use defaults for new fields
        if (data.magic == MAGIC) {
            settings.longBreakMinutes = 15;
            settings.workSessionsBeforeLongBreak = 4;
        }
    } else {
        // Invalid data, use defaults
        Serial.println("EEPROM invalid, using defaults");
        settings = TimerSettings();
        save(settings);
    }
    
    return settings;
}

void Storage::save(const TimerSettings& settings) {
    StoredData data;
    data.magic = MAGIC_V2;
    data.workMinutes = settings.workMinutes;
    data.breakMinutes = settings.breakMinutes;
    data.longBreakMinutes = settings.longBreakMinutes;
    data.workSessionsBeforeLongBreak = settings.workSessionsBeforeLongBreak;
    data.soundEnabled = settings.soundEnabled;
    data.checksum = calculateChecksum(data);
    
    EEPROM.put(SETTINGS_ADDR, data);
    EEPROM.commit();
}

void Storage::resetToDefaults() {
    TimerSettings defaults;
    save(defaults);
}

uint8_t Storage::calculateChecksum(const StoredData& data) {
    uint8_t checksum = 0;
    checksum ^= (data.magic >> 24) & 0xFF;
    checksum ^= (data.magic >> 16) & 0xFF;
    checksum ^= (data.magic >> 8) & 0xFF;
    checksum ^= data.magic & 0xFF;
    checksum ^= data.workMinutes;
    checksum ^= data.breakMinutes;
    checksum ^= data.longBreakMinutes;
    checksum ^= data.workSessionsBeforeLongBreak;
    checksum ^= data.soundEnabled;
    return checksum;
}
