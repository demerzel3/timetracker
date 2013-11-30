part of timetracker;

@NgFilter(name: 'duration')
class DurationFilter {
  var _formatter = new NumberFormat('00');
  
  call(Duration duration, String format) {
    return format
        .replaceFirst('hh', _formatter.format(duration.inHours))
        .replaceFirst('mm', _formatter.format(duration.inMinutes - duration.inHours*Duration.MINUTES_PER_HOUR));    
  }
}