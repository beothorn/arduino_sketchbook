#include <LiquidCrystal.h>
#include "clock.h"
#include "clockPrinter.h"

#define RS 7
#define RW 8
#define ENABLE 9
#define D4 10
#define D5 11
#define D6 12
#define D7 13

#define CHANGE_TIME_BUTTON_PORT 5
#define CHANGE_TIME_PLUS 4
#define CHANGE_TIME_MINUS 3
#define BUZZER 6
#define DISPLAY_SECONDS false

#define BUTTON_PRESSED_CURRENT 1020

Clock clock = Clock();
int delta=0;

boolean changingHoursValue = false;
boolean changingMinutesValue = false;

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);
ClockPrinter printer = ClockPrinter(&lcd);

void setup(){
  pinMode(CHANGE_TIME_BUTTON_PORT,INPUT);
  pinMode(CHANGE_TIME_PLUS,INPUT);
  pinMode(BUZZER,OUTPUT);
  Serial.begin(9600);
}

void buzz(boolean play){
  digitalWrite(BUZZER,play);
}

boolean isTimeValueBeingChanged(){
  return changingHoursValue || changingMinutesValue; 
}

void calculateTime(){
  static long previous_millis_value;
  static long current_millis_value;
  current_millis_value = millis();
  delta += current_millis_value - previous_millis_value; // should work even when millis rolls over
  if(isTimeValueBeingChanged()){
    return;
  }
  clock.updateTimeForDelta(delta);
  delta = delta % 1000;
  previous_millis_value = current_millis_value;
}

void displayTime(){
  printer.printClock(clock);
}

void changeTimeButtonReleased(){
  if(isTimeValueBeingChanged()){
    if(changingHoursValue){
      changingHoursValue = false;
      changingMinutesValue = true;
      printer.stopBlinkingHours();
      printer.startBlinkingMinutes();
      return;
    }
    if(changingMinutesValue){
      changingMinutesValue = false;
      clock.setSeconds(0);
      printer.stopBlinkingMinutes();
      printer.startBlinkingSeparator();
      return;
    }
  }else{
    changingHoursValue = true;
    printer.startBlinkingHours();
    printer.stopBlinkingSeparator();
  }
}

void minusPressed(){
  if(changingHoursValue){
    clock.decreaseHour();
  }
  if(changingMinutesValue){
    clock.decreaseMinute();
  }
  displayTime();
}

void plusPressed(){
  if(changingHoursValue){
    clock.addHour();
  }
  if(changingMinutesValue){
    clock.addMinute();
  }
  displayTime();
}

boolean readAnalogAsDigital(int port){
  return analogRead(port)>BUTTON_PRESSED_CURRENT;
}

void checkButtons(){
  static boolean changeTimeButtonLastState = false;
  static boolean changeTimeMinusLastState = false;
  static boolean changeTimePlusLastState = false;
  
  boolean changeTimeButtonState = readAnalogAsDigital(CHANGE_TIME_BUTTON_PORT);
  boolean changeTimeButtonStateIsNotPressed = !changeTimeButtonState;
  if(changeTimeButtonLastState && changeTimeButtonStateIsNotPressed){
    changeTimeButtonReleased();
  }
  changeTimeButtonLastState = changeTimeButtonState;
  
  
  boolean changeTimePlusState = readAnalogAsDigital(CHANGE_TIME_PLUS);
  boolean changeTimePlusStateIsNotPressed = !changeTimePlusState;
  if(changeTimePlusLastState && changeTimePlusStateIsNotPressed){
    plusPressed();
  }
  changeTimePlusLastState = changeTimePlusState;
  
  boolean changeTimeMinusState = readAnalogAsDigital(CHANGE_TIME_MINUS);
  boolean changeTimeMinusStateIsNotPressed = !changeTimeMinusState;
  if(changeTimeMinusLastState && changeTimeMinusStateIsNotPressed){
    minusPressed();
  }
  changeTimeMinusLastState = changeTimeMinusState;
  
  buzz(changeTimeButtonState || changeTimePlusState || changeTimeMinusState);
}

void loop() {
  calculateTime();
  displayTime();
  checkButtons();
}
