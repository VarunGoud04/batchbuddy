import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNameText extends StatelessWidget {
  final String uid;
  final TextStyle? style;

  const UserNameText({
    super.key,
    required this.uid,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('User');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        return Text(
          data?['fullName'] ?? 'User',
          style: style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
