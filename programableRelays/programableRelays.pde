#include <LiquidCrystal.h>
#include "clock.h"

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


#define BLINKING_INTERVAL_IN_MILLIS 500
#define BUTTON_PRESSED_CURRENT 1020

Clock clock = Clock();
int seconds=0;
int minutes=0;
int hours=0;
int delta=0;

boolean changingHoursValue = false;
boolean changingMinutesValue = false;
int lastSecond = 0;

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);

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
  seconds += delta / 1000;
  delta = delta % 1000;
  minutes += seconds / 60;
  seconds = seconds % 60;
  hours += minutes / 60;
  hours = hours % 24;
  minutes = minutes % 60;
  previous_millis_value = current_millis_value;
}

void formatTimeDigits(char strOut[3], int num)
{
  strOut[0] = '0' + (num / 10);
  strOut[1] = '0' + (num % 10);
  strOut[2] = '\0';
}

void printIntWithTwoDigits(int number){
  char strOut[3];
  formatTimeDigits(strOut, number);
  lcd.print(strOut);
}

boolean blinkStateChanged(){
  static boolean lastState = false;
  boolean currentBlinkingState = getBlinkingState();
  if(currentBlinkingState != lastState){
    lastState = currentBlinkingState;
    return true;
  }
  return false;
}

boolean getBlinkingState(){
  int timeCount = millis() % BLINKING_INTERVAL_IN_MILLIS*2;
  return (timeCount>=BLINKING_INTERVAL_IN_MILLIS);
}

void printTimeValue(int displayTimeIfTimeNeedsRedisplay, boolean blinking){
  boolean showing = getBlinkingState();
  if(blinking && !showing){
    lcd.print("  ");
  }else{
    printIntWithTwoDigits(displayTimeIfTimeNeedsRedisplay);
  }
}

void printTimeSeparator(){
  if((seconds % 2) || isTimeValueBeingChanged())
    lcd.print(":");
  else
    lcd.print(" ");
}

void printTimeOnLcd(int displayHour, int displayMinute, int displaySeconds){
  lcd.clear();
  printTimeValue(displayHour, changingHoursValue);
  printTimeSeparator();
  printTimeValue(displayMinute, changingMinutesValue);
  if(DISPLAY_SECONDS){
    printTimeSeparator();
    printTimeValue(displaySeconds, false);
  }
}

void printTime(){
  printTimeOnLcd(hours,minutes,seconds);
}

boolean timeNeedsRedisplay(){
  boolean needsUpdateBlink = isTimeValueBeingChanged() && blinkStateChanged();
  boolean timeChanged = lastSecond != seconds;
  return needsUpdateBlink || timeChanged;
}

void updateTime(){
  lastSecond = seconds;
}

void displayTimeIfTimeNeedsRedisplay(){
  if(timeNeedsRedisplay()){
    printTime();
    updateTime();
  }
}

void changeTimeButtonReleased(){
  if(isTimeValueBeingChanged()){
    if(changingHoursValue){
      changingHoursValue = false;
      changingMinutesValue = true;
      return;
    }
    if(changingMinutesValue){
      changingMinutesValue = false;
      seconds = 0;
      return;
    }
  }else{
    changingHoursValue = true;
  }
}

void normalizeClockAndPrint(){
  if(seconds<0)
    seconds = 59;
  if(seconds>=60)
    seconds = 0;
    
  if(minutes<0)
    minutes = 59;
  if(minutes>=60)
    minutes = 0;
  
  if(hours<0)
    hours = 23;
  if(hours>=24)
    hours = 0; 
    
  printTime();
}

void minusPressed(){
  if(changingHoursValue){
    hours--;
  }
  if(changingMinutesValue){
    minutes--;
  }
  normalizeClockAndPrint();
}

void plusPressed(){
  if(changingHoursValue){
    hours++;
  }
  if(changingMinutesValue){
    minutes++;
  }
  normalizeClockAndPrint();
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
  displayTimeIfTimeNeedsRedisplay();
  checkButtons();
}
