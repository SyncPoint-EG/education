import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // Main logo entry animation
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Glow / pulse ring
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  // Rotating particles
  late AnimationController _rotateController;

  // Loading dots
  late AnimationController _dotsController;

  // Text reveal
  late AnimationController _textController;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;

  // Bottom image reveal
  late AnimationController _bottomController;
  late Animation<double> _bottomFadeAnim;
  late Animation<Offset> _bottomSlideAnim;

  @override
  void initState() {
    super.initState();

    // ── Entry ──────────────────────────────────────────────────────────────
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // ── Glow pulse ────────────────────────────────────────────────────────
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Orbiting particles ────────────────────────────────────────────────
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // ── Loading dots ──────────────────────────────────────────────────────
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // ── Text ──────────────────────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // ── Bottom image ──────────────────────────────────────────────────────
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bottomFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeIn),
    );
    _bottomSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );

    // ── Sequence ──────────────────────────────────────────────────────────
    _entryController.forward().then((_) {
      _textController.forward().then((_) {
        _bottomController.forward();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadUser();
      Timer(const Duration(milliseconds: 3200), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => const OnboardingPage(),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _dotsController.dispose();
    _textController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C), Color(0xFF0D1B2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Soft background blobs ────────────────────────────────────
            Positioned(
              top: -80,
              left: -60,
              child: _GlowBlob(
                color: AppColors.primary.withOpacity(0.18),
                size: 300,
              ),
            ),
            Positioned(
              bottom: -60,
              right: -50,
              child: _GlowBlob(
                color: AppColors.secondaryDark.withOpacity(0.15),
                size: 260,
              ),
            ),

            // ── Faculty logo pinned to bottom ────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _bottomFadeAnim,
                child: SlideTransition(
                  position: _bottomSlideAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/image/IMG_5131.png',
                          height: 60,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.modulate,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Orbiting ring + logo ────────────────────────────
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow ring
                        AnimatedBuilder(
                          animation: _glowAnim,
                          builder: (_, __) => Container(
                            width: 190 + _glowAnim.value * 16,
                            height: 190 + _glowAnim.value * 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(
                                      0.25 + _glowAnim.value * 0.25),
                                  blurRadius: 40 + _glowAnim.value * 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Orbiting dots
                        AnimatedBuilder(
                          animation: _rotateController,
                          builder: (_, __) {
                            return SizedBox(
                              width: 210,
                              height: 210,
                              child: CustomPaint(
                                painter: _OrbitPainter(
                                  angle: _rotateController.value * 2 * pi,
                                ),
                              ),
                            );
                          },
                        ),

                        // Logo card
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: ScaleTransition(
                              scale: _scaleAnim,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, -4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/image/IMG_5143.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── App name ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _textFadeAnim,
                    child: SlideTransition(
                      position: _textSlideAnim,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Text(
                              'استمع وتحدث',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Tajawal',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Text(
                              'برنامج تعليمي للأطفال',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),

                  // ── Animated dots ─────────────────────────────────────
                  _AnimatedDots(controller: _dotsController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glowing blob widget ────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ── Orbiting particles painter ─────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final double angle;
  _OrbitPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final colors = [
      const Color(0xFF4FC3F7),
      const Color(0xFFFFD54F),
      const Color(0xFFA5D6A7),
      const Color(0xFFCE93D8),
      const Color(0xFFFF8A65),
    ];

    for (int i = 0; i < colors.length; i++) {
      final a = angle + (2 * pi / colors.length) * i;
      final x = center.dx + radius * cos(a);
      final y = center.dy + radius * sin(a);

      // Glow effect
      canvas.drawCircle(
        Offset(x, y),
        8,
        Paint()
          ..color = colors[i].withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Solid dot
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.angle != angle;
}

// ── Loading dots ───────────────────────────────────────────────────────────
class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = Interval(
              i * 0.2,
              0.6 + i * 0.2,
              curve: Curves.easeInOut,
            ).transform(controller.value);
            return Container(
              width: 10 + t * 4,
              height: 10 + t * 4,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.4 + t * 0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(t * 0.6),
                    blurRadius: 8,
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
