import 'package:flutter/widgets.dart';

/// Utilities for inserting template tokens into text fields at the active cursor.
extension TextEditingControllerCursorX on TextEditingController {
  /// Inserts [token] at the current selection (or appends at the end) and notifies [onChanged].
  void insertAtCursor(String token, {ValueChanged<String>? onChanged}) {
    final currentText = text;
    final currentSelection = selection;

    if (currentSelection.isValid && currentSelection.start >= 0) {
      text = currentText.replaceRange(
        currentSelection.start,
        currentSelection.end,
        token,
      );
      selection = TextSelection.collapsed(
        offset: currentSelection.start + token.length,
      );
    } else {
      text = currentText + token;
    }

    onChanged?.call(text);
  }
}