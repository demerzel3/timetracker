part of timetracker;

class Task {
  String id;
  String name = '';
  num estimate;
  List<Timing> timings = new List<Timing>();
  
  EventStream<Timing> _timingAdded = new EventStream<Timing>();
  async.Stream<Timing> get timingAdded => _timingAdded.stream;
  
  Duration _totalDuration;
  
  Task();
  
  Task.fromJson(raw) {
    id = raw['id'];
    name = raw['name'];
    estimate = raw['estimate'];
    if (raw['timings'] != null) {
      timings = new List<Timing>.from(raw['timings'].map((rawTiming) => new Timing.fromJson(rawTiming)..task = this));
    }
  }
  
  /**
   * Adds a new timing, fires it via timingAdded
   */
  addTiming(Timing timing) {
    timings.add(timing);
    _timingAdded.signal(timing);
  }
  
  updateTotalDuration() {
    var total = new Duration();
    timings.forEach((Timing timing) => total += timing.duration);
    _totalDuration = total;
  }
  Duration get totalDuration => _totalDuration;
  
  /**
   * Finds in its inner structure the only one possible active timing, or returns null.
   */
  Timing getActiveTiming(User user) {
    for (Timing timing in timings) {
      if (timing.user == user && timing.trackingActive) {
        return timing;
      }
    }
    return null;
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
