part of timetracker; 

class Timing {
  //DateFormat _formatter = new DateFormat('dd/MM/yyyy');
  
  User user;
  DateTime date = new DateTime.now(); // data a cui si riferisce il lavoro
  Duration duration = new Duration(); // durata del lavoro (0 di default)
}
