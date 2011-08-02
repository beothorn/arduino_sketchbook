#include "state.h"
#include <WProgram.h>

class ClockState : public State{
public:
  ClockState(Clock *clock,LiquidCrystal lcd) {
    _printer = &ClockPrinter(&lcd);
    _clock = clock;
    changingHoursValue = false;
    changingMinutesValue = false;
  }
  
  State setPressed(){
    if(isTimeValueBeingChanged()){
      if(changingHoursValue){
        changingHoursValue = false;
        changingMinutesValue = true;
        _printer->stopBlinkingHours();
        _printer->startBlinkingMinutes();
        return *static_cast<State *>(this);
      }
      if(changingMinutesValue){
        changingMinutesValue = false;
        _clock->setSeconds(0);
        _printer->stopBlinkingMinutes();
        _printer->startBlinkingSeparator();
        return *static_cast<State *>(this);
      }
    }else{
      changingHoursValue = true;
      _printer->startBlinkingHours();
      _printer->stopBlinkingSeparator();
    }
    return *static_cast<State *>(this);
  }
  
  State minusPressed(){
    if(changingHoursValue){
      _clock->decreaseHour();
    }
    if(changingMinutesValue){
      _clock->decreaseMinute();
    }
    printState();
    return *static_cast<State *>(this);
  }
  
  State plusPressed(){
    if(changingHoursValue){
      _clock->addHour();
    }
    if(changingMinutesValue){
      _clock->addMinute();
    }
    printState();
    return *static_cast<State *>(this);
  }
  
  void printState(){
    Serial.println("PRINT");
    _printer->printClock(_clock);
  }
private:
  ClockPrinter *_printer;
  Clock *_clock;
  bool changingHoursValue;
  bool changingMinutesValue;
  
  boolean isTimeValueBeingChanged(){
    return changingHoursValue || changingMinutesValue; 
  }
};
