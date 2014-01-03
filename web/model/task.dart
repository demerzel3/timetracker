part of timetracker;

class Task {
  String id;
  String name = '';
  double estimate;
  List<Timing> timings = new List<Timing>();
  
  Task();
  
  Task.fromJson(raw) {
    id = raw['id'];
    name = raw['name'];
    estimate = raw['estimate'];
    if (raw['timings'] != null) {
      timings = new List<Timing>.from(raw['timings'].map((rawTiming) => new Timing.fromJson(rawTiming)));
    }
  }
  
  Duration get totalDuration {
    var total = new Duration();
    timings.forEach((Timing timing) => total += timing.duration);
    return total;
  }
  
  Map toJson() {
    return {
      'id': id,
      'name': name,
      'estimate': estimate,
      'timings': timings
    };
  }
  
  String toString() {
    return 'Task[id='+ id +', name:'+ name +']';
  }
}
