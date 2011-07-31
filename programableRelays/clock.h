class Clock {
public:
  Clock() {
  }
  
  int getSeconds()
  {
    return _seconds;
  }
  
  void setSeconds(int seconds){
    _seconds = seconds % 60;
  }
  
  void addSecond(){
    _seconds++;
    _seconds = _seconds % 60;
  }
  
  void decreaseSecond(){
    _seconds--;
    if(_seconds<0)
      _seconds = 59;
  }
  
  int getMinutes()
  {
    return _minutes;
  }
  
  void setMinutes(int minutes){
    _minutes = minutes % 60;
  }

  void addMinute(){
    _minutes++;
    _minutes = _minutes % 60;
  }
  
  void decreaseMinute(){
    _minutes--;
    if(_minutes<0)
      _minutes = 59;
  }
  
  int getHours()
  {
    return _hours;
  }
  
  void setHours(int hours){
    _hours = hours % 24;
  }
  
  void addHour(){
    _hours++;
    _hours = _hours % 24;
  }
  
  void decreaseHour(){
    _hours--;
    if(_hours<0)
      _hours = 23;
  }
  
  void updateTimeForDelta(int delta){
    _seconds += delta / 1000;
    _minutes += _seconds / 60;
    _seconds = _seconds % 60;
    _hours += _minutes / 60;
    _minutes = _minutes % 60;
    _hours = _hours % 24;
  }
  
  void asString(char strOut[6])
  {
    strOut[0] = '0' + (_hours / 10);
    strOut[1] = '0' + (_hours % 10);
    strOut[3] = ':';
    strOut[4] = '0' + (_minutes / 10);
    strOut[5] = '0' + (_minutes % 10);
    strOut[6] = '\0';
  }
  
  bool equals(Clock otherClock){
    if(_minutes != otherClock.getMinutes()){
      return false;
    }
    if(_hours != otherClock.getHours()){
      return false;
    }
    return true;
  }
  
  void copy(Clock otherClock){
    _seconds = otherClock.getSeconds();
    _minutes = otherClock.getMinutes();
    _hours = otherClock.getHours();
  }
  
private:
  int _seconds;
  int _minutes;
  int _hours;
};
