part of timetracker;

class Task {
  String name;
  List<Timing> timings = new List<Timing>();
  
  Task(this.name);
  
  Task.fromRawData(raw) {
    name = raw['name'];
    if (raw['timings'] != null) {
      List rawTimings = raw['timings']; 
      timings = rawTimings.map((rawTiming) => new Timing.fromRawData(rawTiming));
    }
  }
}
