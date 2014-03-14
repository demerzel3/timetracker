part of timetracker;

class Project {
  String id;
  String rev;
  String name;
  List<Task> tasks = new List<Task>();
  List<Task> deletedTasks = new List<Task>();
  
  // this should not be persisted
  Duration _totalDuration;
  num _totalEstimate;
  
  Project(this.name);
  
  Project.fromJson(Map raw) {
    id = raw['_id'];
    rev = raw['_rev'];
    name = raw['name'];
    if (raw.containsKey('tasks')) {
      tasks = new List<Task>.from(raw['tasks'].map((rawTask) => new Task.fromJson(rawTask)));
    }
    if (raw.containsKey('deletedTasks')) {
      deletedTasks = new List<Task>.from(raw['deletedTasks'].map((rawTask) => new Task.fromJson(rawTask)));
    }
    
    updateTotalDuration();
    updateTotalEstimate();
  }
  
  /**
   * Updates the total duration for each of the tasks in the project, and for the project itself
   */
  updateTotalDuration() {
    var total = new Duration();
    tasks.forEach((Task task) {
      task.updateTotalDuration();
      total += task.totalDuration;
    });
    _totalDuration = total;
  }
  
  Duration get totalDuration => _totalDuration;
  
  /**
   * Updates the total estimate of the project
   */
  updateTotalEstimate() {
    num total = null;
    tasks.forEach((Task task) {
      if (task.estimate != null) {
        if (total == null) {
          total = task.estimate;
        } else {
          total += task.estimate;
        }
      }
    });
    _totalEstimate = total;
  }
  
  num get totalEstimate => _totalEstimate;
  
  /**
   * Finds in its inner structure the only one possible active timing, or returns null.
   */
  Timing getActiveTiming(User user) {
    for (Task task in tasks) {
      var taskActiveTiming = task.getActiveTiming(user);
      if (taskActiveTiming != null) {
        return taskActiveTiming;
      }
    }
    return null;
  }
  
  /**
   * Serializza id e rev con il tratto basso. 
   */
  Map toJson() {
    var result = {
      'name': name,
      'tasks': tasks,
      'deletedTasks': deletedTasks    
    };
    if (id != null) {
      result["_id"] = id;
      result["_rev"] = rev;
    }
    return result;
  }
}
