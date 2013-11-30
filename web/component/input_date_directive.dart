part of timetracker;

/**
 * Usage:
 *
 *     <input type="date" ng-model="datetime">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the input(date) element in the DOM.  If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@NgDirective(selector: 'input[type=date][ng-model]')
class DateInputDirective {
  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;
  
  DateFormat _formatter = new DateFormat('yyyy-MM-dd');

  DateTime _valueToDate(String value) {
    try {
      return _formatter.parse(value);
    } catch (FormatException) {
      return null;
    }
  }
  
  String _dateToValue(DateTime date) {
    if (date == null) {
      return '';
    } else {
      return _formatter.format(date);
    }
  }
  
  DateInputDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      //if (value == null) value = '';

      var currentValue = _valueToDate(inputElement.value);
      if (value == currentValue) return;
      //var start = inputElement.selectionStart;
      //var end = inputElement.selectionEnd;
      inputElement.value =  _dateToValue(value);
      //inputElement.selectionStart = start;
      //inputElement.selectionEnd = end;
    };
    inputElement.onChange.listen(relaxFnArgs(processValue));
    inputElement.onKeyDown.listen((e) => new async.Timer(Duration.ZERO, processValue));
  }

  processValue() {
    var value = _valueToDate(inputElement.value);
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}
