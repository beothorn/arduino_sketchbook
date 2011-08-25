#include "IRremote.h"
IRsend irsend;

#define NBITS 32
#define PRESS_DELAY 800
#define BAUD_RATE 9600

#define INFO          0xE0E0F807
#define POWER         0xE0E040BF
#define SOURCE        0xE0E0807F
#define TV            0xE0E0D827
#define UP            0xE0E006F9
#define DOWN          0xE0E08679
#define LEFT          0xE0E0A659
#define RIGHT         0xE0E046B9

#define CHANNELUP     0xE0E048B7
#define CHANNELDOWN   0xE0E008F7

#define REW           0xE0E0A25D
#define PAUSE         0xE0E052AD
#define FF            0xE0E012ED
#define REC           0xE0E0926D
#define PLAY          0xE0E0E21D
#define STOP          0xE0E0629D

#define A             0xE0E036C9
#define B             0xE0E028D7
#define C             0xE0E0A857
#define D             0xE0E06897

#define ENTER         0xE0E016E9

void setup()
{
  Serial.begin(BAUD_RATE);
}

void doCommand(unsigned long command){
  Serial.print("Sending command: ");
  Serial.println(command);
  irsend.sendSamsung(command,NBITS);
  delay(PRESS_DELAY);
}

void loop() {
  if (Serial.available() > 0) {
    int inByte = Serial.read();
    switch (inByte) {
      case '1':    
          doCommand(POWER);
      break;
      case '2':
          doCommand(TV);
          doCommand(SOURCE);
          doCommand(DOWN);
          doCommand(DOWN);
          doCommand(DOWN);
          doCommand(ENTER);
      break;
      case '3':    
          doCommand(TV);
      break;
      case '4':    
          doCommand(CHANNELUP);
      break;
      case '5':    
          doCommand(CHANNELDOWN);
      break;
      case '6':    
          doCommand(UP);
      break;
      case '7':    
          doCommand(DOWN);
      break;
      case '8':    
          doCommand(LEFT);
      break;
      case '9':    
          doCommand(RIGHT);
      break;
    }
  }
} 
