import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../group/create_group_page.dart';
import '../group/join_group_page.dart';

import '../expenses/add_expense_page.dart';
import '../expenses/expense_list_page.dart';
import '../balance/balance_widget.dart';

import '../responsibilities/assign_responsibility_page.dart';
import '../responsibilities/group_responsibilities_page.dart';
import '../responsibilities/my_responsibilities_page.dart';

import '../core/animated_route.dart';
import '../core/vts_footer.dart';
import '../status/app_status_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _welcomeShown = false;

  /// 🔔 Show welcome once
  void _showWelcomeDialog(BuildContext context) {
    if (_welcomeShown) return;
    _welcomeShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Welcome to BatchBuddy 👋'),
          content: const Text(
            'You are using Version 1 (Early Access).\n\n'
            'Some features are still under development. '
            'Version 2 is coming soon with more improvements.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    });
  }

  /// 🔙 Back → Exit
  Future<void> _handleBack(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit BatchBuddy?'),
        content: const Text('Do you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (exit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) await _handleBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BatchBuddy'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (_) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),

        /// 🔥 USER DATA
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snap.data!.data() as Map<String, dynamic>?;
            final String? groupId = data?['groupId'];

            if (groupId == null) {
              return _noGroupView(context);
            }

            _showWelcomeDialog(context);

            return _groupDashboard(context, uid, groupId);
          },
        ),
      ),
    );
  }

  /// 🚫 No group view
  Widget _noGroupView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You are not part of any group yet'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                FadeSlideRoute(page: const CreateGroupPage()),
              );
            },
            child: const Text('Create Group'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                FadeSlideRoute(page: const JoinGroupPage()),
              );
            },
            child: const Text('Join Group'),
          ),
          const SizedBox(height: 40),
          const VTSFooter(),
        ],
      ),
    );
  }

  /// 👥 Group dashboard
  Widget _groupDashboard(
      BuildContext context, String uid, String groupId) {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email ?? 'User';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final group = snap.data!.data() as Map<String, dynamic>;
        final adminId = group['adminId'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 👤 PROFILE
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(email[0].toUpperCase()),
                  ),
                  title: Text(email),
                  subtitle: Text('Group ID: $groupId'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: groupId),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group ID copied')),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 💰 BALANCE
              BalanceWidget(groupId: groupId),

              const SizedBox(height: 24),

              /// 💸 EXPENSES
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
                onPressed: () {
                  Navigator.push(
                    context,
                    FadeSlideRoute(
                      page: AddExpensePage(groupId: groupId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Expenses'),
                onPressed: () {
                  Navigator.push(
                    context,
                    FadeSlideRoute(
                      page: ExpenseListPage(groupId: groupId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// 📋 RESPONSIBILITIES
              OutlinedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text('Group Responsibilities'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupResponsibilitiesPage(
                        groupId: groupId,
                        isAdmin: uid == adminId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.assignment_ind),
                label: const Text('My Responsibilities'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyResponsibilitiesPage(groupId: groupId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// 👑 ADMIN ONLY
              if (uid == adminId)
                ElevatedButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Assign Responsibility'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AssignResponsibilityPage(groupId: groupId),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              /// ℹ️ APP STATUS
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('App Status'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppStatusPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
              const VTSFooter(),
            ],
          ),
        );
      },
    );
  }
}
