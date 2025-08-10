class LearningHistoryEntry {
  final String id;
  final String object;
  final DateTime timestamp;

  LearningHistoryEntry({
    required this.id,
    required this.object,
    required this.timestamp,
  });

  factory LearningHistoryEntry.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN: Tambahkan 'Z' di akhir string untuk menandakan ini adalah waktu UTC.
    // Ini akan membuat Dart mem-parsing-nya dengan benar sebagai waktu UTC.
    final utcTimestampString = "${json['timestamp']}Z";

    return LearningHistoryEntry(
      // Pastikan key 'id' ini sesuai dengan response JSON dari server Anda (bisa 'id' atau '_id')
      id: json['id'],
      object: json['object'],
      // Gunakan string yang sudah dimodifikasi untuk parsing
      timestamp: DateTime.parse(utcTimestampString),
    );
  }

  Map<String, dynamic> toJson() {
    return {'object': object, 'timestamp': timestamp.toIso8601String()};
  }
}
