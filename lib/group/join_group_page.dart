import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _joinGroup() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter the invite code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(code);

      final groupSnap = await groupRef.get();

      if (!groupSnap.exists) {
        setState(() => _error = 'Group not found. Check the invite code.');
        return;
      }

      final data = groupSnap.data() as Map<String, dynamic>;
      final List members = data['members'] ?? [];

      if (members.contains(uid)) {
        setState(() => _error = 'You are already a member of this group.');
        return;
      }

      // ✅ ADD USER TO GROUP
      await groupRef.update({
        'members': FieldValue.arrayUnion([uid]),
      });

      // ✅ UPDATE USER DOCUMENT
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'groupId': code,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to join group. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'E.g. AB7K92QX',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 24),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _joinGroup,
                      child: const Text('Join Group'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
