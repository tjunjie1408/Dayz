import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayz/core/theme/app_theme.dart';
import 'package:dayz/features/anniversary/presentation/providers/anniversary_provider.dart';

/// A bottom sheet that allows users to create a new Anniversary.
class AddAnniversarySheet extends ConsumerStatefulWidget {
  const AddAnniversarySheet({Key? key}) : super(key: key);

  /// Helper to easily show this bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAnniversarySheet(),
    );
  }

  @override
  ConsumerState<AddAnniversarySheet> createState() =>
      _AddAnniversarySheetState();
}

class _AddAnniversarySheetState extends ConsumerState<AddAnniversarySheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RomanticColors.roseDark,
              onPrimary: CanvasColors.surface,
              surface: CanvasColors.surface,
              onSurface: CanvasColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    // Basic validation: Title and Date are required
    if (title.isEmpty || _selectedDate == null) return;

    ref.read(anniversaryListProvider.notifier).add(
          title: title,
          startDate: _selectedDate!,
          note: note.isEmpty ? null : note,
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // The padding adds space for the keyboard
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: CanvasColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: CanvasColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'New Anniversary 💕',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: RomanticColors.roseDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., First Met, Our Anniversary',
                labelText: 'Title',
                labelStyle: TextStyle(
                    color: RomanticColors.roseDark.withValues(alpha: 0.8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: RomanticColors.peach.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: RomanticColors.roseDark, width: 2),
                ),
                filled: true,
                fillColor: RomanticColors.peach.withValues(alpha: 0.1),
              ),
              cursorColor: RomanticColors.roseDark,
            ),
            const SizedBox(height: 16),

            // Date Picker Row
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: RomanticColors.peach.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: RomanticColors.peach.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: RomanticColors.roseDark.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat.yMMMd().format(_selectedDate!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDate == null
                              ? CanvasColors.textMuted
                              : CanvasColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'A sweet memory...',
                labelText: 'Note (Optional)',
                labelStyle: TextStyle(
                    color: RomanticColors.roseDark.withValues(alpha: 0.8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: RomanticColors.peach.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: RomanticColors.roseDark, width: 2),
                ),
                filled: true,
                fillColor: RomanticColors.peach.withValues(alpha: 0.1),
              ),
              cursorColor: RomanticColors.roseDark,
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Dimiss keyboard before saving
                FocusScope.of(context).unfocus();
                _save();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RomanticColors.roseDark,
                foregroundColor: CanvasColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
