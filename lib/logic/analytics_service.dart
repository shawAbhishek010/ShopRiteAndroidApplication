class AnalyticsService {
  final List<String> _events = [];

  List<String> get events => List.unmodifiable(_events);

  void track(String eventName, {Map<String, Object?> properties = const {}}) {
    _events.add('$eventName:$properties');
  }
}
