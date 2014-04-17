part of timetracker;

class Task {
  String id;
  String name = '';
  // estimate is always in hours
  num estimate;
  List<Timing> timings = new List<Timing>();
  
  /**
   * Ratio between the total tracked time and the estimate. If there is no estimate, the ratio is always 1.
   */
  num progress;
  /**
   * Weight is the ratio between the task estimate and the project total estimate.
   */
  num weight;
  
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
   * An update to the weight is necessary everytime a change in the project totalestimate is registered
   */
  updateWeight(Project project) {
    var durationInHours = totalDuration.inSeconds / Duration.SECONDS_PER_HOUR;
    var hasEstimate = (estimate != null && estimate > 0); 
    if (hasEstimate) {
      weight = estimate/project.totalEstimate;
    } else {
      if (project.totalEstimate != null && project.totalEstimate > 0) {
        weight = durationInHours/project.totalEstimate;
      } else {
        var totalDurationInHours = project.totalDuration.inSeconds / Duration.SECONDS_PER_HOUR;
        weight = durationInHours/totalDurationInHours;
      }
    }
  }
  /**
   * An update tot he progress is necessary everytime the task estiate or duration changes
   */
  updateProgress(Project project) {
    var durationInHours = totalDuration.inSeconds / Duration.SECONDS_PER_HOUR;
    var hasEstimate = (estimate != null && estimate > 0); 
    if (hasEstimate) {
      progress = durationInHours/estimate;
    } else {
      progress = 1;
    }    
  }
  
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
