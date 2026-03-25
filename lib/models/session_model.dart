class SessionRecord {
  final DateTime date;
  final int durationSeconds;
  final bool hitLimit;

  SessionRecord({
    required this.date,
    required this.durationSeconds,
    required this.hitLimit,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'durationSeconds': durationSeconds,
    'hitLimit': hitLimit,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
    date: DateTime.parse(j['date']),
    durationSeconds: j['durationSeconds'],
    hitLimit: j['hitLimit'],
  );
}
