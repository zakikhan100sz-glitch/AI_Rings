class ChartAnnotation {
  const ChartAnnotation({
    required this.timestamp,
    required this.label,
    required this.type,
  });

  final DateTime timestamp;
  final String label;
  final ChartAnnotationType type;
}

enum ChartAnnotationType {
  alert,
  meal,
  activity,
}

extension ChartAnnotationTypeX on ChartAnnotationType {
  String get label => switch (this) {
        ChartAnnotationType.alert => 'Alert',
        ChartAnnotationType.meal => 'Meal',
        ChartAnnotationType.activity => 'Activity',
      };
}
