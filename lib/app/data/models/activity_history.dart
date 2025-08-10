class ActivityHistory {
  final String id;
  final String title;
  final String image;
  final DateTime date;
  final bool isCompleted;
  final String instruksi;
  final int points;

  ActivityHistory({
    required this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.isCompleted,
    required this.instruksi,
    required this.points,
  });

  ActivityHistory copyWith({
    String? id,
    String? title,
    String? image,
    DateTime? date,
    bool? isCompleted,
    String? instruksi,
    int? points,
  }) {
    return ActivityHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      instruksi: instruksi ?? this.instruksi,
      points: points ?? this.points,
    );
  }

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      id: json['id'] ?? '', // untuk fallback jika ID tidak dikirim dari backend
      title: json['title'],
      image: json['image'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
      instruksi: json['instruksi'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final data = {
      'title': title,
      'image': image,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'instruksi': instruksi,
      'points': points,
    };

    if (includeId) {
      data['id'] = id;
    }

    return data;
  }
}
