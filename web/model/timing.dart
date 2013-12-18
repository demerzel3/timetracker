part of timetracker; 

class Timing {
  //DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  String id;
  User user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration; // = new Duration(); // durata del lavoro (0 di default)
  
  toJson() {
    return {
      id: id,
      user: user.id,
      date: date,
      duration: duration
    };
  }
  
  Timing();
  
  Timing.fromJson(raw) {
    
  }
}
