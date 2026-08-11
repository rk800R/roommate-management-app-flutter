import 'package:flutter/material.dart';
import '../theme/themedata.dart';

/// Animated splash with logo scale-in + fade-out transition.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            AppWidgets.glowOrb(
              top: -120, left: -80, size: 320, color: AppColors.violetOrb,
            ),
            AppWidgets.glowOrb(
              bottom: -100, right: -90, size: 300, color: AppColors.blueBrand,
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96, height: 96,
                        decoration: AppDecorations.logoIcon(),
                        child: const Icon(Icons.group_rounded, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'RoomieSync',
                        style: AppTextStyles.heading.copyWith(fontSize: 34),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Roommate Management',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 28, height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}