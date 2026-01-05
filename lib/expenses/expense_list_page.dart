import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/vts_footer.dart';

class ExpenseListPage extends StatelessWidget {
  final String groupId;
  const ExpenseListPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('groupId', isEqualTo: groupId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No expenses yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    final String paidBy = data['paidBy'];
                    final double amount =
                        (data['amount'] as num).toDouble();

                    final List<String> members =
                        List<String>.from(data['members'] ?? []);

                    final double myShare =
                        members.isEmpty ? 0 : amount / members.length;

                    final bool isMe = paidBy == uid;
                    final bool iOwe = !isMe;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isMe ? Colors.green : Colors.orange,
                              child: Icon(
                                isMe
                                    ? Icons.person
                                    : Icons.payments_outlined,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              data['description'] ?? 'Expense',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe
                                      ? 'Paid by you'
                                      : 'Paid by another member',
                                  style:
                                      const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Your share: ₹${myShare.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          /// ✅ ACTION ROW (NO OVERFLOW)
                          if (iOwe)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                bottom: 8,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('settlements')
                                        .add({
                                      'groupId': groupId,
                                      'from': uid,
                                      'to': paidBy,
                                      'amount': myShare,
                                      'createdAt':
                                          FieldValue.serverTimestamp(),
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Payment marked successfully',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Mark as Paid'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: VTSFooter(),
          ),
        ],
      ),
    );
  }
}
