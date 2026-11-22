import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

/// Standardized AppBar save button shared across full-screen configuration editors.
class EditorSaveButton extends StatelessWidget {
  final bool canSave;
  final VoidCallback onPressed;

  const EditorSaveButton({
    super.key,
    required this.canSave,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilledButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: Text(context.l10n.btnSave),
        style: FilledButton.styleFrom(
          backgroundColor: canSave ? context.vrcColors.success : null,
        ),
        onPressed: canSave ? onPressed : null,
      ),
    );
  }
}