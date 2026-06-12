import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/diary_entry.dart';
import 'diary_provider.dart';

class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMealSheet(),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  double _carbs = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final recordedAt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);

    final entry = DiaryEntry(
      id: 'meal-${DateTime.now().millisecondsSinceEpoch}',
      type: DiaryEntryType.meal,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      recordedAt: recordedAt,
      carbs: _carbs,
    );

    ref.read(diaryEntriesProvider.notifier).addEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Meal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Food Name',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Time', style: TextStyle(color: Colors.white)),
            trailing: Text(
              _time.format(context),
              style: const TextStyle(color: Color(0xFF2E6BD6), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final selected = await showTimePicker(context: context, initialTime: _time);
              if (selected != null) {
                setState(() => _time = selected);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Carbs: ${_carbs.toInt()}g', style: const TextStyle(color: Colors.white)),
          Slider(
            value: _carbs,
            min: 0,
            max: 200,
            divisions: 200,
            activeColor: const Color(0xFF2E6BD6),
            onChanged: (val) => setState(() => _carbs = val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6BD6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
