part of timetracker;

@Controller(
    selector: '[projects-controller]',
    publishAs: 'ctrl')
class ProjectsController implements DetachAware {

  Scope _scope;
  ProjectsClient _db;
  Router _router;
  
  LinkedHashMap<String, Project> projects;
  Iterable<Project> projectsList;
  String newProjectName = "";
    
  Project selectedProject;  
  
  ProjectsController(this._scope, this._db, this._router) {
    projects = new LinkedHashMap<String, Project>();
    _pollForChanges(seq: 0); 
  }
  
  void detach() {
    // is there something to do here?
  }
  
  void _pollForChanges({int seq: null}) {
    _db.pollForChanges(seq: seq).then((List<Project> changedProjects) {
      // Stops polling if scope has been destroyed
      if (_scope.isDestroyed) {
        return;
      }
      
      // add changed projects to the list of projects
      // TODO: improve this!
      changedProjects.forEach((Project project) => _updateProject(project));
      projectsList = projects.values;
      
      // resume polling
      async.scheduleMicrotask(_pollForChanges);
    });
  }
  
  /**
   * Updates a chnaged project in the projects map, preserving selection of project and task.
   */
  void _updateProject(Project project) {
    print(project.name + " updated");
    var wasSelected = (selectedProject != null && projects[project.id] == selectedProject);
    projects[project.id] = project;
    if (wasSelected) {
      selectedProject = project;
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
    
  selectProject(Project project) {
    selectedProject = project;
    _router.go('project', {'projectId': project.id});
    //dom.window.location.hash = '';
    
  }
  
  _saveProject() {
    _save(selectedProject);
  }
  
  _save(Project project) {
    _db.put(project);
  }  
}
