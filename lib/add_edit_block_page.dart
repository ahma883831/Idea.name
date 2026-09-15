import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'theme.dart';
import 'widgets/glow_button.dart';

class AddEditBlockPage extends StatefulWidget {
  final String date;
  final TimeBlock? existing;

  const AddEditBlockPage({super.key, required this.date, this.existing});

  @override
  State<AddEditBlockPage> createState() => _AddEditBlockPageState();
}

class _AddEditBlockPageState extends State<AddEditBlockPage> {
  final _titleController = TextEditingController();
  BlockCategory _category = BlockCategory.grammar;
  TimeOfDay _start = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _category = e.category;
      _start = TimeOfDay(hour: e.startMinutes ~/ 60, minute: e.startMinutes % 60);
      _end = TimeOfDay(hour: e.endMinutes ~/ 60, minute: e.endMinutes % 60);
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    if (_toMinutes(_end) <= _toMinutes(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('زمان پایان باید بعد از زمان شروع باشد')),
      );
      return;
    }

    final block = TimeBlock(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      category: _category,
      startMinutes: _toMinutes(_start),
      endMinutes: _toMinutes(_end),
      date: widget.date,
      completed: widget.existing?.completed ?? false,
    );
    Navigator.of(context).pop(block);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'بلوک جدید' : 'ویرایش بلوک'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'عنوان (مثلاً: درس گرامر A1)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('دسته‌بندی', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: BlockCategory.values.map((c) {
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: c.color.withOpacity(0.35),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: c.color),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text('شروع: ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text('پایان: ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GlowButton(
              label: 'ذخیره',
              color: _category.color,
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
