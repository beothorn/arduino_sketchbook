#include <Wire.h>


#include <math.h>

#include "WiiChuck.h"
//#include "nunchuck_funcs.h"

#define MAXANGLE 90
#define MINANGLE -90


WiiChuck chuck = WiiChuck();
int angleStart, currentAngle;
int tillerStart = 0;
double angle;

void setup() {
  //nunchuck_init();
  Serial.begin(9600);
  chuck.begin();
  chuck.update();
  //chuck.calibrateJoy();
}


void loop() {
  chuck.update(); 
  
  Serial.print("{");  
      Serial.print("'r':");  
      Serial.print(chuck.readRoll());
    Serial.print(",");  
 //     Serial.print("'p':");
 //     Serial.print(chuck.readPitch());
 //   Serial.print(",");
 //     Serial.print("'aX':");
 //     Serial.print((int)chuck.readAccelX()); 
 //   Serial.print(",");
 //     Serial.print("'aY':");
 //     Serial.print((int)chuck.readAccelY());
 //   Serial.print(",");
 //     Serial.print("'aZ':");
 //     Serial.print((int)chuck.readAccelZ()); 
 //   Serial.print(",");
      Serial.print("'x':");
      Serial.print((int)chuck.readJoyX());
    Serial.print(",");
      Serial.print("'y':");
      Serial.print((int)chuck.readJoyY());
    Serial.print(",");
      Serial.print("'c':");
      Serial.print((bool)chuck.buttonC);
    Serial.print(",");
      Serial.print("'z':");
      Serial.print((bool)chuck.buttonZ);
  Serial.print("}");

  Serial.println();
}
