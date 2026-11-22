import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

enum UnsavedChangesAction {
  discard,
  save,
}

abstract final class AdaptiveDialogs {
  /// Prompts the user when attempting to exit with unsaved changes.
  static Future<UnsavedChangesAction?> showUnsavedChangesDialog(BuildContext context) async {
    return await showDialog<UnsavedChangesAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.dialogUnsavedTitle),
        content: Text(ctx.l10n.dialogUnsavedContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, UnsavedChangesAction.discard),
            child: Text(ctx.l10n.btnDiscard, style: TextStyle(color: ctx.colorScheme.error)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, UnsavedChangesAction.save),
            child: Text(ctx.l10n.btnSaveChanges),
          ),
        ],
      ),
    );
  }

  /// Prompts the user with a standard confirmation dialog before destructive actions.
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ctx.colorScheme.error),
            child: Text(ctx.l10n.btnDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}