enum DiaryEntryType { meal, activity }

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.notes,
    required this.recordedAt,
    this.carbs,
    this.durationMinutes,
    this.intensity,
  });

  final String id;
  final DiaryEntryType type;
  final String title;
  final String notes;
  final DateTime recordedAt;
  final double? carbs;
  final int? durationMinutes;
  final String? intensity; // e.g., 'Low', 'Medium', 'High'

  String get typeLabel => switch (type) {
        DiaryEntryType.meal => 'Meal',
        DiaryEntryType.activity => 'Activity',
      };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'notes': notes,
      'recordedAt': recordedAt.toIso8601String(),
      'carbs': carbs,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as String,
      type: DiaryEntryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DiaryEntryType.meal,
      ),
      title: map['title'] as String,
      notes: map['notes'] as String,
      recordedAt: DateTime.parse(map['recordedAt'] as String),
      carbs: map['carbs'] as double?,
      durationMinutes: map['durationMinutes'] as int?,
      intensity: map['intensity'] as String?,
    );
  }
}
