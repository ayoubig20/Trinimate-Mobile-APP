import 'package:flutter/material.dart';

/// Replicates the sign_in drawable:
/// 346x657 card, 35 radius corners, #000000 fill, 2px stroke.
class SignInCard extends StatelessWidget {
  const SignInCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 346),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 657),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: const Color(0x1A000000), // stroke from the vector
              width: 2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}