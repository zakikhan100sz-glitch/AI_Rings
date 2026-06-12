enum LinkStatus { pending, active }

class ClinicSearchResult {
  const ClinicSearchResult({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
  });

  final String id;
  final String name;
  final String specialty;
  final String city;

  factory ClinicSearchResult.fromJson(Map<String, dynamic> json) {
    return ClinicSearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      city: json['city'] as String,
    );
  }
}

class LinkedDoctor {
  const LinkedDoctor({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.status,
  });

  final String doctorId;
  final String name;
  final String specialty;
  final LinkStatus status;

  LinkedDoctor copyWith({LinkStatus? status}) {
    return LinkedDoctor(
      doctorId: doctorId,
      name: name,
      specialty: specialty,
      status: status ?? this.status,
    );
  }
}
