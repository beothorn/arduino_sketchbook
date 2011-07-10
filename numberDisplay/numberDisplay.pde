#define FIRST_LED_PORT 2
#define LAST_LED_PORT 11
#define MAX_DISPLAYABLE_VALUE 1023
#define DIAL_PORT 0
#define TRUE 1
#define FALSE 0

void displayNumber(int number){
  int bitMask = 1;
  for(int i=FIRST_LED_PORT;i<=LAST_LED_PORT;i++){
    int shouldTurnLedOnThiBitToHigh = number & bitMask;
    digitalWrite(i,shouldTurnLedOnThiBitToHigh);
    number = number >> 1;
  }
}

void setup()
{
  for(int i=FIRST_LED_PORT;i<=LAST_LED_PORT;i++){
    pinMode(i, OUTPUT);
  }
  pinMode(BUTTON_PORT, INPUT);
}

int wasPreviouslyPressed = FALSE;
int numberToDisplay = 0;

void loop()
{
  int butonPressed = analogRead(DIAL_PORT);
  displayNumber(numberToDisplay);
}
