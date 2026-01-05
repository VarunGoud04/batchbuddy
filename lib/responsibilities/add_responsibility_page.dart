import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddResponsibilityPage extends StatefulWidget {
  final String groupId;
  const AddResponsibilityPage({super.key, required this.groupId});

  @override
  State<AddResponsibilityPage> createState() =>
      _AddResponsibilityPageState();
}

class _AddResponsibilityPageState extends State<AddResponsibilityPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _assignedTo;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Responsibility')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration:
                  const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration:
                  const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),

            /// SELECT USER
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('groupId', isEqualTo: widget.groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: _assignedTo,
                  hint: const Text('Assign to'),
                  items: snapshot.data!.docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['fullName'] ?? 'User'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _assignedTo = val);
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text('Assign'),
                      onPressed: () async {
                        if (_titleController.text.trim().isEmpty ||
                            _assignedTo == null) return;

                        setState(() => _loading = true);

                        await FirebaseFirestore.instance
                            .collection('responsibilities')
                            .add({
                          'groupId': widget.groupId,
                          'title':
                              _titleController.text.trim(),
                          'description':
                              _descController.text.trim(),
                          'assignedTo': _assignedTo,
                          'assignedBy': uid,
                          'status': 'pending',
                          'createdAt':
                              FieldValue.serverTimestamp(),
                          'completedAt': null,
                        });

                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
