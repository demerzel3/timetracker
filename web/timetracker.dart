//import 'dart:html';
import 'package:angular/angular.dart';
import 'package:intl/intl.dart';
//import 'package:perf_api/perf_api.dart';

class Timing {
  DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  String user;
  DateTime date; // data (in formato gg/mm/aaaa) a cui si riferisce il lavoro
  double duration;
  
  String durationString;
  
  Timing() {
    date = new DateTime.now();
  }
    
  String get formattedDate => _formatter.format(date);
  set formattedDate(String dateExpr) {
    if (dateExpr.length == 10) {
      date = _formatter.parse(dateExpr);
    }
  }
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
    //type(InlineEditableValue);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}