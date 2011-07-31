#include <LiquidCrystal.h>
#include <WProgram.h>

#define BLINKING_INTERVAL_IN_MILLIS 500

class ClockPrinter {
public:
  ClockPrinter(LiquidCrystal *printTarget) {
    _blinkHours = false;
    _blinkMinutes = false;
    _blinkSeparator = true;
    _lastClockPrinted = Clock();
    _printTarget = printTarget;
  }
  
  void startBlinkingHours(){
    _blinkHours = true;
  }
  
  void stopBlinkingHours(){
    _blinkHours = false;
  }
  
  void startBlinkingMinutes(){
    _blinkMinutes = true;
  }
  
  void stopBlinkingMinutes(){
    _blinkMinutes = false;
  }
  
  void startBlinkingSeparator(){
    _blinkSeparator = true;
  }
  
  void stopBlinkingSeparator(){
    _blinkSeparator = false;
  }
  
  bool getBlinkingState(){
    int timeCount = millis() % BLINKING_INTERVAL_IN_MILLIS*2;
    return (timeCount>=BLINKING_INTERVAL_IN_MILLIS);
  }
  
  void printClock(Clock clock)
  {
   
    bool blinkingState = getBlinkingState();
    if(_lastClockPrinted.equals(clock) && blinkingState==_lastBlinkingState){
      return;
    }
    _lastBlinkingState = blinkingState;
    char strOut[6];
    clock.toString(strOut);
   
    if(_blinkHours && blinkingState){
      strOut[0] =' ';
      strOut[1] =' ';
    }
    if(_blinkSeparator && clock.getSeconds() % 2){
      strOut[2] = ' ';
    }
    if(_blinkMinutes && blinkingState){
      strOut[3] =' ';
      strOut[4] =' ';
    }
    _printTarget->clear();
    _printTarget->print(strOut);
    _lastClockPrinted.copy(clock);
  }
  
private:
  bool _blinkHours;
  bool _blinkMinutes;
  bool _blinkSeparator;
  bool _lastBlinkingState;
  LiquidCrystal *_printTarget;
  Clock _lastClockPrinted;
};
