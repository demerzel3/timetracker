part of timetracker; 

class Timing {
  //DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  String id;
  User user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration; // = new Duration(); // durata del lavoro (0 di default)
  bool trackingActive = false; // true if we are tracking the duration of this timing in real time
  /**
   * Parent task
   */
  Task task;
    
  Timing();
  
  Timing.fromJson(Map raw) {
    id = raw['id'];
    // TODO: move this to another part of the application
    user = new User(raw['user']['id'], raw['user']['name']);
    date = DateTime.parse(raw['date']);
    duration = new Duration(hours: raw['duration']['hours'], minutes: raw['duration']['minutes']);
    if (raw.containsKey('trackingActive')) {
      trackingActive = raw['trackingActive'];
    }
  }
  
  /**
   * Updates duration according to the start date (this.date) and the end date provided in endTime.
   */
  Duration updateDuration(DateTime endTime) {
    duration = endTime.difference(date);
    return duration;
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
        'minutes': duration.inMinutes-duration.inHours*Duration.MINUTES_PER_HOUR
      },
      'trackingActive': trackingActive
    };
  }  
}
