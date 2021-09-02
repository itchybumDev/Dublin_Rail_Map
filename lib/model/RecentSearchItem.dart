class RecentSearchItem {
  String origin;
  String destination;
  DateTime time;

  RecentSearchItem(String origin, String destination, DateTime time) {
    this.origin = origin;
    this.destination = destination;
    this.time = time;
  }

  @override
  String toString() {
    return '$origin?$destination?$time';
  }

  String displayString(){
    return '$origin \u{279C} $destination';
  }
}
