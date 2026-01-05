import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateResponsibilityPage extends StatefulWidget {
  final String groupId;
  const CreateResponsibilityPage({super.key, required this.groupId});

  @override
  State<CreateResponsibilityPage> createState() =>
      _CreateResponsibilityPageState();
}

class _CreateResponsibilityPageState
    extends State<CreateResponsibilityPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _assignedTo = TextEditingController();
  bool _loading = false;

  Future<void> _create() async {
    if (_title.text.isEmpty || _assignedTo.text.isEmpty) return;

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('responsibilities')
        .add({
      'groupId': widget.groupId,
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'assignedTo': _assignedTo.text.trim(),
      'assignedBy': uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Responsibility')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assignedTo,
              decoration: const InputDecoration(
                labelText: 'Assign to (User UID)',
              ),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _create,
                    child: const Text('Assign'),
                  ),
          ],
        ),
      ),
    );
  }
}
