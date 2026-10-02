import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/btn_3d.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/widgets/milestone_celebration_dialog.dart';
import '../../../map/domain/entities/level_entity.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../cubit/game_cubit.dart';
import '../widgets/sound_wave_widget.dart';

// Shake Widget for incorrect answer feedback
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({super.key, required this.child, required this.shake});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offset = 0.0;
        if (_controller.isAnimating) {
          offset = sin(_controller.value * 4 * pi) * 12.0;
        }
        return Transform.translate(
          offset: Offset(offset, 0.0),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class GamePage extends StatefulWidget {
  final LevelEntity level;

  const GamePage({super.key, required this.level});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late GameCubit _gameCubit;
  late ConfettiController _confettiController;
  late AnimationController _floatController;
  bool _triggerShake = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _gameCubit = GameCubit(
      context.read<SpeechService>(),
      context.read<ProfileCubit>(),
    )..startSession(widget.level);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _floatController.dispose();
    _gameCubit.close();
    super.dispose();
  }

  void _handleStateChanges(BuildContext context, GameState state) {
    if (state.feedbackStatus == 'perfect' || state.feedbackStatus == 'good') {
      _confettiController.play();
    }
    if (state.feedbackStatus == 'wrong') {
      setState(() {
        _triggerShake = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _triggerShake = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameCubit,
      child: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: BlocListener<ProfileCubit, ProfileState>(
                    listener: (context, profileState) {
                      if (profileState is ProfileMilestoneUnlocked) {
                        showMilestoneCelebration(
                          context,
                          milestones: profileState.newMilestones,
                          totalStars: profileState.user.totalStars,
                          onDismiss: () {
                            context
                                .read<ProfileCubit>()
                                .acknowledgeMilestones();
                          },
                        );
                      }
                    },
                    child: BlocConsumer<GameCubit, GameState>(
                      listener: _handleStateChanges,
                      builder: (context, state) {
                        if (state.isSessionComplete) {
                          return _buildCompletionScreen(context, state);
                        }

                        final ex = _gameCubit.currentExercise;

                        return Stack(
                          children: [
                            Column(
                              children: [
                                // 1. Header Row
                                _buildHeader(context, state),

                                // 2. Progress Bar
                                _buildProgressBar(state),

                                // 3. Exercise Content Area
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 30),
                                        // Floating Emoji Graphic
                                        ShakeWidget(
                                          shake: _triggerShake,
                                          child: ScaleTransition(
                                            scale:
                                                Tween<double>(
                                                  begin: 0.95,
                                                  end: 1.05,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: _floatController,
                                                    curve: Curves.easeInOut,
                                                  ),
                                                ),
                                            child: Container(
                                              width: 140,
                                              height: 140,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                ex.image,
                                                style: const TextStyle(
                                                  fontSize: 70,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),

                                        // Main Text instruction
                                        Text(
                                          ex.prompt,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 40),

                                        // Input/Action buttons depending on state
                                        if (state.feedbackStatus == 'none' &&
                                            !state.isListening)
                                          _buildInitialActionArea(context, ex)
                                        else if (state.isListening)
                                          _buildListeningArea(context)
                                        else
                                          _buildFeedbackArea(
                                            context,
                                            state,
                                            ex,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Confetti widget overlay
                            Align(
                              alignment: Alignment.topCenter,
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirectionality:
                                    BlastDirectionality.explosive,
                                shouldLoop: false,
                                colors: const [
                                  Colors.green,
                                  Colors.blue,
                                  Colors.pink,
                                  Colors.orange,
                                  Colors.purple,
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ),
          // Level Title
          Text(
            '${widget.level.title} ${widget.level.emoji}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          // Progress Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.currentExIndex + 1} / ${widget.level.exercises.length}',
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GameState state) {
    final double progress =
        (state.currentExIndex) / widget.level.exercises.length;
    return Container(
      width: double.infinity,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress == 0 ? 0.05 : progress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.yellow],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialActionArea(BuildContext context, ExerciseEntity ex) {
    return Column(
      children: [
        // Speak button (if applicable)
        if (ex.type == ExerciseType.listenRepeat ||
            ex.type == ExerciseType.answerQuestion) ...[
          Btn3D(
            color: AppColors.blue,
            shadowColor: AppColors.blueShadow,
            width: double.infinity,
            onPressed: () => _gameCubit.playCurrentPrompt(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔊', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text(
                  'اسمع الكلمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Record / Mic Button
        Btn3D(
          color: AppColors.primary,
          shadowColor: AppColors.primaryShadow,
          width: double.infinity,
          onPressed: () => _gameCubit.startListening(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎤', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                ex.type == ExerciseType.describeImage
                    ? 'ابدأ الكلام'
                    : ex.type == ExerciseType.answerQuestion
                    ? 'جاوب الآن'
                    : 'قول الكلمة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Hints if describe image
        if (ex.type == ExerciseType.describeImage &&
            ex.expectedWords != null) ...[
          const SizedBox(height: 24),
          Text(
            '💡 كلمات مقترحة: ${ex.expectedWords!.join("، ")}',
            style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListeningArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎤 بسمعك...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          const SoundWaveWidget(),
          const SizedBox(height: 24),
          Btn3D(
            color: AppColors.red,
            shadowColor: AppColors.redShadow,
            height: 48,
            width: 140,
            onPressed: () => _gameCubit.stopListening(),
            child: const Text(
              'إلغاء ❌',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackArea(
    BuildContext context,
    GameState state,
    ExerciseEntity ex,
  ) {
    final bool isCorrect =
        state.feedbackStatus == 'perfect' || state.feedbackStatus == 'good';

    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xffE8F5E9) : const Color(0xffFFEBEE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCorrect ? AppColors.primary : AppColors.red,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text(
            isCorrect ? '🎉 ممتاز! أحسنت!' : '😅 مش بأس! جرب تاني',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isCorrect ? AppColors.primaryDark : AppColors.redDark,
            ),
          ),
          const SizedBox(height: 12),
          if (state.recognizedText.isNotEmpty) ...[
            Text(
              'أنت قلت: "${state.recognizedText}"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (!isCorrect) ...[
            Text(
              'الكلمة الصح: "${ex.word ?? ex.expectedAnswer ?? (ex.expectedWords?.join('، ') ?? '')}"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textMid,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Btn3D(
                    color: AppColors.blue,
                    shadowColor: AppColors.blueShadow,
                    height: 48,
                    onPressed: () => _gameCubit.playCurrentPrompt(),
                    child: const Text(
                      '🔊 اسمع',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Btn3D(
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryShadow,
                    height: 48,
                    onPressed: () => _gameCubit.repeatExercise(),
                    child: const Text(
                      '🎤 حاول تاني',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _gameCubit.skipExercise(),
              child: const Text(
                'تخطي ←',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Btn3D(
              color: AppColors.primary,
              shadowColor: AppColors.primaryShadow,
              width: double.infinity,
              onPressed: () => _gameCubit.nextExercise(),
              child: const Text(
                'التالي ←',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, GameState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            '🎊 أحسنت يا بطل! 🎊',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'أتممت مستوى: ${widget.level.title}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMid,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Level Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final earned = index < state.earnedStars;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 200)),
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Text(
                      '⭐',
                      style: TextStyle(
                        fontSize: 48,
                        color: earned
                            ? Colors.amber
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 40),

          // Rewards Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRewardItem(
                  label: 'الذهب المكتسب',
                  value: '+${state.earnedStars * 10}',
                  emoji: '🪙',
                  color: AppColors.yellow,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildRewardItem(
                  label: 'الجواهر المكتسبة',
                  value: state.earnedStars == 3 ? '+1' : '+0',
                  emoji: '💎',
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),

          // Action buttons
          Btn3D(
            color: AppColors.primary,
            shadowColor: AppColors.primaryShadow,
            width: double.infinity,
            onPressed: () {
              Navigator.pop(context); // Return to MapPage
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('↩️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text(
                  'الرجوع للخريطة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Btn3D(
            color: AppColors.secondary,
            shadowColor: AppColors.secondaryShadow,
            width: double.infinity,
            onPressed: () {
              _gameCubit.startSession(widget.level);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔄', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'العب تاني',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String label,
    required String value,
    required String emoji,
    required Color color,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
            fontFamily: 'Fredoka',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
