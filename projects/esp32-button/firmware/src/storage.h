#pragma once

#include "config.h"

struct TimerSettings {
    uint8_t workMinutes = 25;
    uint8_t breakMinutes = 5;
    uint8_t longBreakMinutes = 15;
    uint8_t workSessionsBeforeLongBreak = 4;  // After 4 work sessions, take long break
    bool soundEnabled = true;
};

class Storage {
public:
    void begin();
    TimerSettings load();
    void save(const TimerSettings& settings);
    void resetToDefaults();
    
private:
    static constexpr int EEPROM_SIZE = 64;
    static constexpr int SETTINGS_ADDR = 0;
    static constexpr uint32_t MAGIC = 0x504D4454; // "PMDT"
    static constexpr uint32_t MAGIC_V2 = 0x504D4455; // "PMDU" - v2 with long break
    
    struct StoredData {
        uint32_t magic;
        uint8_t workMinutes;
        uint8_t breakMinutes;
        uint8_t longBreakMinutes;
        uint8_t workSessionsBeforeLongBreak;
        uint8_t soundEnabled;
        uint8_t checksum;
    };
    
    uint8_t calculateChecksum(const StoredData& data);
};
