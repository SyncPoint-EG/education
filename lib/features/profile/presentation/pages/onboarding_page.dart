import 'package:flutter/material.dart';
import '../../../../core/widgets/btn_3d.dart';
import 'welcome_page.dart';

// ─── OnboardingPage ───────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomePage()));
    }
  }

  void _skip() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff0D1B2A),
        body: Stack(
          children: [
            // ── Background gradient that shifts per page ───────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _bgColors(_currentPage),
                ),
              ),
            ),

            // ── Decorative gold circles ────────────────────────────────────
            ..._goldBubbles(MediaQuery.of(context).size),

            // ── Pages ─────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Skip
                  if (_currentPage < _totalPages - 1)
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _skip,
                        child: const Text(
                          'تخطي',
                          style: TextStyle(
                            color: Color(0xffD4AF37),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 44),

                  // Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                        _fadeController
                          ..reset()
                          ..forward();
                      },
                      children: [
                        _Page1(fadeCtrl: _fadeController),
                        _Page2(fadeCtrl: _fadeController),
                        _Page3(fadeCtrl: _fadeController),
                      ],
                    ),
                  ),

                  // Dots
                  _DotsIndicator(count: _totalPages, current: _currentPage),
                  const SizedBox(height: 20),

                  // Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Btn3D(
                      color: const Color(0xffD4AF37),
                      shadowColor: const Color(0xff8B6914),
                      width: double.infinity,
                      onPressed: _next,
                      child: Text(
                        _currentPage == _totalPages - 1
                            ? 'ابدأ التطبيق 🚀'
                            : 'التالي',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _bgColors(int page) {
    switch (page) {
      case 0:
        return [const Color(0xff1A2744), const Color(0xff0D1B2A)];
      case 1:
        return [const Color(0xff1C2B1A), const Color(0xff0D1B0D)];
      case 2:
        return [const Color(0xff2A1A2A), const Color(0xff1B0D1B)];
      default:
        return [const Color(0xff2A1A0D), const Color(0xff1B0D0D)];
    }
  }

  List<Widget> _goldBubbles(Size size) {
    return [
      _bubble(size.width * 0.88, -40, 130),
      _bubble(-40, size.height * 0.18, 100),
      _bubble(size.width * 0.65, size.height * 0.55, 80),
      _bubble(size.width * 0.08, size.height * 0.72, 110),
    ];
  }

  Widget _bubble(double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xffD4AF37).withValues(alpha: 0.07),
        ),
      ),
    );
  }
}

// ─── Page 1 — عنوان البحث ─────────────────────────────────────────────────────

class _Page1 extends StatelessWidget {
  final AnimationController fadeCtrl;
  const _Page1({required this.fadeCtrl});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: fadeCtrl, curve: Curves.easeIn),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // University logo — animated entry
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + value * 0.4,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xffD4AF37),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffD4AF37).withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/image/IMG_5133.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // University name
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeIn,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'جامعة بنها',
                    style: TextStyle(
                      color: Color(0xffD4AF37),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const Text(
                    'كلية التربية النوعية',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const Text(
                    'قسم العلوم التربوية والنفسية — تخصص تربية خاصة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Divider
            _GoldDivider(),

            const SizedBox(height: 24),

            // Arabic title
            _GlassCard(
              child: Column(
                children: [
                  const Text(
                    'عنوان الرساله',
                    style: TextStyle(
                      color: Color(0xffD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تنمية بعض مهارات التواصل اللغوي لعينة من الأطفال ذوي التأخر اللغوي باستخدام بيئة تعلم تفاعلية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  // English title
                  const Text(
                    'Developing some linguistic communication skills for a sample of children with language delay using an interactive learning environment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Researcher
            _GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👩‍🎓', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إعداد الباحثة',
                        style: TextStyle(
                          color: Color(0xffD4AF37),
                          fontSize: 12,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'سهيلة أحمد الصغير بيومي قته',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 2 — لجنة الإشراف ──────────────────────────────────────────────────

class _Page2 extends StatelessWidget {
  final AnimationController fadeCtrl;
  const _Page2({required this.fadeCtrl});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: fadeCtrl, curve: Curves.easeIn),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            const Text(
              'لجنة الإشراف',
              style: TextStyle(
                color: Color(0xffD4AF37),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Tajawal',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            _GoldDivider(),
            const SizedBox(height: 24),

            // Main supervisor
            _SupervisorCard(
              rank: 'أ . د .',
              name: 'صلاح الدين عبدالقادر محمد',
              title: 'أستاذ الصحة النفسية المتفرغ',
              place: 'كلية التربية النوعية — جامعة بنها',
              emoji: '👨‍🏫',
              imagePath: 'assets/image/PHOTO-2026-06-05-22-07-09.jpg',
              isMain: true,
            ),

            const SizedBox(height: 20),

            _SupervisorCard(
              rank: 'أ . م . د .',
              name: 'هبة حسين عبد الحميد',
              title: 'أستاذ تكنولوجيا التعليم المساعد',
              place: 'كلية التربية النوعية — جامعة بنها',
              emoji: '👩‍💻',
              imagePath: 'assets/image/PHOTO-2026-06-05-22-37-09.jpg',
              isMain: false,
            ),

            const SizedBox(height: 16),

            _SupervisorCard(
              rank: 'د .',
              name: 'وحيد مصطفى كامل',
              title: 'مدرس الصحة النفسية المتفرغ',
              place: 'كلية التربية النوعية — جامعة بنها',
              emoji: '👨‍🔬',
              imagePath: 'assets/image/PHOTO-2026-06-05-22-07-39.jpg',
              isMain: false,
            ),

            const SizedBox(height: 24),

            // Quote / verse decoration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: const Color(0xffD4AF37).withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
              ),
              child: const Text(
                '\"وَعَلَّمَكَ مَا لَمْ تَكُن تَعْلَمُ ۚ وَكَانَ فَضْلُ اللَّهِ عَلَيْكَ عَظِيمًا\"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Tajawal',
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Year badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffD4AF37).withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '٢٠٢٦ م',
                  style: TextStyle(
                    color: Color(0xffD4AF37),
                    fontSize: 20,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Thank you note
            _GlassCard(
              child: Column(
                children: [
                  const Text('🙏', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 10),
                  const Text(
                    'شكر وتقدير',
                    style: TextStyle(
                      color: Color(0xffD4AF37),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'جزيل الشكر والامتنان لكل من أسهم في إنجاز هذه الرساله من أساتذة وزملاء وأولياء أمور.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Tajawal',
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3 — شكر خاص ────────────────────────────────────────────────────────

class _Page3 extends StatelessWidget {
  final AnimationController fadeCtrl;
  const _Page3({required this.fadeCtrl});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: fadeCtrl, curve: Curves.easeIn),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GlassCard(
                child: Column(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 20),
                    const Text(
                      'إهداء خاص',
                      style: TextStyle(
                        color: Color(0xffD4AF37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GoldDivider(),
                    const SizedBox(height: 24),
                    const Text(
                      'إلى زوجي الحبيب، وأبي وأمي أدام الله عليكم الصحة والعافية، وإخوتي الأعزاء وأبنائهم الغاليين، وقرة عيني أبنائي سيف وياسين بارك الله فيكم جميعاً وحفظكم لي.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Tajawal',
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SupervisorCard extends StatelessWidget {
  final String rank;
  final String name;
  final String title;
  final String place;
  final String emoji;
  final String? imagePath;
  final bool isMain;

  const _SupervisorCard({
    required this.rank,
    required this.name,
    required this.title,
    required this.place,
    required this.emoji,
    this.imagePath,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain
              ? const Color(0xffD4AF37)
              : const Color(0xffD4AF37).withValues(alpha: 0.35),
          width: isMain ? 2 : 1,
        ),
        color: isMain
            ? const Color(0xffD4AF37).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: isMain ? 90 : 70,
            height: isMain ? 90 : 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: const Color(0xffD4AF37).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Image.asset(
                      imagePath!,
                      width: isMain ? 90 : 70,
                      height: isMain ? 90 : 70,
                      fit: BoxFit.fill,
                    ),
                  )
                : Text(emoji, style: TextStyle(fontSize: isMain ? 45 : 35)),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rank,
                    style: TextStyle(
                      color: const Color(0xffD4AF37),
                      fontSize: isMain ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMain ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: isMain ? 16 : 14,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  place,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: isMain ? 13 : 11,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          color: const Color(0xffD4AF37).withValues(alpha: 0.4),
        ),
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffD4AF37),
          ),
        ),
        Container(
          width: 40,
          height: 1,
          color: const Color(0xffD4AF37).withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

// ─── Dots Indicator ───────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xffD4AF37)
                : const Color(0xffD4AF37).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
