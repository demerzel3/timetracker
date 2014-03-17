part of timetracker;

class UserDurationMap {
  Map<String, Duration> _impl = new Map<String, Duration>();
  Duration _totalDuration = new Duration();
  
  Duration get totalDuration => _totalDuration;
  
  Duration operator [](User user) => _impl[user.id];
  
  operator []=(User user, Duration duration) {
    var oldDuration = this[user];
    if (oldDuration != null) {
      _totalDuration -= oldDuration;
    }
    _impl[user.id] = duration;
    _totalDuration += duration;
  }
}

class DayUserDurationMap {
  static DateFormat _dateFormat = new DateFormat('yyyy-MM-dd');
  Map<String, UserDurationMap> _impl = new Map<String, UserDurationMap>();
  
  UserDurationMap getDay(DateTime day, {bool create: false}) {
    var userMap = this[day];
    if (userMap != null || !create) {
      return userMap;
    }
    
    var dayKey = _dateFormat.format(day);
    _impl[dayKey] = new UserDurationMap();
    return _impl[dayKey];
  }
  
  UserDurationMap operator [](DateTime day) {
    var dayKey = _dateFormat.format(day);
    return _impl[dayKey];
  }
}

/**
 * A view of the Task by day and User.
 */
class TaskTimeline {
  static DateFormat _dateFormat = new DateFormat('yyyy-MM-dd');  
  /**
   * Internal implementation using DayUserDurationMap. 
   */
  DayUserDurationMap _daysMap;
  
  /**
   * Source data
   */
  Task task;
  /**
   * Aggregated total duration by user
   */
  UserDurationMap userDurations;
  /**
   * Set of days in which there is some timing
   */
  Set<DateTime> days = new HashSet<DateTime>();
  
  Set<String> keys = new HashSet<String>();
  Map<String, Map<String, Duration>> timeline = new Map<String, Map<String, Duration>>(); 
  
  TaskTimeline(this.task) {
    _daysMap = new DayUserDurationMap();
    for (Timing t in task.timings) {
      var dayOnly = new DateTime(t.date.year, t.date.month, t.date.day);
      days.add(dayOnly);
      var dayKey = _dateFormat.format(t.date);
      keys.add(dayKey);
      
      if (!timeline.containsKey(dayKey)) {
        timeline[dayKey] = new Map<String, Duration>();
      }
      if (!timeline[dayKey].containsKey(t.user)) {
        timeline[dayKey][t.user.id] = new Duration();  
      }
      timeline[dayKey][t.user.id] += t.duration; 
      
      //var userMap = _daysMap.getDay(t.date, create: true); 
      //userMap[t.user] = t.duration;
      //_updateOnChange(t,  userMap);
    }
  }
  
  _updateOnChange(Timing t, UserDurationMap userMap) {
    t.durationChanged.stream.listen((ChangeEvent<Duration> event) {
      print("duration changed on timing " + t.id);
      
      var userDuration = userMap[t.user];
      if (userDuration == null) {
        userDuration = new Duration();
      }
      userDuration -= event.oldValue;
      userDuration += event.newValue;
      userMap[t.user] = userDuration; 
     });
  }
  
  UserDurationMap operator [](DateTime day) => _daysMap[day];
  
   
  
}




