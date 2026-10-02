import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/btn_3d.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../domain/entities/star_milestone.dart';
import '../cubit/profile_cubit.dart';

// ─── WelcomePage ──────────────────────────────────────────────────────────────

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAvatar = '�';
  final List<String> _avatars = ['🐰', '🐸', '🐻', '🦊', '🐧', '🦁', '🐙'];

  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _floatAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _floatAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🥺', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'بدء من جديد؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'هيتمسح كل البيانات والتقدم اللي عملته.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMid,
                    fontFamily: 'Tajawal',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.textLight),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: AppColors.textMid,
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          context.read<ProfileCubit>().resetUser();
                          _nameController.clear();
                          setState(() => _selectedAvatar = '�');
                        },
                        child: const Text(
                          'امسح',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── Animated background ──────────────────────────────────────
            _AnimatedBackground(size: size),

            // ── Content ──────────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state is ProfileAuthenticated) {
                        return _WelcomeBackScreen(
                          user: state.user,
                          floatAnim: _floatAnim,
                          fadeAnim: _fadeAnim,
                          slideAnim: _slideAnim,
                          scaleAnim: _scaleAnim,
                          onReset: () => _showResetConfirmation(context),
                        );
                      }

                      return _CreateProfileScreen(
                        nameController: _nameController,
                        selectedAvatar: _selectedAvatar,
                        avatars: _avatars,
                        fadeAnim: _fadeAnim,
                        slideAnim: _slideAnim,
                        onAvatarSelected: (a) =>
                            setState(() => _selectedAvatar = a),
                      );
                    },
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

// ─── Welcome Back Screen ─────────────────────────────────────────────────────

class _WelcomeBackScreen extends StatelessWidget {
  final dynamic user;
  final Animation<double> floatAnim;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> scaleAnim;
  final VoidCallback onReset;

  const _WelcomeBackScreen({
    required this.user,
    required this.floatAnim,
    required this.fadeAnim,
    required this.slideAnim,
    required this.scaleAnim,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Floating avatar ──────────────────────────────────────
              AnimatedBuilder(
                animation: floatAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, floatAnim.value),
                  child: child,
                ),
                child: ScaleTransition(
                  scale: scaleAnim,
                  child: _AvatarHero(avatar: user.avatar, size: 130),
                ),
              ),

              const SizedBox(height: 28),

              // ── Greeting ─────────────────────────────────────────────
              Text(
                'أهلاً يا ${user.name}! 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Tajawal',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'يلا نكمل مذاكرتنا 🌟',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats row ────────────────────────────────────────────
              _StatsRow(
                gold: user.gold,
                gems: user.gems,
                stars: user.totalStars,
              ),

              const SizedBox(height: 24),

              // ── Star Progress ────────────────────────────────────────
              _StarProgressCard(user: user),

              const SizedBox(height: 32),

              // ── Play button ──────────────────────────────────────────
              Btn3D(
                color: AppColors.primary,
                shadowColor: AppColors.primaryShadow,
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MapPage()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎮', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Text(
                      'استمر في التفاعل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Reset link ───────────────────────────────────────────
              GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.red.withValues(alpha: 0.08),
                  ),
                  child: const Text(
                    'بدء من الأول؟',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Create Profile Screen ───────────────────────────────────────────────────

class _CreateProfileScreen extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedAvatar;
  final List<String> avatars;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final ValueChanged<String> onAvatarSelected;

  const _CreateProfileScreen({
    required this.nameController,
    required this.selectedAvatar,
    required this.avatars,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = nameController.text.trim().isEmpty;

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AvatarHero(avatar: selectedAvatar, size: 90),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أهلاً! 👋',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'إيه اسمك الجميل؟',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMid,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Name Input ───────────────────────────────────────────
              _NameField(controller: nameController),

              const SizedBox(height: 32),

              // ── Avatar selection ─────────────────────────────────────
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختار شخصيتك:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _AvatarGrid(
                avatars: avatars,
                selected: selectedAvatar,
                onSelect: onAvatarSelected,
              ),

              const SizedBox(height: 40),

              // ── Play Button ──────────────────────────────────────────
              Btn3D(
                color: AppColors.primary,
                shadowColor: AppColors.primaryShadow,
                width: double.infinity,
                disabled: isButtonDisabled,
                onPressed: isButtonDisabled
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        context.read<ProfileCubit>().createUser(
                          name,
                          selectedAvatar,
                        );
                      },
                child: AnimatedOpacity(
                  opacity: isButtonDisabled ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🚀', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 10),
                      Text(
                        'يلا نتفاعل!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

/// Glowing avatar circle with animated ring
class _AvatarHero extends StatelessWidget {
  final String avatar;
  final double size;
  const _AvatarHero({required this.avatar, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: size + 24,
          height: size + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Dashed ring
        CustomPaint(
          size: Size(size + 12, size + 12),
          painter: _DashedCirclePainter(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        // Avatar circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(avatar, style: TextStyle(fontSize: size * 0.48)),
        ),
      ],
    );
  }
}

/// Stats row showing gold and gems with a card style
class _StatsRow extends StatelessWidget {
  final int gold;
  final int gems;
  final int stars;
  const _StatsRow({
    required this.gold,
    required this.gems,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              icon: '🪙',
              label: 'ذهب',
              value: gold,
              color: AppColors.secondary,
            ),
            VerticalDivider(
              color: AppColors.textLight.withValues(alpha: 0.5),
              thickness: 1,
              width: 24,
            ),
            _StatItem(
              icon: '💎',
              label: 'جواهر',
              value: gems,
              color: AppColors.accent,
            ),
            VerticalDivider(
              color: AppColors.textLight.withValues(alpha: 0.5),
              thickness: 1,
              width: 24,
            ),
            _StatItem(
              icon: '⭐',
              label: 'نجوم',
              value: stars,
              color: AppColors.yellow,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final Color color;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMid,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}

/// Styled name input field
class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        fontFamily: 'Tajawal',
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: 'اكتب اسمك هنا...',
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontFamily: 'Tajawal',
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(right: 12, left: 4),
          child: Text('✏️', style: TextStyle(fontSize: 20)),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }
}

/// Avatar selection grid
class _AvatarGrid extends StatelessWidget {
  final List<String> avatars;
  final String selected;
  final ValueChanged<String> onSelect;
  const _AvatarGrid({
    required this.avatars,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final bool isSelected = selected == avatar;
        return GestureDetector(
          onTap: () => onSelect(avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textLight,
                width: isSelected ? 3.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            transform: isSelected
                ? (Matrix4.identity()..scale(1.12, 1.12, 1.0))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            alignment: Alignment.center,
            child: Text(avatar, style: const TextStyle(fontSize: 44)),
          ),
        );
      },
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  final Size size;
  const _AnimatedBackground({required this.size});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: widget.size,
        painter: _BgPainter(t: _anim.value),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xffE8F5E9), Color(0xffF1F8E9), Color(0xffE3F2FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Soft floating blobs
    _blob(
      canvas,
      size.width * 0.85,
      size.height * 0.08 + t * 20,
      120,
      const Color(0xff4CAF50),
      0.07,
    );
    _blob(
      canvas,
      size.width * 0.05,
      size.height * 0.2 - t * 15,
      90,
      const Color(0xff81C784),
      0.08,
    );
    _blob(
      canvas,
      size.width * 0.6,
      size.height * 0.6 + t * 10,
      80,
      const Color(0xff2196F3),
      0.05,
    );
    _blob(
      canvas,
      size.width * 0.15,
      size.height * 0.78 - t * 12,
      100,
      const Color(0xffFF9800),
      0.05,
    );
    _blob(
      canvas,
      size.width * 0.75,
      size.height * 0.42 + t * 8,
      70,
      const Color(0xffE91E8C),
      0.04,
    );
  }

  void _blob(
    Canvas c,
    double x,
    double y,
    double r,
    Color color,
    double opacity,
  ) {
    c.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ─── Dashed Circle Painter ─────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount = 20;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

/// Card displaying progress towards the next star milestone
class _StarProgressCard extends StatelessWidget {
  final dynamic user;
  const _StarProgressCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final nextMilestone = getNextMilestone(
      List<String>.from(user.unlockedMilestones),
    );
    if (nextMilestone == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.yellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Text(
            'لقد جمعت كل النجوم! 🌟👑',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xffFBC02D),
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      );
    }

    final totalStars = user.totalStars;
    final requiredStars = nextMilestone.requiredStars;
    final progress = totalStars / requiredStars;
    final remaining = requiredStars - totalStars;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  nextMilestone.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المايلستون الجاي: ${nextMilestone.title}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMid,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'باقي $remaining نجمة ⭐',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}
