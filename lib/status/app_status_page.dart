import 'package:flutter/material.dart';
import '../core/vts_footer.dart';

class AppStatusPage extends StatelessWidget {
  const AppStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Status'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔰 HEADER
            Row(
              children: const [
                Icon(Icons.info_outline, size: 28),
                SizedBox(width: 10),
                Text(
                  'BatchBuddy – Development Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ VERSION 1
            _sectionCard(
              title: 'Version 1.0 (Current)',
              color: Colors.green.shade50,
              icon: Icons.check_circle_outline,
              children: const [
                'User authentication (Signup / Login)',
                'Group creation & joining',
                'Shared expense tracking',
                'Balance calculation',
                'Responsibility assignment (basic)',
              ],
            ),

            const SizedBox(height: 20),

            /// 🚧 VERSION 2
            _sectionCard(
              title: 'Version 2.0 (Coming Soon)',
              color: Colors.orange.shade50,
              icon: Icons.construction,
              children: const [
                'Advanced responsibilities management',
                'Task reminders & due dates',
                'Better balance settlements',
                'Improved UI & animations',
                'Performance and security improvements',
              ],
            ),

            const SizedBox(height: 20),

            /// ⚠️ NOTE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Note:\n'
                'BatchBuddy is actively under development. '
                'Some features may change, improve, or be added in upcoming updates.\n\n'
                'Thank you for your patience and support!',
                style: TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 40),
            const VTSFooter(),
          ],
        ),
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
