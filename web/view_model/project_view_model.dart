part of timetracker;

/**
 * Each user can have at most one active timing on every task.
 */
class UserProjectViewModel extends UserDuration {
  Timing activeTiming;
  
  UserProjectViewModel(User u):super(u);
}

/**
 * A view of the Task by day and User.
 */
class ProjectViewModel {  
  /**
   * Source model
   */
  Project project;
    
  /**
   * List of UserTaskViewModel, one for each user that contributed to this task
   */
  List<UserProjectViewModel> users = [];
  
  /**
   * Event subscriptions, are cancelled during detach()
   */
  var _subscriptions = new List<async.StreamSubscription>();
    
  ProjectViewModel(this.project) {
    for (User user in User.defaultUsers()) {
      var userViewModel = new UserProjectViewModel(user);
      userViewModel.activeTiming = project.getActiveTiming(user);
      users.add(userViewModel);
    }
    
    for (var task in project.tasks) {
      _registerTask(task);
    }
    // TODO: add a listener for taskAdded
  }
  
  _registerTask(Task task) {
    var sub = task.timingAdded.listen(_registerTiming);
    _subscriptions.add(sub);
  }
  
  _registerTiming(Timing timing) {
    // if the timing is a tracking one
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
  
  /**
   * Stop listening to events from task and timings.
   */
  detach() {
    for (async.StreamSubscription sub in _subscriptions) {
      sub.cancel();
    }
  }
}




