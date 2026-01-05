import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponsibilityListPage extends StatelessWidget {
  final String groupId;
  const ResponsibilityListPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsibilities')),
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
            return const Center(child: Text('No responsibilities'));
          }

          return ListView(
            children: snap.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final isMine = d['assignedTo'] == uid;
              final done = d['status'] == 'completed';

              return Card(
                child: ListTile(
                  title: Text(d['title']),
                  subtitle: Text(d['description'] ?? ''),
                  trailing: isMine && !done
                      ? ElevatedButton(
                          onPressed: () {
                            doc.reference.update({
                              'status': 'completed',
                              'completedAt': FieldValue.serverTimestamp(),
                            });
                          },
                          child: const Text('Mark Done'),
                        )
                      : done
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
