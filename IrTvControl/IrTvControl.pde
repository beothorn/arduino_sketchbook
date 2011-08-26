#include "IRremote.h"
IRsend irsend;

#define NBITS 32
#define PRESS_DELAY 800
#define BAUD_RATE 9600
#define COMMAND_COUNT 7


#define INFO                0xE0E0F807
#define POWER               0xE0E040BF
#define MACRO_CHANGETOPC    0x00000001
#define SOURCE              0xE0E0807F
#define TV                  0xE0E0D827
#define UP                  0xE0E006F9
#define DOWN                0xE0E08679
#define LEFT                0xE0E0A659
#define RIGHT               0xE0E046B9

#define CHANNELUP           0xE0E048B7
#define CHANNELDOWN         0xE0E008F7
#define VOLUMEUP            0xE0E0E01F
#define VOLUMEDOWN          0xE0E0D02F


#define REW                 0xE0E0A25D
#define PAUSE               0xE0E052AD
#define FF                  0xE0E012ED
#define REC                 0xE0E0926D
#define PLAY                0xE0E0E21D
#define STOP                0xE0E0629D

#define A                   0xE0E036C9
#define B                   0xE0E028D7
#define C                   0xE0E0A857
#define D                   0xE0E06897

#define ENTER               0xE0E016E9

unsigned long commands[COMMAND_COUNT] =
{
    POWER,     
    MACRO_CHANGETOPC,
    TV,         
    CHANNELUP,
    CHANNELDOWN,
    VOLUMEUP,
    VOLUMEDOWN
};

void setup()
{
  Serial.begin(BAUD_RATE);
}

void doCommandWithDelay(unsigned long command,int delayBetweenCommands){
  Serial.print("Sending command: ");
  Serial.println(command);
  irsend.sendSamsung(command,NBITS);
  delay(delayBetweenCommands);
}

void doCommand(unsigned long command){
  if(command == MACRO_CHANGETOPC){
    doCommandWithDelay(TV,PRESS_DELAY);
    doCommandWithDelay(SOURCE,PRESS_DELAY);
    doCommandWithDelay(DOWN,PRESS_DELAY);
    doCommandWithDelay(DOWN,PRESS_DELAY);
    doCommandWithDelay(DOWN,PRESS_DELAY);
    doCommandWithDelay(ENTER,0);
    return;
  }
  doCommandWithDelay(command,0);
}

void loop() {
  if (Serial.available() > 0) {
    int inByte = Serial.read()-1;
    if(inByte>COMMAND_COUNT){
      Serial.print("Unknown command code: ");
      Serial.println(inByte);
      return;
    }
    doCommand(commands[inByte]);
  }
} 
