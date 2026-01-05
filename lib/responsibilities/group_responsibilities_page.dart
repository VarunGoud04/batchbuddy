import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupResponsibilitiesPage extends StatelessWidget {
  final String groupId;
  final bool isAdmin;

  const GroupResponsibilitiesPage({
    super.key,
    required this.groupId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Responsibilities')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('responsibilities')
            .where('groupId', isEqualTo: groupId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView(
            children: snap.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(d['title']),
                subtitle: Text(
                  'Status: ${d['status']}',
                ),
                trailing: isAdmin
                    ? const Icon(Icons.admin_panel_settings)
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
