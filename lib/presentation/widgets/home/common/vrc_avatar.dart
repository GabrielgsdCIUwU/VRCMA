import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

class VrcAvatar extends ConsumerWidget {
  final String? imageUrl;
  final String displayName;
  final double radius;
  final VoidCallback? onTap;
  
  const VrcAvatar({
    super.key,
    required this.imageUrl,
    required this.displayName,
    this.radius = 20,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }
    
    final resolvedUrlAsync = ref.watch(vrcResolvedImageProvider(imageUrl!));
    
    final cacheSize = (radius * 3 * MediaQuery.devicePixelRatioOf(context)).toInt();
    
    return GestureDetector(
      onTap: onTap,
      child: resolvedUrlAsync.when(
        data: (finalUrl) => CircleAvatar(
          radius: radius,
          backgroundColor: context.colorScheme.surfaceContainerHighest,
          backgroundImage: ResizeImage(
            NetworkImage(finalUrl),
            width: cacheSize,
            height: cacheSize,
          ),
          onBackgroundImageError: (_, _) => _buildPlaceholder(context),
        ),
        loading: () => SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (err, _) => _buildPlaceholder(context, error: err.toString()),
      ),
    );
  }
  
  Widget _buildPlaceholder(BuildContext context, {String? error}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.colorScheme.primaryContainer,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}