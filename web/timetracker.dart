library timetracker;

//@MirrorsUsed(symbols: const ['name', 'tasks', 'timings', 'id', 'user', 'date', 'duration'], override: '*')
import 'dart:html' as dom;
import 'dart:async' as async;
import 'dart:convert';
import 'dart:collection';

/* Should be used to reduce ouput size
@MirrorsUsed(targets: const[
    'angular',
    'angular.core',
    'angular.core.dom',
    'angular.filter',
    'angular.perf',
    'angular.directive',
    'angular.routing',
    'angular.core.parser',
    'perf_api',
    'NodeTreeSanitizer'
  ],
  override: '*')
import 'dart:mirrors';
*/
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:intl/intl.dart';
import 'package:bootjack/bootjack.dart';
//import 'package:serialization/serialization.dart';

part 'component/input_date_directive.dart';
part 'component/input_time_directive.dart';

part 'controller/projects_controller.dart';
part 'controller/project_controller.dart';

part 'filter/duration_filter.dart';

part 'model/project.dart';
part 'model/task.dart';
part 'model/timing.dart';
part 'model/user.dart';

part 'data/couchdb_client.dart';
part 'data/projects_client.dart';

class TTRouteInitializer implements RouteInitializer {
  void init(Router router, ViewFactory view) {
    router.root
      ..addRoute(
        name: 'projects',
        defaultRoute: true,
        enter: view('view/projects.html'))
      ..addRoute(
        name: 'project',
        path: '/projects/:projectId',
        enter: view('view/project.html'));
      
  }
}

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
    type(ProjectsController);
    type(ProjectController);
    
    type(DateInputDirective);
    type(TimeInputDirective);
    
    type(DurationFilter);
    
    type(RouteInitializer, implementedBy: TTRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
    
    factory(ProjectsClient, (Injector injector) {
      //return new ProjectsClient(injector.get(Http), 'http://127.0.0.1:5984');
      // http://192.168.230.230/
      return new ProjectsClient(injector.get(Http), 'http://192.168.230.230:5984');
    });

    /*
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
    */
    
    //type(InlineEditableValue);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}