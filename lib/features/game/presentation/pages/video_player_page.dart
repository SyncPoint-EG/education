import 'dart:async';

import 'package:education/features/family_session/presentation/pages/feelings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/audio_output_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/btn_3d.dart';
import '../../../map/domain/entities/level_entity.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../family_session/presentation/pages/family_session_page.dart';
import '../../../farm_session/presentation/pages/farm_session_page.dart';
import '../widgets/advanced_assessment_game.dart';

class VideoPlayerPage extends StatefulWidget {
  final LevelEntity level;
  final bool startAssessmentImmediately;
  const VideoPlayerPage({
    super.key,
    required this.level,
    this.startAssessmentImmediately = false,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();
  bool _hasVideoController = false;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showAssessment = false;
  int _currentAssessmentIndex = 0;
  int? _selectedOptionIndex;
  bool _answeredAssessment = false;
  int _assessmentStars = 0;
  final Map<int, int> _matchedAssessmentTargets = {};
  int? _wrongDragOptionIndex;
  bool _reinforcementInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.level.videoPath.isEmpty || widget.startAssessmentImmediately) {
      _showAssessment = true;
      _startAssessmentMusic();
      return;
    }
    _hasVideoController = true;
    _controller = VideoPlayerController.asset(widget.level.videoPath);
    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _controller.play();
            _controller.addListener(_videoListener);
          }
        })
        .catchError((error) {
          debugPrint("Error loading video: $error");
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
  }

  void _videoListener() {
    if (mounted && _controller.value.isInitialized) {
      if (_controller.value.position >= _controller.value.duration) {
        _onVideoEnded();
      }
      setState(() {}); // Redraw for progress indicator and time updates
    }
  }

  void _onVideoEnded() {
    _controller.removeListener(_videoListener);
    _controller.pause();

    if (widget.level.id == 1 || widget.level.id == 2) {
      _navigateToGame();
      return;
    }

    if (mounted) {
      setState(() {
        _showAssessment = true;
      });
      _startAssessmentMusic();
    }
  }

  void _navigateToGame() {
    // For level 1 (أسرتي), navigate to the Family Session interactive game
    if (widget.level.id == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FamilySessionPage(initialStars: _assessmentStars),
        ),
      );
    } else if (widget.level.id == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FarmSessionPage(initialStars: _assessmentStars),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (newContext) => Scaffold(
            backgroundColor: const Color(0xffFAF8F5),
            body: SafeArea(
              child: FeelingsPage(
                sessionName: widget.level.title,
                totalStars: _assessmentStars + 1,
                onComplete: () {
                  _assessmentStars++;
                  newContext.read<ProfileCubit>().completeLevel(
                    widget.level.id,
                    _assessmentStars,
                  );
                  Navigator.pop(newContext);
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_hasVideoController) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _feedbackPlayer.stop();
    _feedbackPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldStop =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (!shouldStop) return;

    if (_hasVideoController) {
      unawaited(_controller.pause());
    }
    unawaited(_audioPlayer.stop());
    unawaited(_feedbackPlayer.stop());
  }

  Future<void> _startAssessmentMusic() async {
    // Music disabled to prevent buzzing sound
  }

  Future<void> _showAnswerReinforcement(
    bool correct, {
    bool isNegativeFeeling = false,
  }) async {
    if (_reinforcementInProgress) return;
    _reinforcementInProgress = true;
    final bool showPositive = correct && !isNegativeFeeling;

    try {
      await AudioOutputService.playAsset(
        _feedbackPlayer,
        showPositive ? 'audio/correct_chime.m4a' : 'audio/wrong_tone.m4a',
      );
      if (!mounted) return;

      // Vary the reinforcement globally for positive as requested
      final positiveEmojis = ['🎉✨', '🎈🎊', '🎆🎇'];
      final randomPositive =
          positiveEmojis[DateTime.now().millisecond % positiveEmojis.length];

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      final controller = messenger.showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Center(
            child: Container(
              width: isNegativeFeeling ? 160 : 140,
              height: 120,
              decoration: BoxDecoration(
                color: showPositive
                    ? const Color(0xff4ECE6C)
                    : Colors.redAccent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 18),
                ],
              ),
              alignment: Alignment.center,
              child: isNegativeFeeling
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/image/sad_face.png',
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) =>
                              const Text('😢', style: TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'حاول مرة أخرى',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    )
                  : Text(
                      showPositive ? randomPositive : '✖️👎',
                      style: const TextStyle(fontSize: 42),
                    ),
            ),
          ),
        ),
      );
      await controller.closed;
    } finally {
      _reinforcementInProgress = false;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1A237E), Color(0xff004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Row: Back button, Level Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'شاهد وتعلم: ${widget.level.title} ${widget.level.emoji}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 44),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Video Screen Area — Expanded fills all remaining space
                          Expanded(
                            child: _isInitialized
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xff8D5524),
                                        width: 5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(19),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          // Fill the container with the video, centered
                                          SizedBox.expand(
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: _controller
                                                    .value
                                                    .size
                                                    .width,
                                                height: _controller
                                                    .value
                                                    .size
                                                    .height,
                                                child: VideoPlayer(_controller),
                                              ),
                                            ),
                                          ),
                                          // Playback Controls Overlay
                                          _buildControlsOverlay(),
                                        ],
                                      ),
                                    ),
                                  )
                                : !_hasError
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white12,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xff4ECE6C),
                                            ),
                                      ),
                                    ),
                                  )
                                : _buildErrorState(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showAssessment) _buildAssessmentOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentOverlay() {
    final activities = widget.level.assessmentActivities;
    final activity = activities[_currentAssessmentIndex];
    final isLastActivity = _currentAssessmentIndex == activities.length - 1;
    final progress =
        (_currentAssessmentIndex + (_answeredAssessment ? 1 : 0)) /
        activities.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF3FFF5), Color(0xffE5F6FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_assessmentStars / ${activities.length}',
                            style: const TextStyle(
                              color: AppColors.textMid,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          flex: 4,
                          child: Text(
                            '${activity.emoji} ${widget.level.title}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _navigateToGame,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.04, 1),
                        minHeight: 12,
                        backgroundColor: Colors.black.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(child: _buildAssessmentGame(activity)),
                    if (_answeredAssessment) ...[
                      const SizedBox(height: 12),
                      _buildAssessmentFeedback(activity),
                      const SizedBox(height: 14),
                      Btn3D(
                        color: AppColors.primary,
                        shadowColor: AppColors.primaryShadow,
                        height: 50,
                        onPressed: () => isLastActivity
                            ? _navigateToGame()
                            : _goToNextAssessment(),
                        child: Text(
                          isLastActivity
                              ? (widget.level.id <= 2
                                    ? 'ابدأ النشاط'
                                    : 'العودة للخريطة')
                              : 'السؤال التالي',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        _assessmentHint(activity.type),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentGame(AssessmentActivityEntity activity) {
    if (_isAdvancedActivity(activity.type)) {
      return AdvancedAssessmentGame(
        key: ValueKey(_currentAssessmentIndex),
        activity: activity,
        speechService: context.read<SpeechService>(),
        onCompleted: _completeAdvancedActivity,
        onCorrectStep: () => _showAnswerReinforcement(true),
        onIncorrect: () => _showAnswerReinforcement(false),
      );
    }

    if (activity.type == AssessmentGameType.dragToTarget) {
      return _buildGenericDragGame(activity);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
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
            child: activity.iconPath != null
                ? Image.asset(
                    activity.iconPath!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  )
                : Text(activity.emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 18),
          Text(
            activity.prompt,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 21,
              height: 1.35,
              fontWeight: FontWeight.w900,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ...activity.options.asMap().entries.map(
            (entry) => _buildAssessmentOption(
              activity: activity,
              optionIndex: entry.key,
              label: entry.value,
            ),
          ),
        ],
      ),
    );
  }

  bool _isAdvancedActivity(AssessmentGameType type) {
    return type == AssessmentGameType.selectMany ||
        type == AssessmentGameType.colorMix ||
        type == AssessmentGameType.coloring ||
        type == AssessmentGameType.speechPicture ||
        type == AssessmentGameType.balloonPop ||
        type == AssessmentGameType.conveyorSort ||
        type == AssessmentGameType.saladMaker ||
        type == AssessmentGameType.memoryReveal ||
        type == AssessmentGameType.songRepeat ||
        type == AssessmentGameType.shapeBalloons ||
        type == AssessmentGameType.traceShape ||
        type == AssessmentGameType.faceBuilder ||
        type == AssessmentGameType.bodyPartsBuilder ||
        type == AssessmentGameType.bodyPrivacyMarkers ||
        type == AssessmentGameType.sequenceTrain ||
        type == AssessmentGameType.puzzle ||
        type == AssessmentGameType.cameraIdentity ||
        type == AssessmentGameType.nameAndGender;
  }

  String _assessmentHint(AssessmentGameType type) {
    if (type == AssessmentGameType.dragToTarget ||
        type == AssessmentGameType.conveyorSort ||
        type == AssessmentGameType.saladMaker) {
      return 'اسحب العناصر للمكان المناسب 👆';
    }
    if (type == AssessmentGameType.coloring) {
      return 'اختار الفرشاة ولوّن الصور 🖌️';
    }
    if (type == AssessmentGameType.speechPicture) {
      return 'اسمع الكلمة ثم انطقها في الميكروفون 🎙️';
    }
    if (type == AssessmentGameType.balloonPop) {
      return 'فرقّع البالونة الصحيحة 🎈';
    }
    if (type == AssessmentGameType.memoryReveal) {
      return 'احفظ أماكن الكروت ثم اختر الحواس 🧠';
    }
    if (type == AssessmentGameType.songRepeat) {
      return 'ردد كلمات الاغنيه معايا 🎵';
    }
    if (type == AssessmentGameType.shapeBalloons) {
      return 'المس كل بالونة لتفرقعها 🎈';
    }
    if (type == AssessmentGameType.traceShape) {
      return 'حرّك القلم فوق الخط المنقّط ✏️';
    }
    if (type == AssessmentGameType.faceBuilder) {
      return 'اسحب كل جزء إلى مكانه في الوجه 🙂';
    }
    if (type == AssessmentGameType.bodyPartsBuilder) {
      return 'اسحب كل جزء إلى مكانه في الجسم 🧍‍♂️';
    }
    if (type == AssessmentGameType.bodyPrivacyMarkers) {
      return 'اسحب علامة الصح أو الخطأ إلى الدائرة المناسبة 🛡️';
    }
    if (type == AssessmentGameType.sequenceTrain) {
      return 'اختار الصور بالترتيب الصحيح 🚂';
    }
    if (type == AssessmentGameType.cameraIdentity) {
      return 'انظر للكاميرا وتعرف على نفسك 🪞';
    }
    if (type == AssessmentGameType.nameAndGender) {
      return 'سجل اسمك واختار نوعك 🎤';
    }
    return 'اختار الإجابة المناسبة 👆';
  }

  void _completeAdvancedActivity() {
    if (_answeredAssessment) return;
    _showAnswerReinforcement(true);
    setState(() {
      _answeredAssessment = true;
      _assessmentStars++;
    });
  }

  Widget _buildGenericDragGame(AssessmentActivityEntity activity) {
    final remainingOptions = activity.options.asMap().entries.where(
      (entry) => !_matchedAssessmentTargets.containsKey(entry.key),
    );

    return Column(
      children: [
        Text(
          activity.prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 21,
            height: 1.35,
            fontWeight: FontWeight.w900,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: activity.targets.asMap().entries.map((entry) {
                final matchedLabels = _matchedAssessmentTargets.entries
                    .where((matched) => matched.value == entry.key)
                    .map((matched) => activity.options[matched.key])
                    .toList();

                return _buildGenericTarget(
                  activity: activity,
                  targetIndex: entry.key,
                  label: entry.value,
                  matchedLabels: matchedLabels,
                );
              }).toList(),
            ),
          ),
        ),
        if (_wrongDragOptionIndex != null)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'قربت! جرب مكان تاني',
              style: TextStyle(
                color: Color(0xffD78300),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              final entry = remainingOptions.elementAt(index);
              final audioPath =
                  activity.audioPaths != null &&
                      activity.audioPaths!.length > entry.key
                  ? activity.audioPaths![entry.key]
                  : null;
              final imagePath =
                  activity.imagePaths != null &&
                      activity.imagePaths!.length > entry.key
                  ? activity.imagePaths![entry.key]
                  : null;
              return _buildDraggableAssessmentItem(
                optionIndex: entry.key,
                label: entry.value,
                audioPath: audioPath,
                imagePath: imagePath,
                audioOnly: activity.audioOnlyOptions,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: remainingOptions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableAssessmentItem({
    required int optionIndex,
    required String label,
    String? audioPath,
    String? imagePath,
    bool audioOnly = false,
  }) {
    final isWrong = _wrongDragOptionIndex == optionIndex;
    final color = _optionColor(optionIndex);
    final soundText = _soundTextForOption(label);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 126,
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isWrong ? Colors.red.shade50 : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isWrong ? Colors.redAccent : color, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (audioOnly)
                Icon(Icons.volume_up_rounded, color: color, size: 48)
              else if (imagePath != null && imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: 96,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Text(_optionEmoji(label), style: const TextStyle(fontSize: 34)),
              if (!audioOnly && (soundText != null || audioPath != null))
                const Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.textMid,
                    size: 18,
                  ),
                ),
            ],
          ),
          if (!audioOnly) ...[
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isWrong ? Colors.redAccent : color,
                  fontSize: 13,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Draggable<int>(
      data: optionIndex,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.04, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: card),
      child: GestureDetector(
        onTap: (audioPath != null)
            ? () => _playAssessmentSound(audioPath, fallbackText: label)
            : (soundText != null
                  ? () => _playAssessmentSound(soundText)
                  : null),
        child: card,
      ),
    );
  }

  Widget _buildGenericTarget({
    required AssessmentActivityEntity activity,
    required int targetIndex,
    required String label,
    required List<String> matchedLabels,
  }) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_answeredAssessment,
      onAcceptWithDetails: (details) =>
          _handleAssessmentDrop(activity, details.data, targetIndex),
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 160,
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHover
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHover ? AppColors.primary : Colors.grey.shade300,
              width: isHover ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGenericTargetVisual(
                activity: activity,
                targetIndex: targetIndex,
                label: label,
                matchedLabels: matchedLabels,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 16),
              if (matchedLabels.isEmpty)
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '؟',
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                )
              else if (activity.mergedTargetImagePaths != null)
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 38,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: matchedLabels.map((mLabel) {
                    final optionIndex = activity.options.indexOf(mLabel);
                    final color = _optionColor(optionIndex);
                    final optionImagePath =
                        activity.imagePaths != null &&
                            activity.imagePaths!.length > optionIndex &&
                            activity.imagePaths![optionIndex].isNotEmpty
                        ? activity.imagePaths![optionIndex]
                        : null;
                    final matchedImagePath =
                        optionImagePath ??
                        (activity.audioOnlyOptions &&
                                activity.targetImagePaths != null &&
                                activity.targetImagePaths!.length >
                                    targetIndex &&
                                activity
                                    .targetImagePaths![targetIndex]
                                    .isNotEmpty
                            ? activity.targetImagePaths![targetIndex]
                            : null);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (matchedImagePath != null)
                            Image.asset(
                              matchedImagePath,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            )
                          else
                            Text(
                              _optionEmoji(mLabel),
                              style: const TextStyle(fontSize: 24),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            mLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenericTargetVisual({
    required AssessmentActivityEntity activity,
    required int targetIndex,
    required String label,
    required List<String> matchedLabels,
  }) {
    final targetImagePath =
        activity.targetImagePaths != null &&
            activity.targetImagePaths!.length > targetIndex &&
            activity.targetImagePaths![targetIndex].isNotEmpty
        ? activity.targetImagePaths![targetIndex]
        : null;
    final mergedImagePath =
        matchedLabels.isNotEmpty &&
            activity.mergedTargetImagePaths != null &&
            activity.mergedTargetImagePaths!.length > targetIndex &&
            activity.mergedTargetImagePaths![targetIndex].isNotEmpty
        ? activity.mergedTargetImagePaths![targetIndex]
        : null;

    if (mergedImagePath != null) {
      return Image.asset(
        mergedImagePath,
        width: 112,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    if (matchedLabels.isNotEmpty && targetImagePath != null) {
      final optionIndex = activity.options.indexOf(matchedLabels.first);
      final childImagePath =
          optionIndex >= 0 &&
              activity.imagePaths != null &&
              activity.imagePaths!.length > optionIndex &&
              activity.imagePaths![optionIndex].isNotEmpty
          ? activity.imagePaths![optionIndex]
          : null;
      if (childImagePath != null) {
        return SizedBox(
          width: 120,
          height: 90,
          child: Row(
            children: [
              Expanded(
                child: Image.asset(targetImagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 4),
              Expanded(child: Image.asset(childImagePath, fit: BoxFit.contain)),
            ],
          ),
        );
      }
    }

    if (targetImagePath != null) {
      return Image.asset(
        targetImagePath,
        width: 72,
        height: 72,
        fit: BoxFit.contain,
      );
    }

    return Text(
      _targetEmoji(label, targetIndex),
      style: const TextStyle(fontSize: 48),
    );
  }

  Color _optionColor(int index) {
    const colors = [
      AppColors.blue,
      Color(0xffE91E63),
      Color(0xff795548),
      Color(0xff607D8B),
      AppColors.secondary,
    ];
    return colors[index % colors.length];
  }

  String _optionEmoji(String label) {
    if (label.contains('فستان')) return '👗';
    if (label.contains('شعر')) return '💇';
    if (label.contains('قميص')) return '👔';
    if (label.contains('طعام') || label.contains('ترتيب')) return '🏠';
    if (label.contains('طائرة') || label.contains('الطيار')) return '✈️';
    if (label.contains('إطفاء') || label.contains('المطافي')) return '🚒';
    if (label.contains('مياو') ||
        label.contains('موو') ||
        label.contains('كوكو') ||
        label.contains('ماااع')) {
      return '📢';
    }
    if (label.contains('قط')) return '🐱';
    if (label.contains('عجل')) return '🐄';
    if (label.contains('كتكوت')) return '🐔';
    if (label.contains('ماعز') || label.contains('جدي')) {
      return '🐐';
    }
    if (label.contains('سيارة') || label.contains('السائق')) return '🚗';
    if (label.contains('مركب') || label.contains('البحار')) return '⛵';
    if (label.contains('إسعاف') || label.contains('المسعف')) return '🚑';
    if (label.contains('الأنف')) return '👃';
    if (label.contains('العين')) return '👁️';
    if (label.contains('اليد')) return '✋';
    if (label.contains('الوجه')) return '🙂';
    if (label.contains('فرشاة')) return '🪥';
    if (label.contains('الملعقة')) return '🥄';
    if (label.contains('الشامبو')) return '🧴';
    if (label.contains('الطبق') || label.contains('طعام')) return '🍽️';
    if (label.contains('نوم')) return '🛏️';
    if (label.contains('طائرة')) return '✈️';
    if (label.contains('حريق')) return '🚒';
    if (label.contains('أم')) return '👩';
    if (label.contains('عمل')) return '💼';
    if (label.contains('الخاصة')) return '🛡️';
    if (label.contains('أحمر')) return '🔴';
    if (label.contains('أصفر')) return '🟡';
    if (label.contains('أزرق')) return '🔵';
    if (label.contains('أخضر')) return '🟢';
    if (label.contains('برتقالي')) return '🟠';
    if (label.contains('بنفسجي')) return '🟣';
    if (label.contains('الأنف')) return '👃';
    if (label.contains('العين')) return '👁️';
    if (label.contains('✔') || label.contains('مكان خاص')) return '✔️';
    if (label.contains('✖') || label.contains('ليس')) return '✖️';
    return '🧩';
  }

  String? _soundTextForOption(String label) {
    if (label == 'مياو') return 'مياااو، أنا القطة';
    if (label == 'موو') return 'موووو، أنا البقرة';
    if (label == 'كوكو') return 'كوكو كوكو، أنا الدجاجة';
    if (label == 'ماااع') return 'ماااع، أنا الماعز';
    return null;
  }

  Future<void> _playAssessmentSound(
    String textOrPath, {
    String? fallbackText,
  }) async {
    if (textOrPath.endsWith('.ogg') ||
        textOrPath.endsWith('.mp3') ||
        textOrPath.endsWith('.m4a')) {
      try {
        await AudioOutputService.playAsset(_audioPlayer, textOrPath);
      } catch (error) {
        debugPrint('Error playing assessment audio: $error');
        if (fallbackText != null && mounted) {
          await context.read<SpeechService>().speak(fallbackText);
        }
      }
    } else {
      await context.read<SpeechService>().speak(textOrPath);
    }
  }

  String _targetEmoji(String label, int index) {
    if (label.contains('الأم')) return '👩';
    if (label.contains('الأسرة')) return '❓';
    if (label.contains('قطة')) return '🐱';
    if (label.contains('بقرة')) return '🐄';
    if (label.contains('دجاج')) return '🐔';
    if (label.contains('ماعز')) return '🐐';
    if (label.contains('الطريق') || label.contains('سيارة')) return '🚗';
    if (label.contains('السماء') || label.contains('طائرة')) return '✈️';
    if (label.contains('البحر') || label.contains('مركب')) return '⛵';
    if (label.contains('المريض') || label.contains('الإسعاف')) return '🚑';
    if (label.contains('الحريق') || label.contains('الإطفاء')) return '🚒';
    if (label.contains('أساسية')) return '🎨';
    if (label.contains('ثانوي') || label.contains('ناتج')) return '🌈';
    if (label.contains('برتقالي')) return '🟠';
    if (label.contains('أخضر')) return '🟢';
    if (label.contains('بنفسجي')) return '🟣';
    if (label.contains('أنا')) return '🪞';
    if (label.contains('مطبخ') || label.contains('طعام')) return '🍽️';
    if (label.contains('حمام')) return '🛁';
    if (label.contains('أم')) return '👩';
    if (label.contains('عمل') || label.contains('آخر')) return '🚪';
    return index.isEven ? '🙂' : '⭐';
  }

  Widget _buildAssessmentOption({
    required AssessmentActivityEntity activity,
    required int optionIndex,
    required String label,
  }) {
    final isSelected = _selectedOptionIndex == optionIndex;
    final isCorrect = activity.correctOptionIndex == optionIndex;
    final isReflective = activity.correctOptionIndex == null;

    Color borderColor = Colors.white;
    Color backgroundColor = Colors.white.withValues(alpha: 0.82);
    Color textColor = AppColors.textDark;
    IconData icon = Icons.touch_app_rounded;
    Color iconColor = AppColors.textMid;

    if (_answeredAssessment && isSelected) {
      final answeredCorrect = isReflective || isCorrect;
      borderColor = answeredCorrect
          ? const Color(0xff4ECE6C)
          : Colors.redAccent;
      backgroundColor = (answeredCorrect ? const Color(0xff4ECE6C) : Colors.red)
          .withValues(alpha: 0.18);
      icon = answeredCorrect
          ? Icons.check_circle_rounded
          : Icons.refresh_rounded;
      iconColor = answeredCorrect ? const Color(0xff4ECE6C) : Colors.redAccent;
      textColor = answeredCorrect ? const Color(0xff2E7D32) : Colors.redAccent;
    } else if (_answeredAssessment && isCorrect) {
      borderColor = const Color(0xff4ECE6C);
      backgroundColor = const Color(0xff4ECE6C).withValues(alpha: 0.12);
      icon = Icons.star_rounded;
      iconColor = const Color(0xff4ECE6C);
      textColor = const Color(0xff2E7D32);
    }

    return GestureDetector(
      onTap: _answeredAssessment
          ? null
          : () => _selectAssessmentOption(activity, optionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentFeedback(AssessmentActivityEntity activity) {
    final isReflective = activity.correctOptionIndex == null;
    final isCorrect =
        _isAdvancedActivity(activity.type) ||
        isReflective ||
        _selectedOptionIndex == activity.correctOptionIndex;
    const rewards = ['⭐', '🏆', '🎉', '👏', '🌟', '🎁'];
    final reward = rewards[(_assessmentStars - 1).clamp(0, rewards.length - 1)];
    final text = isCorrect
        ? '$reward ${activity.successMessage}'
        : 'قربت! بص على الكارت الصح وجرب تفتكره.';
    final color = isCorrect ? const Color(0xff4ECE6C) : const Color(0xffFFB74D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w900,
          fontFamily: 'Tajawal',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _selectAssessmentOption(
    AssessmentActivityEntity activity,
    int optionIndex,
  ) async {
    final label = activity.options[optionIndex];

    if (label == 'افتح الكاميرا') {
      try {
        await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );
      } catch (e) {
        debugPrint('Camera error: $e');
      }
      return;
    }

    bool isCorrect =
        activity.correctOptionIndex == null ||
        activity.correctOptionIndex == optionIndex;

    // Custom feeling logic: if it's a negative feeling, don't treat it as "correct" for the reinforcement sound/animation.
    bool isNegativeFeeling = false;
    if (activity.correctOptionIndex == null) {
      final label = activity.options[optionIndex];
      if (label.contains('لا') ||
          label.contains('قليلاً') ||
          label.contains('أريد المحاولة') ||
          label.contains('صعبة') ||
          label.contains('مساعدة') ||
          label.contains('لم أستمتع') ||
          label.contains('لم استمتع')) {
        isNegativeFeeling = true;
      }
    }

    setState(() {
      _selectedOptionIndex = optionIndex;
      _answeredAssessment = true;
      if (isCorrect) {
        _assessmentStars++;
      }
    });

    _showAnswerReinforcement(isCorrect, isNegativeFeeling: isNegativeFeeling);
  }

  void _handleAssessmentDrop(
    AssessmentActivityEntity activity,
    int optionIndex,
    int targetIndex,
  ) {
    final correctTargetIndex = activity.correctTargetIndexes[optionIndex];

    if (targetIndex == correctTargetIndex) {
      _showAnswerReinforcement(true);
      setState(() {
        _wrongDragOptionIndex = null;
        _matchedAssessmentTargets[optionIndex] = targetIndex;

        if (_matchedAssessmentTargets.length == activity.options.length) {
          _answeredAssessment = true;
          _assessmentStars++;
        }
      });
      return;
    }

    _showAnswerReinforcement(false);
    setState(() {
      _wrongDragOptionIndex = optionIndex;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted && _wrongDragOptionIndex == optionIndex) {
        setState(() {
          _wrongDragOptionIndex = null;
        });
      }
    });
  }

  void _goToNextAssessment() {
    setState(() {
      _currentAssessmentIndex++;
      _selectedOptionIndex = null;
      _answeredAssessment = false;
      _matchedAssessmentTargets.clear();
      _wrongDragOptionIndex = null;
    });
  }

  Widget _buildErrorState() {
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'حدث خطأ أثناء تشغيل الفيديو',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Btn3D(
            color: AppColors.primary,
            shadowColor: AppColors.primaryShadow,
            height: 44,
            onPressed: _navigateToGame,
            child: const Text(
              'الذهاب للعب مباشرة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final double maxDuration = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final double currentPosition = position.inMilliseconds.toDouble().clamp(
      0.0,
      maxDuration,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: Color(0xffFF9800),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Color(0xffFF9800),
                  ),
                  child: Slider(
                    min: 0,
                    max: maxDuration,
                    value: currentPosition,
                    onChanged: (value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  final newPosition = position - const Duration(seconds: 10);
                  _controller.seekTo(
                    newPosition < Duration.zero ? Duration.zero : newPosition,
                  );
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF9800),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  final newPosition = position + const Duration(seconds: 10);
                  _controller.seekTo(
                    newPosition > duration ? duration : newPosition,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
