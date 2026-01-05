import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberBalancePage extends StatelessWidget {
  final String groupId;

  const MemberBalancePage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Group Balances')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('groupId', isEqualTo: groupId)
            .snapshots(),
        builder: (context, expenseSnap) {
          if (!expenseSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, double> balances = {};

          for (var doc in expenseSnap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            final paidBy = d['paidBy'];
            final split = (d['splitAmount'] ?? 0).toDouble();
            final amount = (d['amount'] ?? 0).toDouble();

            balances.update(uid, (v) => v - split, ifAbsent: () => -split);
            balances.update(paidBy, (v) => v + amount, ifAbsent: () => amount);
          }

          balances.remove(uid);

          return ListView(
            children: balances.entries.map((e) {
              final isOwed = e.value > 0;

              return ListTile(
                leading: Icon(
                  isOwed ? Icons.call_received : Icons.call_made,
                  color: isOwed ? Colors.green : Colors.red,
                ),
                title: Text(
                  isOwed
                      ? 'User owes you ₹${e.value.toStringAsFixed(2)}'
                      : 'You owe user ₹${e.value.abs().toStringAsFixed(2)}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
