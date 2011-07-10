#define IRINPUT 5
#define ARRAY_SIZE 100

int lastValue = 0;

int values[ARRAY_SIZE];

void setup(){
  Serial.begin(9600);
}

void loop() {
  int irValue = analogRead(IRINPUT);
  int delta = 0;
  while(irValue>0){
    delay(10);
    delta++;
    irValue = analogRead(IRINPUT);
  }
  if(delta>0){
    Serial.print("Time: ");
    Serial.print(delta);
  }
//  Serial.print(" IR: ");
//  Serial.println(values[i]);
}
