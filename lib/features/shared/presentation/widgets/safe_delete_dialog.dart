import 'package:flutter/material.dart';

import 'package:dayz/core/theme/app_theme.dart';

/// A safe delete confirmation dialog with large rounded corners,
/// following the "Soft & Airy" aesthetic.
class SafeDeleteDialog extends StatelessWidget {
  const SafeDeleteDialog({super.key});

  /// Helper to easily show this dialog and await the bool result.
  /// Returns `true` if confirmed, `false` otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const SafeDeleteDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: CanvasColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      title: Text(
        'Are you sure?',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontSize: 20,
        ),
      ),
      content: Text(
        'This action cannot be undone.',
        style: theme.textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, top: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: CanvasColors.textSecondary,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: RomanticColors.roseDark,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
