import 'enums.dart';

class HealthAlert {
  const HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.cause,
    required this.recommendation,
    required this.level,
    required this.createdAt,
    this.isResolved = false,
  });

  final String id;
  final String title;
  final String message;
  final String cause;
  final String recommendation;
  final AlertLevel level;
  final DateTime createdAt;
  final bool isResolved;

  HealthAlert copyWith({bool? isResolved}) {
    return HealthAlert(
      id: id,
      title: title,
      message: message,
      cause: cause,
      recommendation: recommendation,
      level: level,
      createdAt: createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
