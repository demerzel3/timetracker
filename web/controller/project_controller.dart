part of timetracker;

@NgController(
    selector: '[project-controller]',
    publishAs: 'ctrl')
class ProjectController {

  Scope _scope;
  ProjectsClient _db;
  Modal _tasksBinModal;
  
  List<User> users = User.defaultUsers();
  
  Project project;
  
  String newTaskName = "";
  Task selectedTask;
  
  Timing newTiming = new Timing();
  
  String _projectId;
  
  ProjectController(this._db, this._scope, Http http, RouteProvider routeProvider) {
    _projectId = routeProvider.parameters['projectId'];
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
    
    /*
    _db.getAll().then((List<Project> loadedProjects) {      
      projects = new List<Project>.from(loadedProjects, growable: true);
    });
    */
    _pollForChanges(seq: 0); 
  }
  
  _pollForChanges({int seq: null}) {
    _db.pollForChanges(seq: seq, docIds: [_projectId]).then((List<Project> changedProjects) {
      project = changedProjects[0];
      
      // resume polling
      async.scheduleMicrotask(_pollForChanges);
    });
  }
  
  /**
   * Updates a chnaged project in the projects map, preserving selection of project and task.
   */
  _updateProject(Project project) {
    print(project.name + " updated");
    var wasSelected = (selectedProject != null && projects[project.id] == selectedProject);
    projects[project.id] = project;
    if (wasSelected) {
      selectedProject = project;
      if (selectedTask != null) {
        var selectedTaskId = selectedTask.id;
        selectedTask = null;
        for (int i = 0; i < project.tasks.length; i++) {
          if (project.tasks[i].id == selectedTaskId) {
            selectedTask = project.tasks[i];
          }
        }
      }
    }
  }
  
  createNewProject() {
    if (newProjectName.length > 0) {
      var project = new Project(newProjectName);
      _db.post(project).then((Project project) {
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
      if (_tasksBinModal == null) {
        _tasksBinModal = Modal.wire(dom.document.querySelector('#tasksBinModal'));
      }
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
