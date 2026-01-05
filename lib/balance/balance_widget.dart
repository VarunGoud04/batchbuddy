import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalanceWidget extends StatelessWidget {
  final String groupId;
  const BalanceWidget({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .snapshots(),
      builder: (context, expenseSnap) {
        if (!expenseSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('settlements')
              .where('groupId', isEqualTo: groupId)
              .snapshots(),
          builder: (context, settleSnap) {
            if (!settleSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            double youOwe = 0;
            double youReceive = 0;

            /// 🔹 PROCESS EXPENSES
            for (var doc in expenseSnap.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;

              final double amount =
                  (data['amount'] as num?)?.toDouble() ?? 0;

              final String paidBy = data['paidBy'] ?? '';

              final List<String> members =
                  List<String>.from(data['members'] ?? []);

              if (members.isEmpty) continue;

              final double share = amount / members.length;

              if (paidBy == uid) {
                // Others owe you
                youReceive += share * (members.length - 1);
              } else if (members.contains(uid)) {
                // You owe someone
                youOwe += share;
              }
            }

            /// 🔹 APPLY SETTLEMENTS (MARK AS PAID)
            for (var doc in settleSnap.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final double amt =
                  (data['amount'] as num?)?.toDouble() ?? 0;

              final String from = data['from'] ?? '';
              final String to = data['to'] ?? '';

              if (from == uid) youOwe -= amt;
              if (to == uid) youReceive -= amt;
            }

            youOwe = youOwe < 0 ? 0 : youOwe;
            youReceive = youReceive < 0 ? 0 : youReceive;

            final double net = youReceive - youOwe;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Balance',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    _row('You will receive', youReceive, Colors.green),
                    const SizedBox(height: 6),
                    _row('You owe', youOwe, Colors.red),
                    const Divider(height: 24),

                    _row(
                      'Net balance',
                      net.abs(),
                      net >= 0 ? Colors.green : Colors.red,
                      suffix: net >= 0 ? ' (receive)' : ' (pay)',
                      bold: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _row(
    String label,
    double value,
    Color color, {
    bool bold = false,
    String suffix = '',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            )),
        Text(
          '₹${value.toStringAsFixed(2)}$suffix',
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
