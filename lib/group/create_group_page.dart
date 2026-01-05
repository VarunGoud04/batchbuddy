import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  // 🔑 INVITE CODE = GROUP ID
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a group name');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final groupId = _generateInviteCode();

    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      // ✅ Ensure no collision (very rare, but correct)
      final exists = await groupRef.get();
      if (exists.exists) {
        throw 'Group code collision. Try again.';
      }

      // ✅ CREATE GROUP WITH KNOWN ID
      await groupRef.set({
        'groupId': groupId,
        'name': name,
        'adminId': uid,
        'members': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ UPDATE USER → GROUP LINK
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'groupId': groupId,
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'An invite code will be generated and shared with members.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      onPressed: _createGroup,
                      child: const Text('Create Group'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
