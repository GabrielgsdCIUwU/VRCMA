import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogsPanel extends StatelessWidget {
  const LogsPanel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text("AUTOMATION LOGS", style: Theme.of(context).textTheme.labelSmall),
        ),
        Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                title: Text("Accepted Invite from User_$index", style: TextStyle(fontSize: 13)),
                subtitle: Text("Applied Rule: 'Auto-accept friends'", style: const TextStyle(fontSize: 11),),
                trailing: Text("12:4$index", style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ),
            ) 
        )
      ],
    );
  }
}