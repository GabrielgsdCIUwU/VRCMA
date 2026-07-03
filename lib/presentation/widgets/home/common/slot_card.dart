import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class SlotCard  extends StatelessWidget {
  final int index;
  final CustomMessage? message;
  
  const SlotCard({super.key, required this.index, this.message});
  
  @override
  Widget build(BuildContext context) {
    final bool isEmpty = message == null;
    
   return Card(
     elevation: 0,
     color: isEmpty ? Colors.transparent : context.colorScheme.primary.withValues(alpha: 0.05),
     shape: RoundedRectangleBorder(
       side: BorderSide(color: isEmpty ? context.colorScheme.outlineVariant : context.colorScheme.primary.withValues(alpha: 0.3)),
       borderRadius: BorderRadiusGeometry.circular(4),
     ),
     child: Padding(
       padding: const EdgeInsets.all(8),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             context.l10n.messageSlotLabel(index).toUpperCase(),
             style: TextStyle(fontSize: 9, color: isEmpty ? context.colorScheme.onSurfaceVariant : context.colorScheme.primary, fontWeight: FontWeight.bold),
           ),
           const SizedBox(height: 4),
           Text(
             isEmpty ? "---" : message!.content,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
             style: TextStyle(fontSize: 11, color: isEmpty
                 ? context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                 : context.colorScheme.onSurface),
           ),
         ],
       ),
     ),
   );
  }
}