import 'package:flutter/material.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

/// Standardized uppercase section header with an optional trailing action widget.
class EditorSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Color? color;

  const EditorSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: color ?? context.colorScheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}