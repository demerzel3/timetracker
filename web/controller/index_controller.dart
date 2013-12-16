part of timetracker;

@NgController(
    selector: '[index-controller]',
    publishAs: 'ctrl')
class IndexController {

  ProjectsClient _db;
  
  List<User> users = User.defaultUsers();
  
  List<Project> projects;
  String newProjectName = "";
    
  Project selectedProject;
  
  String newTaskName = "";
  Task selectedTask;
  
  Timing newTiming = new Timing();
  
  IndexController(this._db, Scope scope, Http http) {
    //print(_db);
    //_db.getAll();
    //print(scope);
    //print(http);
    
    //newTiming.duration = new Duration(hours: 3, minutes: 45);
    
    
    /*
    Project banco = new Project("Banco Farmaceutico");
    banco.tasks.add(new Task("123", "Velocizzare addVolontario"));
    
    projects = new List<Project>();
    projects.add(banco);
    */
    
    _db.getAll().then((List<Project> loadedProjects) {      
      projects = new List<Project>.from(loadedProjects, growable: true);
    });
  }
  
  createNewProject() {
    if (newProjectName.length > 0) {
      var project = new Project(newProjectName);
      _db.post(project).then((Project project) {
        projects.add(project);  
        newProjectName = "";
      });
    }
  }
  
  createNewTask() {
    if (newTaskName.length == 0) {
      return;
    }
    _db.generateUuid().then((String uuid) {
      selectedProject.tasks.add(new Task(uuid, newTaskName));        
      _db.put(selectedProject);
      newTaskName = "";
    });
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
  
  deleteTask(Task task) {
    // move task from actual tasks to deleted tasks
    selectedProject.tasks.remove(task);
    selectedProject.deletedTasks.add(task);
    
    // save the project
    _db.put(selectedProject);
  }
  
  selectTask(Task task) {
    selectedTask = task;
  }
  
  debug() {
    print("sticazzi");
  }
  
}
