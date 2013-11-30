library timetracker;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:intl/intl.dart';
//import 'package:perf_api/perf_api.dart';

part 'component/input_date_directive.dart';
part 'component/input_time_directive.dart';

part 'controller/index_controller.dart';

part 'filter/duration_filter.dart';

part 'model/project.dart';
part 'model/task.dart';
part 'model/timing.dart';
part 'model/user.dart';

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
    type(IndexController);
    
    type(DateInputDirective);
    type(TimeInputDirective);
    
    type(DurationFilter);
    //type(InlineEditableValue);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}