import 'package:flutter/material.dart';

/// Wraps children to support platform-specific context triggers.
/// Desktop users trigger through secondary tap (right-click),
/// while mobile users rely on taps or lacalized menu buttons.
class AdaptiveContextMenuWrapper<T> extends StatelessWidget {
  final Widget child;
  final List<PopupMenuEntry<T>> menuItems;
  final ValueChanged<T> onSelected;

  const AdaptiveContextMenuWrapper({
    super.key,
    required this.child,
    required this.menuItems,
    required this.onSelected,
  });

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: menuItems,
    ).then((value) {
      if (value != null) {
        onSelected(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }
}