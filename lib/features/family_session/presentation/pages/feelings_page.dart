import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/btn_3d.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Feelings Assessment: How did the child feel during the session?
/// Two large emoji buttons (☹️ and 😄) + completion summary.
/// ─────────────────────────────────────────────────────────────────────────────

class FeelingsPage extends StatefulWidget {
  final int totalStars;
  final String sessionName;
  final VoidCallback onComplete;

  const FeelingsPage({
    super.key, 
    required this.totalStars, 
    this.sessionName = 'الجلسة',
    required this.onComplete,
  });

  @override
  State<FeelingsPage> createState() => _FeelingsPageState();
}

class _FeelingsPageState extends State<FeelingsPage> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasSelected = false;
  bool _isHappy = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _selectFeeling(bool happy) {
    setState(() {
      _hasSelected = true;
      _isHappy = happy;
    });
    if (happy) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _hasSelected ? _buildCompletionView() : _buildSelectionView(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating emoji
            ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                alignment: Alignment.center,
                child: const Text('🤔', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'كيف كان شعورك أثناء الجلسة؟',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, fontFamily: 'Tajawal'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'اختر الوجه اللي بيعبر عن إحساسك',
              style: TextStyle(fontSize: 15, color: AppColors.textMid, fontFamily: 'Tajawal'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // Two emoji buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeelingButton(
                  emoji: '☹️',
                  label: 'مش مبسوط',
                  color: AppColors.red,
                  onTap: () => _selectFeeling(false),
                ),
                _buildFeelingButton(
                  emoji: '😄',
                  label: 'مبسوط!',
                  color: AppColors.primary,
                  onTap: () => _selectFeeling(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingButton({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 3),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.2), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              _isHappy ? '🎊 أحسنت يا بطل! 🎊' : '💙 شكراً لمشاركتك!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isHappy
                  ? 'لقد أتممت ${widget.sessionName} بنجاح!'
                  : 'لا تقلق، المرة الجاية هتكون أحلى! 💪',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMid, fontFamily: 'Tajawal'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Stars earned
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final earned = index < widget.totalStars;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 150)),
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Text(
                        '⭐',
                        style: TextStyle(
                          fontSize: 36,
                          color: earned ? Colors.amber : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 30),

            // Reward card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text(
                    'شعورك أثناء الجلسة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLight, fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isHappy ? '😄 مبسوط!' : '☹️ مش مبسوط',
                    style: const TextStyle(fontSize: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Return button
            Btn3D(
              color: AppColors.primary,
              shadowColor: AppColors.primaryShadow,
              width: double.infinity,
              onPressed: widget.onComplete,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('↩️', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'الرجوع للخريطة',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
