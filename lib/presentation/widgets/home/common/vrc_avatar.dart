import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return _buildPlaceholder();
    }
    
    final resolvedUrlAsync = ref.watch(vrcResolvedImageProvider(imageUrl!));
    
    return GestureDetector(
      onTap: onTap,
      child: resolvedUrlAsync.when(
        data: (finalUrl) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.black26,
          backgroundImage: NetworkImage(finalUrl),
          onBackgroundImageError: (_, _) => _buildPlaceholder(),
        ),
        loading: () => SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (err, _) => _buildPlaceholder(error: err.toString()),
      ),
    );
  }
  
  Widget _buildPlaceholder({String? error}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.deepPurple.shade700,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}