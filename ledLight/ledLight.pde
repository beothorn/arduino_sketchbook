void displayNumber(int number){
}

void setup()
{
  for(int i=2;i<12;i++){
    pinMode(i, OUTPUT);
  }
  pinMode(12, INPUT);
}

void loop()
{
  if(digitalRead(12)){
    for(int i=2;i<12;i++){
      digitalWrite(i,HIGH);
      delay(10);
      digitalWrite(i,LOW);
    }
  }else{
    for(int i=2;i<12;i++){
      digitalWrite(i,LOW);
    }
  }
}
