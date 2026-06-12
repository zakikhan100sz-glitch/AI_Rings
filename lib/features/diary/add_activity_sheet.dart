import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/diary_entry.dart';
import 'diary_provider.dart';

class AddActivitySheet extends ConsumerStatefulWidget {
  const AddActivitySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActivitySheet(),
    );
  }

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  final _activities = ['Walking', 'Running', 'Cycling', 'Swimming', 'Yoga', 'Strength Training', 'Other'];
  String _selectedActivity = 'Walking';
  TimeOfDay _time = TimeOfDay.now();
  Duration _duration = const Duration(minutes: 30);
  String _intensity = 'Medium';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final now = DateTime.now();
    final recordedAt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);

    final entry = DiaryEntry(
      id: 'activity-${DateTime.now().millisecondsSinceEpoch}',
      type: DiaryEntryType.activity,
      title: _selectedActivity,
      notes: _notesController.text.trim(),
      recordedAt: recordedAt,
      durationMinutes: _duration.inMinutes,
      intensity: _intensity,
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
                'Log Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedActivity,
            dropdownColor: const Color(0xFF21262D),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Activity Type',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: _activities
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedActivity = val);
            },
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
          const Text('Duration', style: TextStyle(color: Colors.white)),
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: _duration,
                onTimerDurationChanged: (val) {
                  setState(() => _duration = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Intensity', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Low', label: Text('Low')),
              ButtonSegment(value: 'Medium', label: Text('Medium')),
              ButtonSegment(value: 'High', label: Text('High')),
            ],
            selected: {_intensity},
            onSelectionChanged: (s) => setState(() => _intensity = s.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF2E6BD6);
                }
                return const Color(0xFF0D1117);
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
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
            child: const Text('Save Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
