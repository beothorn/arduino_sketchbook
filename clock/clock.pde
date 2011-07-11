#include <LiquidCrystal.h>

#define RS 7
#define RW 8
#define ENABLE 9
#define D4 10
#define D5 11
#define D6 12
#define D7 13

#define CHANGE_TIME_BUTTON_PORT 6
#define CHANGE_TIME_MINUS 5
#define CHANGE_TIME_PLUS 4

long previous_millis_value;
long current_millis_value;

unsigned int seconds = 55;
unsigned int minutes = 59;
unsigned int hours = 23;
int delta;

boolean changingHoursValue = false;
boolean changingMinutesValue = false;
boolean changingSecondsValue = false;
int lastSecond = 0;

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);

void setup(){
  pinMode(CHANGE_TIME_BUTTON_PORT,INPUT);
  pinMode(CHANGE_TIME_MINUS,INPUT);
  pinMode(CHANGE_TIME_PLUS,INPUT);
  Serial.begin(9600);
}

void calculateTime(){
  current_millis_value = millis();
  delta += current_millis_value - previous_millis_value; // should work even when millis rolls over
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

void printTimeValue(int displayTime, boolean blinking){
  if(blinking){
    if(seconds % 2){
      printIntWithTwoDigits(displayTime);
    }else{
      lcd.print("  ");
    }
  }else{
    printIntWithTwoDigits(displayTime);
  }
}

void printTimeOnLcd(int displayHour, int displayMinute, int displaySeconds){
  lcd.clear();
  printTimeValue(displayHour, changingHoursValue);
  lcd.print(":");
  printTimeValue(displayMinute, changingMinutesValue);
  lcd.print(":");
  printTimeValue(displaySeconds, changingSecondsValue);
  lastSecond = seconds;
}

void displayTime(){
  boolean time_changed = lastSecond != seconds; 
  if(time_changed){
    printTimeOnLcd(hours,minutes,seconds);
  }
}

void changeTimeButtonReleased(){
  if(changingHoursValue || changingMinutesValue || changingSecondsValue){
    if(changingHoursValue){
      changingHoursValue = false;
      changingMinutesValue = true;
      return;
    }
    if(changingMinutesValue){
      changingMinutesValue = false;
      changingSecondsValue = true;
      return;
    }
    if(changingSecondsValue){
      changingSecondsValue = false;
      return;
    }
  }else{
    changingHoursValue = true;
  }
}

void normalizeClock(){
  seconds = seconds % 60;
  hours = hours % 24;
  minutes = minutes % 60;
}

void minusPressed(){
  if(changingHoursValue){
    hours--;
  }
  if(changingMinutesValue){
    minutes--;
  }
  if(changingSecondsValue){
    seconds--;
  }
  normalizeClock();
}

void plusPressed(){
  if(changingHoursValue){
    hours++;
  }
  if(changingMinutesValue){
    minutes++;
  }
  if(changingSecondsValue){
    seconds++;
  }
  normalizeClock();
}

boolean changeTimeButtonLastState = false;
boolean changeTimeMinusLastState = false;
boolean changeTimePlusLastState = false;
void checkButtons(){
  boolean changeTimeButtonState = digitalRead(CHANGE_TIME_BUTTON_PORT);
  boolean changeTimeButtonStateIsNotPressed = !changeTimeButtonState;
  if(changeTimeButtonLastState && changeTimeButtonStateIsNotPressed){
    changeTimeButtonReleased();
  }
  changeTimeButtonLastState = changeTimeButtonState;
  
  boolean changeTimePlusState = digitalRead(CHANGE_TIME_PLUS);
  boolean changeTimePlusStateIsNotPressed = !changeTimePlusState;
  if(changeTimePlusLastState && changeTimePlusStateIsNotPressed){
    plusPressed();
  }
  changeTimePlusLastState = changeTimePlusState;
  
  boolean changeTimeMinusState = digitalRead(CHANGE_TIME_MINUS);
  boolean changeTimeMinusStateIsNotPressed = !changeTimeMinusState;
  if(changeTimeMinusLastState && changeTimeMinusStateIsNotPressed){
    minusPressed();
  }
  changeTimeMinusLastState = changeTimeMinusState;
  
}

void loop() {
  calculateTime();
  displayTime();
  checkButtons();
}
