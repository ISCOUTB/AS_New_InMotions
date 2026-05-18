class MoodRecord {
  const MoodRecord({
    required this.id,
    required this.userId,
    required this.mood,
    required this.level,
    required this.tags,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String mood;
  final int level;
  final List<String> tags;
  final String note;
  final DateTime createdAt;

  MoodRecord copyWith({
    String? id,
    String? userId,
    String? mood,
    int? level,
    List<String>? tags,
    String? note,
    DateTime? createdAt,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      level: level ?? this.level,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood,
      'level': level,
      'tags': tags,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
