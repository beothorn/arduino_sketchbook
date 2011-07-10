#include <LiquidCrystal.h>
#include <EEPROM.h>
/*
LCD Pin Number Symbol Function
1 Vss Display power ground
2 Vdd Display power +5V
3 Vo Contrast Adjust. Altered by adjusting the voltage to this pin, grounding it sets it to maximum contrast.
4 RS Register select
5 R/W Data read/write selector. Its possible to read information from a display however there's no need for it here so grounding it sets it permanently write.
6 E Enable strobe
7 DB0 Data Bus 0
8 DB1 Data Bus 1
9 DB2 Data Bus 2
10 DB3 Data Bus 3
11 DB4 Data Bus 4
12 DB5 Data Bus 5
13 DB6 Data Bus 6
14 DB7 Data Bus 7
15 A
LED backlight power +5V
16 K LED backlight power ground
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
#define IRINPUT 5
#define IROUTPUT 2

#define IRMINIMUN_VARIATION 1
#define NEGATIVE_IRMINIMUN_VARIATION -1

#define INT_SIZE 32767
#define MAX_IR_SIGNAL_ARRAY_SIZE 100
#define ARRAY_TERMINATOR -1

LiquidCrystal lcd(RS, RW, ENABLE, D4, D5, D6 ,D7);

boolean shouldDisplayStandBy;
unsigned long timeOnLastChange = 0;
unsigned long button1Deltas[MAX_IR_SIGNAL_ARRAY_SIZE];
unsigned long button1Values[MAX_IR_SIGNAL_ARRAY_SIZE];
int button1DeltasIndex = 0;
int lastValue = 0;

void printOnLCD(char string[]){
  lcd.clear();
  lcd.print(string);
}

void displayStandBy(){
  printOnLCD("aguardando");
}

void displayChoosingButton(){
  printOnLCD("Escolha o botao");
}

void displayRecordingMacro(){
  printOnLCD("Gravando macro");
}

void displayMacroSaved(){
  printOnLCD("Macro salva");
}

void displayPlayingMacro(int macroButtonIndex){
  printOnLCD("Rodando macro 1");
}

void printSequence(){
  int index = 0;
  int timeInterval;
  int irValue;
  Serial.println("Macro called:");
  while(button1Deltas[index] != ARRAY_TERMINATOR && index < MAX_IR_SIGNAL_ARRAY_SIZE){
    timeInterval = button1Deltas[index];
    irValue = button1Values[index];
    index++;
    Serial.print("IRValue ");
    Serial.print(irValue);
    Serial.print(" for delta ");
    Serial.println(timeInterval,DEC);
  }
}

void playMacro(int buttonToPlayMacro){
  int index = 0;
  int timeInterval;
  while(button1Deltas[index] != ARRAY_TERMINATOR && index < MAX_IR_SIGNAL_ARRAY_SIZE){
    timeInterval = button1Deltas[index];
    if(button1Values[index]>100){
      digitalWrite(IROUTPUT,HIGH);
    }else{
      digitalWrite(IROUTPUT,LOW);
    }
    index++;
    delay(timeInterval);
  }
  digitalWrite(IROUTPUT,LOW);
}

boolean anyButtonsPressed(){
  return digitalRead(BUTTON1);
}

void waitForButtonsToBeReleased(){
  while(anyButtonsPressed()){};
}

int askForButtonToRecordMacro(){
  displayChoosingButton();
  boolean buttonChosen = false;
  int buttonToRecordMacro;
  while(!buttonChosen){
    if(digitalRead(BUTTON1)){
      buttonChosen = true;
      buttonToRecordMacro = BUTTON1;
    }
  }
  waitForButtonsToBeReleased();
  
  return buttonToRecordMacro;
}

void recordMacro(int buttonToRecordMacro){
  displayRecordingMacro();
  while(!digitalRead(buttonToRecordMacro)){
    int valueFromIRSEnsor = analogRead(IRINPUT);
    int irVariation = valueFromIRSEnsor - lastValue;
    if(irVariation >= IRMINIMUN_VARIATION || irVariation <= NEGATIVE_IRMINIMUN_VARIATION){
      unsigned long currentTime = millis();
      unsigned long delta = currentTime - timeOnLastChange;
      timeOnLastChange = currentTime; 
      lastValue = valueFromIRSEnsor;
      button1Deltas[button1DeltasIndex] = delta;
      button1Values[button1DeltasIndex] = valueFromIRSEnsor;
      button1DeltasIndex++;
      if(button1DeltasIndex == MAX_IR_SIGNAL_ARRAY_SIZE-1){
        button1Deltas[button1DeltasIndex] = ARRAY_TERMINATOR;
        button1DeltasIndex = 0;
      }else{
        button1Deltas[button1DeltasIndex] = ARRAY_TERMINATOR;
      }
    }
  }
}

void recordMacroRoutine(){
  int buttonToRecordMacro = askForButtonToRecordMacro();
  recordMacro(buttonToRecordMacro);
  displayMacroSaved();
  delay(500);
  waitForButtonsToBeReleased();
}

void setup(){
  pinMode(RECORD_IR_MACRO_BUTTON,INPUT);
  pinMode(BUTTON1,INPUT); 
  pinMode(IROUTPUT, OUTPUT);
  shouldDisplayStandBy = true;
  Serial.begin(9600);
  button1Deltas[0] = ARRAY_TERMINATOR;
}

void loop() {
  if(timeOnLastChange <= 0){
    timeOnLastChange = millis();
  }
  
  if(digitalRead(RECORD_IR_MACRO_BUTTON)){
    recordMacroRoutine();
    shouldDisplayStandBy = true;
  }else if(digitalRead(BUTTON1)){
    int buttonToPlayMacro = 1;
    displayPlayingMacro(buttonToPlayMacro);
    printSequence();
    playMacro(buttonToPlayMacro);
    shouldDisplayStandBy = true;
  }
 
  if(shouldDisplayStandBy){
    shouldDisplayStandBy = false;
    displayStandBy();
  }
}
