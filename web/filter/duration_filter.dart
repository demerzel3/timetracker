part of timetracker;

@NgFilter(name: 'duration')
class DurationFilter {
  var _formatter = new NumberFormat('0');
  var _formatter2 = new NumberFormat('00');

  /**
   * Format is a string in the form:
   *   '{durationFormat}[|{zeroExpr}]'
   */
  call(Duration duration, String format) {
    var chunks = format.split('|');
    String zeroExpr = null;
    format = chunks[0];
    if (chunks.length > 1) {
      zeroExpr = chunks[1];
    }
    if (zeroExpr != null && duration.inMicroseconds == 0) {
      return zeroExpr;
    }
    return format
        .replaceFirst('hh', _formatter2.format(duration.inHours))
        .replaceFirst('h', _formatter.format(duration.inHours))
        .replaceFirst('mm', _formatter2.format(duration.inMinutes - duration.inHours*Duration.MINUTES_PER_HOUR));    
  }
}