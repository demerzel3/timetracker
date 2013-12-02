library timetracker;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:intl/intl.dart';
import 'package:serialization/serialization.dart';

part 'component/input_date_directive.dart';
part 'component/input_time_directive.dart';

part 'controller/index_controller.dart';

part 'filter/duration_filter.dart';

part 'model/project.dart';
part 'model/task.dart';
part 'model/timing.dart';
part 'model/user.dart';

part 'data/couchdb_database.dart';

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
    type(IndexController);
    
    type(DateInputDirective);
    type(TimeInputDirective);
    
    type(DurationFilter);
    
    // I'm not 100% convinced of this, for this kind of things I would prefer
    // a named entry, like CouchDbDatabase('projects')
    factory(CouchDbDatabase, (Injector injector) {
      return new CouchDbDatabase(injector.get(Http), injector.get(Serialization), 'http://127.0.0.1:5984', 'projects');
    });
    
    // I still don't get it: how do I unserialize real world json?
    factory(Serialization, (Injector injector) {
      projectToMap(Project p) => {"name": p.name, "tasks": p.tasks};
      createProject(Map m) => new Project(m["name"]);
      fillProject(Project p, Map m) => p.name = m["name"];
      var projectRule = new ClosureRule(Project, projectToMap, createProject, fillProject);
      
      taskToMap(Task t) => {"name": t.name};
      createTask(Map m) => new Task(m["name"]);
      fillTask(Task t, Map m) => t.name = m["name"];
      var taskRule = new ClosureRule(Task, taskToMap, createTask, fillTask);
      
      return new Serialization()
        ..selfDescribing = false
        ..addRule(projectRule)
        ..addRule(taskRule);
    });
    
    //type(InlineEditableValue);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}