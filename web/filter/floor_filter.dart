part of timetracker;

@NgFilter(name: 'floor')
class FloorFilter {
  call(double value) {
    if (value != null) {
      return value.floor();
    } else {
      return null;
    }
  }
}