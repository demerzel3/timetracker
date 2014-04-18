part of timetracker; 

class Timing {
  String id;
  User user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration; // = new Duration(); // durata del lavoro (0 di default)
  bool _trackingActive = false; // true if we are tracking the duration of this timing in real time
  
  /**
   * Parent task
   */
  Task task;
    
  Timing();
  
  EventStream<ChangeEvent<Duration>> _durationChanged = new EventStream<ChangeEvent<Duration>>();
  async.Stream<ChangeEvent<Duration>> get durationChanged => _durationChanged.stream; 
  EventStream<ChangeEvent<bool>> _trackingActiveChanged = new EventStream<ChangeEvent<bool>>();
  async.Stream<ChangeEvent<bool>> get trackingActiveChanged => _trackingActiveChanged.stream;
  
  Timing.fromJson(Map raw) {
    id = raw['id'];
    // TODO: move this to another part of the application
    user = User.defaultUsers().firstWhere((User u) => u.id == raw['user']['id']);
    //user = new User(raw['user']['id'], raw['user']['name']);
    date = DateTime.parse(raw['date']);
    duration = new Duration(
        hours: raw['duration']['hours'], 
        minutes: raw['duration']['minutes'],
        seconds: raw['duration']['seconds'] != null ? raw['duration']['seconds'] : 0
    );
    if (raw.containsKey('trackingActive')) {
      _trackingActive = raw['trackingActive'];
    }
  }
  
  /**
   * Updates duration according to the start date (this.date) and the end date provided in endTime.
   */
  Duration updateDuration(DateTime endTime) {
    var prevDuration = duration;
    duration = endTime.difference(date);
    
    _durationChanged.signal(new ChangeEvent<Duration>(duration, prevDuration));
    
    return duration;
  }
  
  bool operator ==(other) {
    if (other is Timing) {
      return id == other.id;
    } else {
      return false;
    }
  }
  
  bool get trackingActive => _trackingActive;
  set trackingActive(bool value) {
    if (value == _trackingActive) {
      return;
    }
    _trackingActive = value;
    _trackingActiveChanged.signal(new ChangeEvent<bool>(value, !value));
  }
  
  int get durationSeconds {
    return duration.inSeconds - duration.inMinutes*Duration.SECONDS_PER_MINUTE;
  }
  
  Map toJson() {
    return {
      'id': id,
      'user': {
        'id': user.id,
        'name': user.name
      },
      'date': date.toString(),
      'duration': {
        'hours': duration.inHours,
        'minutes': duration.inMinutes-duration.inHours*Duration.MINUTES_PER_HOUR,
        'seconds': duration.inSeconds-duration.inMinutes*Duration.SECONDS_PER_MINUTE
      },
      'trackingActive': _trackingActive
    };
  }  
}
