import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/models/doctor.dart';

const String _baseUrl = 'https://api.airings.ai';

final doctorSearchQueryProvider = StateProvider<String>((ref) => '');

final doctorSearchProvider = FutureProvider<List<ClinicSearchResult>>((ref) async {
  final query = ref.watch(doctorSearchQueryProvider);
  if (query.isEmpty) return [];

  try {
    final uri = Uri.parse('$_baseUrl/api/v1/clinics/search?q=$query');
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ClinicSearchResult.fromJson(e)).toList();
    }
    // Fallback on error response
    throw Exception('API error');
  } catch (e) {
    // Fallback mock data when API is unreachable or fails
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      const ClinicSearchResult(
        id: 'clinic-1',
        name: 'Wellness Clinic Almaty',
        specialty: 'Endocrinology',
        city: 'Almaty',
      ),
      const ClinicSearchResult(
        id: 'clinic-2',
        name: 'Dr. Sarah Chen, MD',
        specialty: 'Primary Care',
        city: 'Almaty',
      ),
      const ClinicSearchResult(
        id: 'clinic-3',
        name: 'City Health Center',
        specialty: 'General Practice',
        city: 'Astana',
      ),
    ].where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
});

class LinkedDoctorsNotifier extends AsyncNotifier<List<LinkedDoctor>> {
  @override
  Future<List<LinkedDoctor>> build() async {
    // Return initial mock state
    return [
      const LinkedDoctor(
        doctorId: 'clinic-1',
        name: 'Wellness Clinic Almaty',
        specialty: 'Endocrinology',
        status: LinkStatus.active,
      ),
    ];
  }

  Future<void> sendRequest(String doctorId, String name, String specialty) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final uri = Uri.parse('$_baseUrl/api/v1/patients/link-request');
        final response = await http.post(
          uri,
          body: jsonEncode({'doctorId': doctorId}),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('API error');
        }
      } catch (e) {
        // Fallback mock success
        await Future.delayed(const Duration(seconds: 1));
      }

      final current = state.value ?? [];
      if (current.any((d) => d.doctorId == doctorId)) {
        return current; // already linked/pending
      }
      return [
        ...current,
        LinkedDoctor(
          doctorId: doctorId,
          name: name,
          specialty: specialty,
          status: LinkStatus.pending,
        ),
      ];
    });
  }

  Future<void> unlink(String doctorId) async {
    // Mock the unlink API
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      final current = state.value ?? [];
      return current.where((d) => d.doctorId != doctorId).toList();
    });
  }
}

final linkedDoctorsProvider =
    AsyncNotifierProvider<LinkedDoctorsNotifier, List<LinkedDoctor>>(
        LinkedDoctorsNotifier.new);
