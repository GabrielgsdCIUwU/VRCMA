import 'package:flutter/material.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.lock_person, size: 80, color: context.colorScheme.primary),
        const SizedBox(height: 32),
        const Text(
          'VRCMA',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}