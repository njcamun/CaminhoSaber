import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;

  const BackgroundContainer({super.key, required this.child, this.baseColor});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = baseColor ?? Colors.blue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
            ? [Colors.black, primaryColor.withValues(alpha: 0.2)]
            : [primaryColor.withValues(alpha: 0.1), Colors.white],
        ),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(isDarkMode 
                    ? 'assets/images/background_dark.png' 
                    : 'assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
