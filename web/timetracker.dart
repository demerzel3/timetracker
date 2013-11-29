import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:intl/intl.dart';
//import 'package:perf_api/perf_api.dart';

class Timing {
  //DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  String user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration; // durata del lavoro
}

class Task {
  String name;
  List<Timing> timings = new List<Timing>();
  
  Task(this.name);
}

class Project {
  String name;
  List<Task> tasks = new List<Task>();
  
  Project(this.name);
}

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

@NgController(
    selector: '[index-controller]',
    publishAs: 'ctrl')
class IndexController {

  List<Project> projects;
  String newProjectName = "";
    
  Project selectedProject;
  
  String newTaskName = "";
  Task selectedTask;
  
  Timing newTiming = new Timing();
  
  IndexController(Scope scope, Http http) {
    //print(scope);
    //print(http);
    
    Project banco = new Project("Banco Farmaceutico");
    banco.tasks.add(new Task("Velocizzare addVolontario"));
    
    projects = new List<Project>();
    projects.add(banco);
  }
  
  createNewProject() {
    if (newProjectName.length > 0) {
      projects.add(new Project(newProjectName));
      newProjectName = "";
    }
  }
  
  createNewTask() {
    if (newTaskName.length > 0) {
      selectedProject.tasks.add(new Task(newTaskName));
      newTaskName = "";
    }
  }
  
  createNewTiming() {
    selectedTask.timings.add(newTiming);
    newTiming = new Timing();
  }
  
  selectProject(Project project) {
    selectedProject = project;
    if (project.tasks.length > 0) {
      selectedTask = project.tasks[0];
    } else {
      selectedTask = null;
    }
  }
  
  selectTask(Task task) {
    selectedTask = task;
  }
  
}

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
    type(IndexController);
    type(DateInputDirective);
    //type(InlineEditableValue);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}