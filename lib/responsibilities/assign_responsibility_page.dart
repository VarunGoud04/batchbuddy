import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignResponsibilityPage extends StatefulWidget {
  final String groupId;
  const AssignResponsibilityPage({super.key, required this.groupId});

  @override
  State<AssignResponsibilityPage> createState() =>
      _AssignResponsibilityPageState();
}

class _AssignResponsibilityPageState
    extends State<AssignResponsibilityPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedUserId;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final adminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Responsibility')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('groupId', isEqualTo: widget.groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration:
                      const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _descController,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),

                /// 👤 USER NAME DROPDOWN
                DropdownButtonFormField<String>(
                  value: _selectedUserId,
                  hint: const Text('Assign to'),
                  items: users.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unnamed';
                    return DropdownMenuItem(
                      value: doc.id, // UID stored
                      child: Text(name), // Name shown
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedUserId = val);
                  },
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_selectedUserId == null ||
                              _titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Fill all required fields'),
                              ),
                            );
                            return;
                          }

                          setState(() => _loading = true);

                          await FirebaseFirestore.instance
                              .collection('responsibilities')
                              .add({
                            'groupId': widget.groupId,
                            'title': _titleController.text.trim(),
                            'description':
                                _descController.text.trim(),
                            'assignedTo': _selectedUserId,
                            'assignedBy': adminId,
                            'status': 'pending',
                            'createdAt':
                                FieldValue.serverTimestamp(),
                            'completedAt': null,
                          });

                          if (mounted) Navigator.pop(context);
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Assign Task'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
