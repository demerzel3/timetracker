part of timetracker;

@NgController(
    selector: '[index-controller]',
    publishAs: 'ctrl')
class IndexController {

  Scope _scope;
  ProjectsClient _db;
  Modal _tasksBinModal;
  
  List<User> users = User.defaultUsers();
  
  List<Project> projects;
  String newProjectName = "";
    
  Project selectedProject;
  
  String newTaskName = "";
  Task selectedTask;
  
  Timing newTiming = new Timing();
  
  IndexController(this._db, this._scope, Http http) {
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
    _tasksBinModal = Modal.wire(dom.document.querySelector('#tasksBinModal'));
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
      _saveProject();
      newTaskName = "";
    });
  }
  
  createNewTiming() {
    _db.generateUuid().then((String uuid) {
      newTiming.id = uuid;
      selectedTask.timings.add(newTiming);
      _saveProject();
      newTiming = new Timing();
    });
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
    _saveProject();

    // fix to the incorrect selection of task after deletion
    // due to nested ng-clicks, this can probably be avoided
    // by removing one level of ng-click
    // TODO: refactor HTML to avoid this behavior
    var currentSelectedTask = selectedTask;
    var me = this;
    var timer = new async.Timer(new Duration(milliseconds:0), () {
      _scope.$apply(() {
        if (currentSelectedTask == task) {
          me.selectedTask = null;
        } else {
          me.selectedTask = currentSelectedTask;
        }
      });      
    });
  }
  
  showTasksBin() {
    if (selectedProject.deletedTasks.length > 0) {
      _tasksBinModal.show();
    }
  }
  
  /**
   * Cancels the elimination of the task
   */
  restoreTask(Task task) {
    // move task from deleted tasks to actual tasks
    selectedProject.deletedTasks.remove(task);
    selectedProject.tasks.add(task);
    
    // save the project
    _saveProject();
    
    if (selectedProject.deletedTasks.length == 0) {
      _tasksBinModal.hide();
    }
  }
  
  clearDeletedTasks() {
    if (!dom.window.confirm("Are you sure?")) {
      return;
    }
    
    selectedProject.deletedTasks.clear();
    _saveProject();
  }
  
  selectTask(Task task) {
    selectedTask = task;
  }
    
  debug() {
    print("sticazzi");
  }

  _saveProject() {
    _save(selectedProject);
  }
  
  _save(Project project) {
    _db.put(project);
  }  
}
