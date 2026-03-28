import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AutomationSettingsPanel extends StatelessWidget {
  const AutomationSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Active Profile"),
          subtitle: const Text("Default Filter"),
          trailing: Switch(value: true, onChanged: (v) {}),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              _buildRuleItem("Admins", Icons.security, Colors.orange),
              _buildRuleItem("VIP Friends", Icons.star, Colors.blue),
              _buildRuleItem("Blocked", Icons.block, Colors.red),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("New Rule")
          ),
        )
      ],
    );
  }

  Widget _buildRuleItem(String name, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}