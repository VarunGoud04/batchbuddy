import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

import 'splash/splash_page.dart';
import 'auth/auth_home_page.dart';
import 'auth/login_page.dart';
import 'home/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BatchBuddyApp());
}

class BatchBuddyApp extends StatelessWidget {
  const BatchBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BatchBuddy',

      // ================== GLOBAL THEME ==================
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFF1F5F9),
          surfaceVariant: const Color(0xFFE2E8F0),
          onSurfaceVariant: Colors.black87,
        ),

        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F766E),
          elevation: 0.6,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // ✅ CORRECT MATERIAL 3 CARD THEME
        cardTheme: const CardThemeData(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
          ),
        ),
      ),

      // ================== ROUTING ==================
      initialRoute: '/',
      onGenerateRoute: (settings) {
        late final Widget page;

        switch (settings.name) {
          case '/':
            page = const SplashPage();
            break;
          case '/welcome':
            page = const AuthHomePage();
            break;
          default:
            page = const AuthGate();
        }

        return PageRouteBuilder(
          pageBuilder: (_, animation, __) => page,
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation = animation.drive(
              Tween(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).chain(
                CurveTween(curve: Curves.easeInOutCubic),
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}

// ================== GRADIENT BACKGROUND ==================
class GradientBackground extends StatefulWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  int currentIndex = 0;

  final List<Color> colors = const [
    Color(0xFF0F766E),
    Color(0xFF059669),
    Color(0xFF0891B2),
  ];

  @override
  void initState() {
    super.initState();
    _cycleColors();
  }

  void _cycleColors() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        currentIndex = (currentIndex + 1) % colors.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[currentIndex],
            colors[(currentIndex + 1) % colors.length],
          ],
        ),
      ),
      child: widget.child,
    );
  }
}

// ================== SHIMMER CARD ==================
class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerCard({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ================== AUTH GATE ==================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0F766E),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}
