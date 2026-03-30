import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/user_details_provider.dart';

class UserDetailsSheet extends ConsumerWidget {
  final VrcUser user;
  const UserDetailsSheet({super.key, required this.user});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedRolesAsync = ref.watch(userMetadataProvider(user.id));
    final allRolesAsync = ref.watch(allAvailableRolesProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          const Divider(),
          const Text("App Roles", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: allRolesAsync.when(
                data: (allRoles) => ListView.builder(
                  itemCount: allRoles.length,
                  itemBuilder: (context, index) {
                    final role = allRoles[index];
                    final isAssigned = assignedRolesAsync.value?.contains(role) ?? false;

                    return CheckboxListTile(
                      title: Text(role.name),
                      value: isAssigned,
                      onChanged: (val) {
                        ref.read(userMetadataProvider(user.id).notifier)
                            .toggleRole(role, val ?? false);
                      },
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, _) => const Text("Error loading roles")
            ),
          ),
          const SizedBox(height: 10),
          const Text("VRChat Tags (Read Only)", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            children: user.tags.map((t) => 
                Chip(label: Text(
                    t, 
                    style: const TextStyle(fontSize: 10))))
                .toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(VrcUser user) {
    return Row(
      children: [
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user.status)
          ],
        )
      ],
    );
  }
}