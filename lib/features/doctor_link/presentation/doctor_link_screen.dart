import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/doctor.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_view.dart';
import '../doctor_link_provider.dart';

class DoctorLinkScreen extends ConsumerStatefulWidget {
  const DoctorLinkScreen({super.key});

  @override
  ConsumerState<DoctorLinkScreen> createState() => _DoctorLinkScreenState();
}

class _DoctorLinkScreenState extends ConsumerState<DoctorLinkScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(doctorSearchQueryProvider.notifier).state = query;
    });
  }

  void _sendRequest(ClinicSearchResult clinic) async {
    try {
      await ref.read(linkedDoctorsProvider.notifier).sendRequest(
            clinic.id,
            clinic.name,
            clinic.specialty,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(doctorSearchProvider);
    final linkedDoctorsAsync = ref.watch(linkedDoctorsProvider);
    final searchQuery = ref.watch(doctorSearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text('Link Doctor / Clinic', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or 6-digit code',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF161B22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            Expanded(
              child: searchResultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                data: (results) {
                  if (results.isEmpty) {
                    return const Center(
                      child: Text('No clinics found.', style: TextStyle(color: Colors.white54)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final clinic = results[index];
                      return Card(
                        color: const Color(0xFF161B22),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(clinic.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('${clinic.specialty} • ${clinic.city}', style: const TextStyle(color: Colors.white54)),
                          trailing: ElevatedButton(
                            onPressed: () => _sendRequest(clinic),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E6BD6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Send Request'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'My Doctors',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: linkedDoctorsAsync.when(
                      loading: () => const LoadingView(message: 'Loading your doctors...'),
                      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                      data: (doctors) {
                        if (doctors.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Link your doctor to share health data',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white54, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            final isPending = doc.status == LinkStatus.pending;

                            return Dismissible(
                              key: ValueKey(doc.doctorId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: AppColors.risk,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                ref.read(linkedDoctorsProvider.notifier).unlink(doc.doctorId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Doctor unlinked')),
                                );
                              },
                              child: Card(
                                color: const Color(0xFF161B22),
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF21262D),
                                    child: Icon(Icons.local_hospital, color: Colors.white54),
                                  ),
                                  title: Text(doc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text(doc.specialty, style: const TextStyle(color: Colors.white54)),
                                  trailing: Chip(
                                    label: Text(
                                      isPending ? 'Pending' : 'Active',
                                      style: TextStyle(
                                        color: isPending ? Colors.black87 : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: isPending ? AppColors.warning : AppColors.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
