part of timetracker;

class Task {
  String id;
  String name = '';
  double score;
  double estimate;
  List<Timing> timings = new List<Timing>();
  
  Task();
  
  Task.fromJson(raw) {
    id = raw['id'];
    name = raw['name'];
    score = raw['score'];
    estimate = raw['estimate'];
    if (raw['timings'] != null) {
      timings = new List<Timing>.from(raw['timings'].map((rawTiming) => new Timing.fromJson(rawTiming)));
    }
  }
  
  Map toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'estimate': estimate,
      'timings': timings
    };
  }
  
  String toString() {
    return 'Task[id='+ id +', name:'+ name +']';
  }
}
