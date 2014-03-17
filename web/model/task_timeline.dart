part of timetracker;

class UserDuration {
  User user;
  Duration duration = new Duration();
  
  UserDuration(this.user);
  
  bool isSameUser(User u) {
    return user == u;
  }
}

class DayUserDurations {
  DateTime day;
  List<UserDuration> users = [];
  
  DayUserDurations(DateTime date) {
    // extract day only
    day = new DateTime(date.year, date.month, date.day);
    // add default users immediately
    // TODO: when adding real users, this must be though off better of course
    for (User u in User.defaultUsers()) {
      users.add(new UserDuration(u));
    }
  }
  
  bool isSameDay(DateTime date) {
    return date.year == day.year && date.month == day.month && date.day == day.day;
  }
  
  bool operator ==(other) {
    if (other is DayUserDurations) {
      return other.day == day;
    } else {
      return false;
    }
  }
}

/**
 * A view of the Task by day and User.
 */
class TaskTimeline {  
  /**
   * Source data
   */
  Task task;
  /**
   * List of days for which there is at least a timing
   */
  List<DayUserDurations> days = [];
    
  TaskTimeline(this.task) {
    for (Timing t in task.timings) {
      
      DayUserDurations foundDay;
      for (var day in days) {
        if (day.isSameDay(t.date)) {
          foundDay = day;
          break;
        }
      }
      if (foundDay == null) {
        foundDay = new DayUserDurations(t.date);
        days.add(foundDay);
      }
      
      UserDuration foundUser;
      for (var userDuration in foundDay.users) {
        if (userDuration.isSameUser(t.user)) {
          foundUser = userDuration;
          break;
        }
      }
      
      foundUser.duration += t.duration;
      _updateOnChange(t,  foundUser);
    }
  }
  
  _updateOnChange(Timing t, UserDuration userDuration) {
    t.durationChanged.stream.listen((ChangeEvent<Duration> event) {
      print("duration changed on timing " + t.id);
      userDuration.duration -= event.oldValue;
      userDuration.duration += event.newValue; 
     });
  }
}




