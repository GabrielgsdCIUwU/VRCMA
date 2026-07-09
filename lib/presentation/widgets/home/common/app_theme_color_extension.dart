import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/theme/app_theme_color.dart';

extension AppThemeColorMaterial on AppThemeColor {
  Color get getMaterialColor {
    switch (this) {
      case AppThemeColor.deepPurple:
        return Colors.deepPurple;
        
      case AppThemeColor.blue:
        return Colors.blue;
      
      case AppThemeColor.teal:
        return Colors.teal;
      
      case AppThemeColor.green:
        return Colors.green;
      
      case AppThemeColor.orange:
        return Colors.deepOrange;
      
      case AppThemeColor.rose:
        return Colors.pink;

    }
  }

  String getLozalizedName(BuildContext context) {
    switch (this) {
      case AppThemeColor.deepPurple:
        return context.l10n.colorDeepPurple;
      
      case AppThemeColor.blue:
        return context.l10n.colorBlue;
      
      case AppThemeColor.teal:
        return context.l10n.colorTeal;
      
      case AppThemeColor.green:
        return context.l10n.colorGreen;
      
      case AppThemeColor.orange:
        return context.l10n.colorOrange;
      
      case AppThemeColor.rose:
        return context.l10n.colorRose;
    }
  }
}