part of timetracker;

class Task {
  String id;
  String name;
  List<Timing> timings = new List<Timing>();
  
  Task(this.id, this.name);
  
  Task.fromJson(raw) {
    id = raw['id'];
    name = raw['name'];
    if (raw['timings'] != null) {
      timings = new List<Timing>.from(raw['timings'].map((rawTiming) => new Timing.fromRawData(rawTiming)));
    }
  }
}
