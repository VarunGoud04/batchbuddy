import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyResponsibilitiesPage extends StatelessWidget {
  final String groupId;

  const MyResponsibilitiesPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Responsibilities')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('responsibilities')
            .where('groupId', isEqualTo: groupId)
            .where('assignedTo', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks assigned to you'));
          }

          return ListView(
            children: snap.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(d['title']),
                  subtitle: Text(d['description'] ?? ''),
                  trailing: d['status'] == 'completed'
                      ? const Icon(Icons.check, color: Colors.green)
                      : ElevatedButton(
                          child: const Text('Mark Done'),
                          onPressed: () {
                            doc.reference.update({
                              'status': 'completed',
                              'completedAt':
                                  FieldValue.serverTimestamp(),
                            });
                          },
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
