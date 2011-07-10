#include <LiquidCrystal.h>
#include <EEPROM.h>
/*
LCD Pin Number	Symbol	Function
1	Vss	Display power ground
2	Vdd	Display power +5V
3	Vo	Contrast Adjust. Altered by adjusting the voltage to this pin, grounding it sets it to maximum contrast.
4	RS	Register select
5	R/W	Data read/write selector. Its possible to read information from a display however there's no need for it here so grounding it sets it permanently write.
6	E	Enable strobe
7	DB0	Data Bus 0
8	DB1	Data Bus 1
9	DB2	Data Bus 2
10	DB3	Data Bus 3
11	DB4	Data Bus 4
12	DB5	Data Bus 5
13	DB6	Data Bus 6
14	DB7	Data Bus 7
15	A
LED backlight power +5V
16	K	LED backlight power ground
*/
//rs, rw, enable, d4, d5, d6, d7

#define RS 7
#define RW 8
#define ENABLE 9
#define D4 10
#define D5 11
#define D6 12
#define D7 13
#define RECORD_IR_MACRO_BUTTON 6
#define BUTTON1 5

#define INT_SIZE 32767
#define MAX_IR_SIGNAL_ARRAY_SIZE 100
#define ARRAY_TERMINATOR -1

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);

boolean shouldChangeDisplay;

void printOnLCD(char string[]){
  lcd.clear();
  lcd.print(string);
}

int askForButtonToRecordMacro(){
  printOnLCD("Escolha o botao");
  boolean buttonChosen = false;
  int buttonToRecordMacro;
  while(!buttonChosen){
    if(digitalRead(BUTTON1)){
      buttonChosen = true;
      buttonToRecordMacro = BUTTON1;
    }
  }
  return buttonToRecordMacro;
}

void recordMacro(int buttonToRecordMacro){
  printOnLCD("Gravando macro");
  while(!digitalRead(buttonToRecordMacro)){
    EEPROM.write(0, buttonToRecordMacro);
  }
}

boolean lastIRState = false;
unsigned long timeOnLastChange = 0;
unsigned int button1Macro[MAX_IR_SIGNAL_ARRAY_SIZE];
int button1MacroIndex = 0;

void setup(){
  pinMode(RECORD_IR_MACRO_BUTTON,INPUT);
  pinMode(BUTTON1,INPUT);  
  pinMode(2, INPUT);
  shouldChangeDisplay = true;
  Serial.begin(9600);
  button1Macro[0] = ARRAY_TERMINATOR;
}

void loop() {
  if(timeOnLastChange <= 0){
    timeOnLastChange = micros();
  }
  
  if(digitalRead(RECORD_IR_MACRO_BUTTON)){
    
    boolean irOn = true;
    int index = 0;
    int timeInterval;
    while(button1Macro[index] != ARRAY_TERMINATOR){
      timeInterval = button1Macro[index++];
      Serial.print(irOn,DEC);
      Serial.print(" stay for ");
      Serial.println(timeInterval,DEC);
      irOn = !irOn;
    }
    
    int buttonToRecordMacro = askForButtonToRecordMacro();
    delay(300);
    recordMacro(buttonToRecordMacro);
    printOnLCD("Macro salva");
    delay(1000);
    shouldChangeDisplay = true;
    return;
  }else if(digitalRead(BUTTON1)){
    printOnLCD("Rodando macro 1");
    delay(1000);
    shouldChangeDisplay = true;
    return;
  }
  
  boolean infraRedState = analogRead(5)>0;
  
  if(infraRedState != lastIRState){
    lastIRState = infraRedState;
    unsigned long currentTime = micros();
    unsigned long delta = currentTime - timeOnLastChange;
    timeOnLastChange = currentTime;
    if(delta>INT_SIZE){
      return;
    }
    button1Macro[button1MacroIndex] = delta;
    Serial.print("Stayed on state ");
    Serial.print(!infraRedState,DEC);
    Serial.print(" for ");
    Serial.println(delta);
    button1MacroIndex++;
    if(button1MacroIndex == MAX_IR_SIGNAL_ARRAY_SIZE-1){
      button1Macro[button1MacroIndex] = ARRAY_TERMINATOR;
      button1MacroIndex = 0;
    }else{
      button1Macro[button1MacroIndex] = ARRAY_TERMINATOR;
    }
  }
  
  if(shouldChangeDisplay){
    shouldChangeDisplay = false;
    printOnLCD("aguardando");
  }
}
