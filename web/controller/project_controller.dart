part of timetracker;

@NgController(
    selector: '[project-controller]',
    publishAs: 'ctrl')
class ProjectController {

  ProjectsClient _db;
  LoggedUser _loggedUser;
  Modal _tasksBinModal;
  Scope _scope;
  
  List<User> users = User.defaultUsers();
  
  Project project;
  
  Task selectedTask;
  // TODO: make this "timings" to account for multiple active timings at once, from different users
  Timing activeTiming;
  async.Timer durationUpdateTimer;
  
  Timing newTiming = new Timing();
  Task newTask = new Task();
  
  String _projectId;
  
  bool newTaskFormFocus = false;
  
  ProjectController(this._db, this._loggedUser, this._scope, RouteProvider routeProvider) {
    _projectId = routeProvider.parameters['projectId'];
    
    // whenever activeTiming get changed, we start a timer that updates its duration
    _scope.watch('ctrl.activeTiming', (Timing _activeTiming, Timing) {
      if (_activeTiming == null) {
        if (durationUpdateTimer != null) {
          durationUpdateTimer.cancel();
          durationUpdateTimer = null;
        }
        return;
      }
      durationUpdateTimer = new async.Timer.periodic(new Duration(seconds: 1), (async.Timer timer) {
        _activeTiming.updateDuration(new DateTime.now());
        // update the total duration of the project based on the new timing duration
        project.updateTotalDuration();
      });
    });
    
    _scope.on('\$destroy').listen((ScopeEvent event) {
      if (identical(event.targetScope, _scope)) {
        print('TODO: cleanup timers and pending actions');
      }
    });
    
    _pollForChanges(seq: 0); 
  }
  
  _pollForChanges({int seq: null}) {
    _db.pollForChanges(seq: seq, docIds: [_projectId]).then((List<Project> changedProjects) {
      project = changedProjects[0];
      
      // restore activeTiming for the current user
      activeTiming = project.getActiveTiming(_loggedUser.user);
      
      // preserve selected task
      if (selectedTask != null) {
        var selectedTaskId = selectedTask.id;
        selectedTask = null;
        for (Task task in project.tasks) {
          if (task.id == selectedTaskId) {
            selectedTask = task;
          }
        }
      }
      
      // resume polling
      // TODO: stop polling if scope has been destroyed
      async.scheduleMicrotask(_pollForChanges);
    });
  }
  
  startTimer() {
    var autoTiming = new Timing();
    autoTiming.trackingActive = true;
    autoTiming.user = _loggedUser.user;
    autoTiming.duration = new Duration();
    autoTiming.task = selectedTask; // set the parent task
    _db.generateUuid().then((String uuid) {
      autoTiming.id = uuid;
      selectedTask.timings.add(autoTiming);
      _saveProject();
      
      activeTiming = autoTiming;
    });
  }
  
  stopTimer() {
    activeTiming.updateDuration(new DateTime.now());
    // update the total duration of the project based on the new timing duration
    project.updateTotalDuration();    
    activeTiming.trackingActive = false;
    _saveProject();
    activeTiming = null;
  }
  
  createNewTask() {
    _db.generateUuid().then((String uuid) {
      newTask.id = uuid;
      project.tasks.add(newTask);
      project.updateTotalEstimate();
      _saveProject();
      newTask = new Task();
      
      // TODO: move this out of the controller
      dom.document.querySelector('#newTaskNameBox').focus();
    });
  }
  
  bool timingFormFocused = false;
  bool timingFormInputFocused = false;
  
  newTimingBoxFocusIn() {
    timingFormInputFocused = true;
    timingFormFocused = true;
    // TODO: move this out of the controller
    new async.Timer(new Duration(), () {
      dom.document.querySelector('#dateBox').focus();          
    });    
  }
  
  timingInputFocusIn() {
    timingFormInputFocused = true;
    if (!timingFormFocused) {
      timingFormFocused = true;
      print('formFocused = true');
    }
  }
  
  timingInputFocusOut() {
    timingFormInputFocused = false;
    new async.Timer(new Duration(), () {
      if (!timingFormInputFocused) {
        timingFormFocused = false;
        print('formFocused = false');    
      }
    });
  }
  
  createNewTiming() {
    _db.generateUuid().then((String uuid) {
      newTiming.id = uuid;
      selectedTask.timings.add(newTiming);
      _saveProject();
      newTiming = new Timing();
      
      // TODO: move this out of the controller
      dom.document.querySelector('#dateBox').focus();          
    });
  }
  
  deleteTask(Task task) {    
    // move task from actual tasks to deleted tasks
    project.tasks.remove(task);
    project.deletedTasks.add(task);
    
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
    if (project.deletedTasks.length > 0) {
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
    project.deletedTasks.remove(task);
    project.tasks.add(task);
    
    // save the project
    _saveProject();
    
    if (project.deletedTasks.length == 0) {
      _tasksBinModal.hide();
    }
  }
  
  clearDeletedTasks() {
    if (!dom.window.confirm("Are you sure?")) {
      return;
    }
    
    project.deletedTasks.clear();
    _saveProject();
    _tasksBinModal.hide();
  }
  
  selectTask(Task task) {
    selectedTask = task;
  }
    
  debug() {
    print("sticazzi");
  }

  _saveProject() {
    _save(project);
  }
  
  _save(Project project) {
    _db.put(project);
  }  
}
