import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettlementHistoryPage extends StatelessWidget {
  final String groupId;

  const SettlementHistoryPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settlements')
            .where('groupId', isEqualTo: groupId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No payments yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              final from = data['from'];
              final to = data['to'];
              final amount = (data['amount'] ?? 0).toDouble();

              final isMe = from == uid;

              return ListTile(
                leading: Icon(
                  isMe ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isMe ? Colors.red : Colors.green,
                ),
                title: Text(
                  isMe
                      ? 'You paid ₹${amount.toStringAsFixed(2)}'
                      : 'You received ₹${amount.toStringAsFixed(2)}',
                ),
                subtitle: Text(isMe ? 'Payment sent' : 'Payment received'),
              );
            },
          );
        },
      ),
    );
  }
}
