part of timetracker;

class UserDuration {
  User user;
  Duration duration = new Duration();
  
  UserDuration(this.user);
  
  bool isSameUser(User u) {
    return user == u;
  }
}

/**
 * Each user can have at most one active timing on every task.
 */
class UserTaskViewModel extends UserDuration {
  Timing activeTiming;
  
  UserTaskViewModel(User u):super(u);
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
class TaskViewModel {  
  /**
   * Source data
   */
  Task task;
  
  /**
   * List of days for which there is at least a timing
   */
  List<DayUserDurations> days = [];
  
  /**
   * List of UserTaskViewModel, one for each user that contributed to this task
   */
  List<UserTaskViewModel> users = [];
  
  /**
   * Event subscriptions, are cancelled during detach()
   */
  var _subscriptions = new List<async.StreamSubscription>();
    
  TaskViewModel(this.task) {
    for (User u in User.defaultUsers()) {
      users.add(new UserTaskViewModel(u));
    }    
    
    for (Timing t in task.timings) {
      _registerTiming(t);
    }
    
    var sub = task.timingAdded.listen(_registerTiming);
    _subscriptions.add(sub);
  }
  
  _registerTiming(Timing timing) {
    var userDuration = _getUserDuration(timing);
    userDuration.duration += timing.duration;
    _updateOnDurationChange(timing, userDuration);
    
    // attach the active timing to its user
    if (timing.trackingActive) {
      var userViewModel = _getUserViewModel(timing.user);
      userViewModel.activeTiming = timing;
      _updateOnTrackingChange(timing, userViewModel);
    }
  }
  
  UserTaskViewModel _getUserViewModel(User u) {
    for (var viewModel in users) {
      if (viewModel.isSameUser(u)) {
        return viewModel;
      }
    }
    // this should never be executed
    return null;
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
  
  _updateOnTrackingChange(Timing t, UserTaskViewModel userViewModel) {
    async.StreamSubscription<ChangeEvent<bool>> sub;
    sub = t.trackingActiveChanged.listen((ChangeEvent<bool> event) {
      if (event.newValue) {
        userViewModel.activeTiming = t;
      } else {
        userViewModel.activeTiming = null;
        // cancels the subscription immediately: a stopped tracking is never restarted again
        sub.cancel();
        _subscriptions.remove(sub);
      }
     });
    _subscriptions.add(sub);    
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




