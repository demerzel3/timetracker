part of timetracker;

class Project {
  String name;
  List<Task> tasks = new List<Task>();
  
  Project(this.name);
  
  Project.fromRawData(raw) {
    name = raw['name'];
    if (raw['tasks'] != null) {
      List rawTasks = raw['tasks']; 
      tasks = rawTasks.map((rawTask) => new Task.fromRawData(rawTask));
    }
  }
}
