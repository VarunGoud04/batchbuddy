import 'package:flutter/material.dart';

class FadeSlideRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
        );
}
