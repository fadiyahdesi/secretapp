class ActivityHistory {
  final String id;
  final String title;
  final String image;
  final DateTime date;
  final bool isCompleted;
  String instruksi;

  ActivityHistory({
    required this.id,
    required this.title,
    required this.image,
    required this.date,
    required this.isCompleted,
    required this.instruksi,
  });

  ActivityHistory copyWith({
    String? id,
    String? title,
    String? image,
    DateTime? date,
    bool? isCompleted,
  }) {
    return ActivityHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      instruksi: instruksi ?? this.instruksi,
    );
  }

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'],
      instruksi: json['instruksi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'instruksi': instruksi,
    };
  }
}
