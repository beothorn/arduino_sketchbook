#include <LiquidCrystal.h>

LiquidCrystal lcd(2, 3, 4, 5, 6, 7 ,8);
void setup(){
}

void loop() {
  lcd.print(analogRead(0));
}
