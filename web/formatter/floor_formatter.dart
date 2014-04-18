part of timetracker;

@Formatter(name: 'floor')
class FloorFormatter {
  call(num value) {
    if (value != null && value != double.NAN && value != double.INFINITY) {
      return value.floor();
    } else {
      return null;
    }
  }
}