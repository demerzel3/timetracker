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
  
  /**
   * Event dubscriptions, are cancelled during dispose()
   */
  var _subscriptions = new List<async.StreamSubscription>();
    
  TaskTimeline(this.task) {
    for (Timing t in task.timings) {
      var userDuration = _getUserDuration(t);
      userDuration.duration += t.duration;
      _updateOnDurationChange(t, userDuration);
    }
    
    var sub = task.timingAdded.listen((Timing timing) {
      var userDuration = _getUserDuration(timing);
      userDuration.duration += timing.duration;
      _updateOnDurationChange(timing, userDuration);      
    });
    _subscriptions.add(sub);
  }
  
  UserDuration _getUserDuration(Timing t) {
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
    return foundUser;
  }
  
  _updateOnDurationChange(Timing t, UserDuration userDuration) {
    var sub = t.durationChanged.listen((ChangeEvent<Duration> event) {
      //print("duration changed on timing " + t.id);
      userDuration.duration -= event.oldValue;
      userDuration.duration += event.newValue; 
     });
    _subscriptions.add(sub);
  }
  
  /**
   * Stop listening to events from task and timings.
   */
  detach() {
    for (async.StreamSubscription sub in _subscriptions) {
      sub.cancel();
    }
  }
}




