import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VTSFooter extends StatefulWidget {
  const VTSFooter({super.key});

  @override
  State<VTSFooter> createState() => _VTSFooterState();
}

class _VTSFooterState extends State<VTSFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _leftColor;
  late Animation<Color?> _rightColor;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _leftColor = ColorTween(
      begin: const Color(0xFF2DD4BF), // teal
      end: const Color(0xFFA855F7), // purple
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rightColor = ColorTween(
      begin: const Color(0xFFF97316), // orange
      end: const Color(0xFF22C55E), // green
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fail silently – footer links should never crash UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final gradient = LinearGradient(
          colors: [
            _leftColor.value ?? Colors.teal,
            _rightColor.value ?? Colors.orange,
          ],
        );

        return Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated divider
              Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: gradient,
                ),
              ),

              const SizedBox(height: 12),

              // Brand line
              ShaderMask(
                shaderCallback: (bounds) {
                  return gradient.createShader(bounds);
                },
                child: const Text(
                  'BatchBuddy · A VarunTechServices product',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              ShaderMask(
                shaderCallback: (bounds) {
                  return gradient.createShader(bounds);
                },
                child: const Text(
                  'Designed & engineered with AI-assisted workflows',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 🔗 LINKS
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  GestureDetector(
                    onTap: () => _openLink(
                      'https://varuntechservices.vercel.app',
                    ),
                    child: const Text(
                      'Website',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openLink(
                      'https://www.linkedin.com/in/bandi-varun-goud/',
                    ),
                    child: const Text(
                      'LinkedIn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
