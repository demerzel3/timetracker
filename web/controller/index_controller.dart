part of timetracker;

@NgController(
    selector: '[index-controller]',
    publishAs: 'ctrl')
class IndexController {

  List<User> users = User.defaultUsers();
  
  List<Project> projects;
  String newProjectName = "";
    
  Project selectedProject;
  
  String newTaskName = "";
  Task selectedTask;
  
  Timing newTiming = new Timing();
  
  IndexController(Scope scope, Http http) {
    //print(scope);
    //print(http);
    
    //newTiming.duration = new Duration(hours: 3, minutes: 45);
    
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
  
  debug() {
    print("sticazzi");
  }
  
}
