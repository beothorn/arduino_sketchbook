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
  
  int getMinutes()
  {
    return _minutes;
  }
  
  void setMinutes(int minutes){
    _minutes = minutes % 60;
  }
  
  int getHours()
  {
    return _hours;
  }
  
  void setHours(int hours){
    _hours = hours % 24;
  }
  
private:
  int _seconds;
  int _minutes;
  int _hours;
};
