part of timetracker;

class ChangeEvent<T> {
  T newValue;
  T oldValue;
  
  ChangeEvent(this.newValue, this.oldValue);
}