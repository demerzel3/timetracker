part of timetracker; 

class Timing {
  //DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  String id;
  User user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration; // = new Duration(); // durata del lavoro (0 di default)
  
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
      }
    };
  }
  
  Timing();
  
  Timing.fromJson(raw) {
    id = raw['id'];
    // TODO: move this to another part of the application
    user = new User(raw['user']['id'], raw['user']['name']);
    date = DateTime.parse(raw['date']);
    duration = new Duration(hours: raw['duration']['hours'], minutes: raw['duration']['minutes']);
  }
}
