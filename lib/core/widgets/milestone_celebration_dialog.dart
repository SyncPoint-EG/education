import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_colors.dart';
import '../../features/profile/domain/entities/star_milestone.dart';
import 'btn_3d.dart';

/// A celebratory dialog shown when a player unlocks a new star milestone.
/// Features confetti, bounce animation, and the milestone details.
class MilestoneCelebrationDialog extends StatefulWidget {
  final List<StarMilestone> milestones;
  final int totalStars;
  final VoidCallback onDismiss;

  const MilestoneCelebrationDialog({
    super.key,
    required this.milestones,
    required this.totalStars,
    required this.onDismiss,
  });

  @override
  State<MilestoneCelebrationDialog> createState() =>
      _MilestoneCelebrationDialogState();
}

class _MilestoneCelebrationDialogState
    extends State<MilestoneCelebrationDialog> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnim;
  late Animation<double> _glowAnim;
  int _currentMilestoneIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _confettiController.play();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  StarMilestone get _currentMilestone =>
      widget.milestones[_currentMilestoneIndex];

  void _next() {
    if (_currentMilestoneIndex < widget.milestones.length - 1) {
      setState(() => _currentMilestoneIndex++);
      _bounceController.forward(from: 0.0);
      _confettiController.play();
    } else {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestone = _currentMilestone;
    final nextMilestone = getNextMilestone(
      widget.milestones.map((m) => m.id).toList(),
    );

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Background tap to dismiss
          GestureDetector(
            onTap: _next,
            child: Container(color: Colors.transparent),
          ),

          // Content
          Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnim.value,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Milestone counter (e.g., 1/2)
                      if (widget.milestones.length > 1)
                        Text(
                          '${_currentMilestoneIndex + 1} / ${widget.milestones.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                            fontFamily: 'Fredoka',
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Title
                      const Text(
                        '🎊 مبرووووك! 🎊',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Glowing emoji
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (context, child) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.yellow
                                      .withOpacity(0.3 * _glowAnim.value),
                                  AppColors.yellow.withOpacity(0.0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.yellow
                                      .withOpacity(0.4 * _glowAnim.value),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.yellow,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                milestone.emoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Milestone title
                      Text(
                        milestone.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        milestone.rewardDescription,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMid,
                          fontFamily: 'Tajawal',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Stars count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐',
                                style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.totalStars} نجمة',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Bonus reward info
                      Text(
                        '+25 🪙  +1 💎',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMid.withOpacity(0.7),
                          fontFamily: 'Fredoka',
                        ),
                      ),

                      // Next milestone hint
                      if (nextMilestone != null) ...[
                        const SizedBox(height: 16),
                        _buildNextMilestoneHint(nextMilestone),
                      ],

                      const SizedBox(height: 24),

                      // Action button
                      Btn3D(
                        color: AppColors.primary,
                        shadowColor: AppColors.primaryShadow,
                        width: double.infinity,
                        onPressed: _next,
                        child: Text(
                          _currentMilestoneIndex <
                                  widget.milestones.length - 1
                              ? 'التالي ←'
                              : 'يلا نكمل! 🚀',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.06,
              numberOfParticles: 25,
              maxBlastForce: 30,
              minBlastForce: 10,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMilestoneHint(StarMilestone next) {
    final remaining = next.requiredStars - widget.totalStars;
    final progress = widget.totalStars / next.requiredStars;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgMain,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(next.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'المايلستون الجاي: ${next.title}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMid,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'باقي $remaining نجمة ⭐',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the milestone celebration as a full-screen overlay dialog.
void showMilestoneCelebration(
  BuildContext context, {
  required List<StarMilestone> milestones,
  required int totalStars,
  required VoidCallback onDismiss,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (context, anim1, anim2) {
      return MilestoneCelebrationDialog(
        milestones: milestones,
        totalStars: totalStars,
        onDismiss: () {
          Navigator.of(context).pop();
          onDismiss();
        },
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
