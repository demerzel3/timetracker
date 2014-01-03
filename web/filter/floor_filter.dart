part of timetracker;

@NgFilter(name: 'floor')
class FloorFilter {
  call(double value) {
    if (value != null && value != double.NAN && value != double.INFINITY) {
      return value.floor();
    } else {
      return null;
    }
  }
}