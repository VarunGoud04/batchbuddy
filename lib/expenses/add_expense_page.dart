import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/vts_footer.dart';

class AddExpensePage extends StatefulWidget {
  final String groupId;
  const AddExpensePage({super.key, required this.groupId});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    final desc = _descController.text.trim();

    if (amount == null || amount <= 0 || desc.isEmpty) {
      setState(() => _error = 'Enter valid amount and description');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 🔹 Fetch group members (REQUIRED)
      final groupSnap = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final members =
          List<String>.from(groupSnap.data()?['members'] ?? []);

      if (members.isEmpty) {
        throw Exception('Group has no members');
      }

      await FirebaseFirestore.instance.collection('expenses').add({
        'groupId': widget.groupId,
        'amount': amount,
        'description': desc,
        'paidBy': uid,
        'members': members, // 🔥 REQUIRED for rules & balance
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to add expense');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addExpense,
                      child: const Text('Add Expense'),
                    ),
                  ),
            const SizedBox(height: 40),
            const VTSFooter(),
          ],
        ),
      ),
    );
  }
}
