import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/diary_entry.dart';

class DiaryDatabase {
  static const _key = 'diary_entries';

  Future<List<DiaryEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];

    final List<DiaryEntry> entries = data
        .map((e) => DiaryEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return entries;
  }

  Future<void> addEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    
    // Replace if exists
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    
    entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final data = entries.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    
    final data = entries.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, data);
  }
}

final diaryDatabaseProvider = Provider<DiaryDatabase>((ref) {
  return DiaryDatabase();
});

final diaryEntriesProvider = AsyncNotifierProvider<DiaryNotifier, List<DiaryEntry>>(DiaryNotifier.new);

class DiaryNotifier extends AsyncNotifier<List<DiaryEntry>> {
  @override
  FutureOr<List<DiaryEntry>> build() async {
    return _fetchEntries();
  }

  Future<List<DiaryEntry>> _fetchEntries() async {
    final db = ref.watch(diaryDatabaseProvider);
    return await db.getEntries();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(diaryDatabaseProvider);
      await db.addEntry(entry);
      return _fetchEntries();
    });
  }

  Future<void> removeEntry(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(diaryDatabaseProvider);
      await db.deleteEntry(id);
      return _fetchEntries();
    });
  }
}
