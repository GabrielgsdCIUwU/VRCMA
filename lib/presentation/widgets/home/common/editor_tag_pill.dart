import 'package:flutter/material.dart';

/// Compact semantic badge pill used in previews, status indicators, and cards.
class EditorTagPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool showBorder;

  const EditorTagPill({
    super.key,
    required this.label,
    required this.color,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: showBorder
            ? Border.all(color: color.withValues(alpha: 0.35))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}