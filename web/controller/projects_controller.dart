part of timetracker;

@NgController(
    selector: '[projects-controller]',
    publishAs: 'ctrl')
class ProjectsController {

  ProjectsClient _db;
  Router _router;
  
  LinkedHashMap<String, Project> projects;
  Iterable<Project> projectsList;
  String newProjectName = "";
    
  Project selectedProject;  
  
  ProjectsController(this._db, this._router) {
    projects = new LinkedHashMap<String, Project>();
    _pollForChanges(seq: 0); 
  }
  
  _pollForChanges({int seq: null}) {
    _db.pollForChanges(seq: seq).then((List<Project> changedProjects) {
      // add changed projects to the list of projects
      // TODO: improve this!
      changedProjects.forEach((Project project) => _updateProject(project));
      projectsList = projects.values;
      
      // resume polling
      // TODO: stop polling if scope has been destroyed
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
