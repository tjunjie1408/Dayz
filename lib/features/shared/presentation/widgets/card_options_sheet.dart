import 'package:flutter/material.dart';

import 'package:dayz/core/theme/app_theme.dart';

/// A reusable bottom sheet with "Soft & Airy" rounded aesthetics.
/// Provides "Edit" and "Delete" actions for cards.
class CardOptionsSheet extends StatelessWidget {
  const CardOptionsSheet({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  /// Called when the "Edit" tile is tapped.
  final VoidCallback onEdit;

  /// Called when the "Delete" tile is tapped.
  final VoidCallback onDelete;

  /// Helper to easily show this sheet.
  static void show({
    required BuildContext context,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CanvasColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (_) => CardOptionsSheet(
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pill indicator.
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: CanvasColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Edit Option.
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: CanvasColors.textPrimary,
              ),
              title: Text(
                'Edit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: CanvasColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            
            // Delete Option.
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: RomanticColors.roseDark,
              ),
              title: Text(
                'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: RomanticColors.roseDark,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
