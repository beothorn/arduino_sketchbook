#include <LiquidCrystal.h>

#define RS 7
#define RW 8
#define ENABLE 9
#define D4 10
#define D5 11
#define D6 12
#define D7 13

long previous_millis_value;
long current_millis_value;

unsigned int seconds = 0;
unsigned int minutes = 0;
unsigned int hours = 0;
int delta;

int lastSecond = 0;

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);

void formatTimeDigits(char strOut[3], int num)
{
  strOut[0] = '0' + (num / 10);
  strOut[1] = '0' + (num % 10);
  strOut[2] = '\0';
}

void setup(){
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
  minutes = minutes % 60;
  previous_millis_value = current_millis_value;
}

void printIntWithTwoDigits(int number){
  char strOut[3];
  formatTimeDigits(strOut, number);
  lcd.print(strOut);
}

void printTimeOnLcd(){
  lcd.clear();
  printIntWithTwoDigits(hours);
  lcd.print(":");
  printIntWithTwoDigits(minutes);
  lcd.print(":");
  printIntWithTwoDigits(seconds);
  lastSecond = seconds;
}

void displayTime(){
  boolean time_changed = lastSecond != seconds; 
  if(time_changed){
    printTimeOnLcd();
  }
}

void loop() {
  calculateTime();
  displayTime();
}
