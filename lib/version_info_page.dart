import 'package:flutter/material.dart';

class VersionInfoPage extends StatelessWidget {
  const VersionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BatchBuddy Updates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Current Version',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text('BatchBuddy v1.0'),
            Text(
              'Expense tracking for shared living',
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 12),

            Text(
              'Version 2.0 – Coming Soon 🚀',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            ListTile(
              leading: Icon(Icons.task_alt),
              title: Text('Responsibilities'),
              subtitle: Text('Assign and track group tasks'),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Real Member Names'),
              subtitle: Text('No more confusing user IDs'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Clear Balances'),
              subtitle: Text('Who owes, who receives'),
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Admin Controls'),
              subtitle: Text('Manage tasks and assignments'),
            ),

            SizedBox(height: 16),
            Text(
              'Launch date will be announced soon.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
