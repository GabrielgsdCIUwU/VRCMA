import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

extension VrcTagCategoryUI on VrcTagCategory {
  Widget getIcon(BuildContext context, {double size = 24}) {
    IconData icon;
    Color color;

    switch (this) {
      case VrcTagCategory.admin:
        icon = Icons.admin_panel_settings;
        color = context.colorScheme.error;
        break;
      case VrcTagCategory.system:
        icon = Icons.settings_system_daydream;
        color = context.colorScheme.primary;
        break;
      case VrcTagCategory.trust:
        icon = Icons.shield;
        color = context.vrcColors.request;
        break;
      case VrcTagCategory.language:
        icon = Icons.language;
        color = context.vrcColors.success;
        break;
    }
    return Icon(icon, color: color, size: 24);
  }
}