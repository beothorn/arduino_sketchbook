#include <Wire.h>
#include <math.h>
#include "WiiChuck.h"

#define ECHOPIN 2                            // Pin to receive echo pulse
#define TRIGPIN 3                            // Pin to send trigger pulse
#define INPUT1 6
#define INPUT2 9
#define INPUT3 8
#define INPUT4 7

#define MAXANGLE 90
#define MINANGLE -90


WiiChuck chuck = WiiChuck();
int angleStart, currentAngle;
int tillerStart = 0;
double angle;

enum commands {
  STOP,
  FORWARD,
  BACKWARD,
  CLOCKWISE,
  COUNTERCLOCKWISE
};

void setup() {
  Serial.begin(9600);
  chuck.begin();
  chuck.update();

  pinMode(INPUT1, OUTPUT);
  pinMode(INPUT2, OUTPUT);
  pinMode(INPUT3, OUTPUT);
  pinMode(INPUT4, OUTPUT);
  
  pinMode(ECHOPIN, INPUT);
  pinMode(TRIGPIN, OUTPUT);
  
}

void stopCar(){
  digitalWrite(INPUT1, LOW);
  digitalWrite(INPUT2, LOW);
  digitalWrite(INPUT3, LOW);
  digitalWrite(INPUT4, LOW);
}

void forward(){
  digitalWrite(INPUT1, HIGH);
  digitalWrite(INPUT2, LOW);
  digitalWrite(INPUT3, HIGH);
  digitalWrite(INPUT4, LOW);
}

void backward(){
  digitalWrite(INPUT1, LOW);
  digitalWrite(INPUT2, HIGH);
  digitalWrite(INPUT3, LOW);
  digitalWrite(INPUT4, HIGH);
}

void counterclockwise(){
  digitalWrite(INPUT1, LOW);
  digitalWrite(INPUT2, HIGH);
  digitalWrite(INPUT3, HIGH);
  digitalWrite(INPUT4, LOW);
}

void clockwise(){
  digitalWrite(INPUT1, HIGH);
  digitalWrite(INPUT2, LOW);
  digitalWrite(INPUT3, LOW);
  digitalWrite(INPUT4, HIGH);
}

void doCommand(int command){
  switch(command) {
    case STOP:
      stopCar();
      break;
    case FORWARD:
      forward();
      break;
    case BACKWARD:
      backward();
      break;
    case CLOCKWISE:
      clockwise();
      break;
    case COUNTERCLOCKWISE:
      counterclockwise();
      break;
  }
}

void serial(){
  if (Serial.available() > 0) {
    int byteRead = Serial.read();
    doCommand(byteRead);
  }
}

void numChuck(){
  chuck.update(); 
  int y = (int)chuck.readJoyY();
  int x = (int)chuck.readJoyX();
  int command = 0;
  if(y>100){
    forward();
    command = 1;
  }else if(y<-100){
    backward();
    command = 1;
  }
  if(x>100){
   clockwise();
   command = 1;
  }else if(x<-100){
    counterclockwise();
    command = 1;
  }
  if(!command)
    stopCar(); 
  Serial.println();
}

void test(){
  forward();
  delay(1000);
  clockwise();
  delay(1000);
  forward();
  delay(1000);
  backward();
  delay(1000);
  counterclockwise();
  delay(1000);
  backward();
  delay(1000);
  stopCar();
  delay(1000);
}

int calculateDistance(){
  digitalWrite(TRIGPIN, LOW);                   // Set the trigger pin to low for 2uS
  delayMicroseconds(2);
  digitalWrite(TRIGPIN, HIGH);                  // Send a 10uS high to trigger ranging
  delayMicroseconds(10);
  digitalWrite(TRIGPIN, LOW);                   // Send pin low again
  int distance = pulseIn(ECHOPIN, HIGH);        // Read in times pulse
  return distance/58;                        // Calculate distance from time of pulse        
}

void wallHugger(){
  int distance = calculateDistance();
  if(distance < 20)
    clockwise();
  else
    forward();
}

void loop() {
  wallHugger();
  //test();
}
