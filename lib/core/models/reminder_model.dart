class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.hour,
    required this.minute,
    required this.days,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final int hour;
  final int minute;
  final List<int> days;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderModel copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    int? hour,
    int? minute,
    List<int>? days,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeLabel {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
  }

  String get daysLabel {
    if (days.length == 7) return 'Todos los días';
    if (_sameDays(days, const [1, 2, 3, 4, 5])) return 'Lun - Vie';
    if (_sameDays(days, const [1, 3, 5])) return 'Lun, Mié, Vie';
    if (_sameDays(days, const [7, 1, 2, 3, 4])) return 'Dom - Jue';

    const names = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };

    final orderedDays = [...days]..sort();
    return orderedDays.map((day) => names[day] ?? '').where((day) => day.isNotEmpty).join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'hour': hour,
      'minute': minute,
      'days': days,
      'enabled': enabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      days: List<int>.from(json['days'] as List),
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static bool _sameDays(List<int> first, List<int> second) {
    final orderedFirst = [...first]..sort();
    final orderedSecond = [...second]..sort();
    if (orderedFirst.length != orderedSecond.length) return false;
    for (var i = 0; i < orderedFirst.length; i++) {
      if (orderedFirst[i] != orderedSecond[i]) return false;
    }
    return true;
  }
}
