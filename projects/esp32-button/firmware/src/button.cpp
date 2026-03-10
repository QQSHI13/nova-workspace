#include "button.h"

void PomodoroButton::begin() {
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    // Give time for pullup to stabilize
    delay(10);
    lastButtonState = (digitalRead(BUTTON_PIN) == LOW);
}

bool PomodoroButton::isPressed() const {
    return digitalRead(BUTTON_PIN) == LOW;  // Active low
}

ButtonEvent PomodoroButton::update() {
    bool reading = isPressed();
    ButtonEvent event = ButtonEvent::NONE;
    unsigned long now = millis();
    
    // Debounce
    if (reading != lastButtonState) {
        lastDebounceTime = now;
    }
    
    if ((now - lastDebounceTime) > DEBOUNCE_DELAY) {
        // Button state has stabilized
        if (reading != buttonState) {
            buttonState = reading;
            
            if (buttonState) {
                // Button pressed (active low)
                buttonDownTime = now;
                longPressTriggered = false;
                
                // Check for double click timing
                if ((now - lastClickTime) < CLICK_TIMEOUT) {
                    clickCount++;
                } else {
                    clickCount = 1;
                }
                lastClickTime = now;
                
                // If this is the second click in quick succession, it's a double click
                if (clickCount == 2) {
                    event = ButtonEvent::DOUBLE_CLICK;
                    clickCount = 0;  // Reset count
                }
            } else {
                // Button released
                if (!longPressTriggered && (now - buttonDownTime) < LONG_PRESS_DURATION) {
                    // Short release - check if it's part of a double click
                    // Single click is only confirmed if double click window expires
                    // For now, we delay single click to next update if clickCount == 1
                }
            }
        }
        
        // Check for long press while button is held
        if (buttonState && !longPressTriggered) {
            if ((now - buttonDownTime) >= LONG_PRESS_DURATION) {
                longPressTriggered = true;
                event = ButtonEvent::LONG_PRESS;
                clickCount = 0;  // Reset click count on long press
            }
        }
        
        // Check for single click confirmation (double click window expired)
        if (!buttonState && clickCount == 1 && (now - lastClickTime) >= CLICK_TIMEOUT) {
            if (!longPressTriggered) {
                event = ButtonEvent::SINGLE_CLICK;
            }
            clickCount = 0;
        }
    }
    
    lastButtonState = reading;
    return event;
}