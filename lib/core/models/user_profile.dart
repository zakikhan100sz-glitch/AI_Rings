import 'enums.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.diabetesStatus,
    this.medications = const [],
    this.chronicConditions = const [],
    this.linkedDoctor,
    this.linkedClinic,
  });

  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final DiabetesStatus diabetesStatus;
  final List<String> medications;
  final List<String> chronicConditions;
  final String? linkedDoctor;
  final String? linkedClinic;

  String get diabetesLabel => switch (diabetesStatus) {
        DiabetesStatus.none => 'No diabetes',
        DiabetesStatus.prediabetes => 'Prediabetes',
        DiabetesStatus.type1 => 'Type 1 diabetes',
        DiabetesStatus.type2 => 'Type 2 diabetes',
      };

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    DiabetesStatus? diabetesStatus,
    List<String>? medications,
    List<String>? chronicConditions,
    String? linkedDoctor,
    String? linkedClinic,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      diabetesStatus: diabetesStatus ?? this.diabetesStatus,
      medications: medications ?? this.medications,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      linkedDoctor: linkedDoctor ?? this.linkedDoctor,
      linkedClinic: linkedClinic ?? this.linkedClinic,
    );
  }
}
