#include <LiquidCrystal.h>

LiquidCrystal lcd(7, 8, 9, 10, 11, 12 ,13);
void setup(){
  lcd.print("Carol!");
}

unsigned long lastInterval = 0;

void loop() {
  unsigned long currentInterval = millis();
  unsigned long delta = currentInterval-lastInterval;
  lastInterval = currentInterval;
  
  lcd.print(delta/1000);
}
