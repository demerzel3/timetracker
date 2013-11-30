part of timetracker;

/**
 * Usage:
 *
 *     <input type="time" ng-model="duration">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the input(time) element in the DOM.  If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@NgDirective(selector: 'input[type=time][ng-model]')
class TimeInputDirective {
  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;
  
  var _timeExp = new RegExp('([0-9]{1,2})\:([0-9]{1,2})');
  var _formatter = new NumberFormat('00');

  Duration _stringToDuration(String value) {
    var match = _timeExp.firstMatch(value);
    if (match == null) {
      return null;
    }
    return new Duration(hours: int.parse(match[1]), minutes: int.parse(match[2]));
  }
  
  String _durationToString(Duration duration) {
    if (duration == null) {
      return '';
    } else {
      return _formatter.format(duration.inHours)
          + ":"
          + _formatter.format(duration.inMinutes-duration.inHours*Duration.MINUTES_PER_HOUR);
    }
  }
  
  TimeInputDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      //if (value == null) value = '';

      var currentValue = _stringToDuration(inputElement.value);
      if (value == currentValue) return;
      //var start = inputElement.selectionStart;
      //var end = inputElement.selectionEnd;
      inputElement.value =  _durationToString(value);
      //inputElement.selectionStart = start;
      //inputElement.selectionEnd = end;
    };
    inputElement.onChange.listen(relaxFnArgs(processValue));
    inputElement.onKeyDown.listen((e) => new async.Timer(Duration.ZERO, processValue));
  }

  processValue() {
    var value = _stringToDuration(inputElement.value);
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}
