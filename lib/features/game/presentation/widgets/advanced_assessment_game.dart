import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/services/audio_output_service.dart';
import '../../../../core/services/speech_result_guard.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../map/domain/entities/level_entity.dart';
import '../pages/song_video_player_page.dart';

class AdvancedAssessmentGame extends StatefulWidget {
  final AssessmentActivityEntity activity;
  final SpeechService speechService;
  final VoidCallback onCompleted;
  final VoidCallback? onCorrectStep;
  final VoidCallback? onIncorrect;

  const AdvancedAssessmentGame({
    super.key,
    required this.activity,
    required this.speechService,
    required this.onCompleted,
    this.onCorrectStep,
    this.onIncorrect,
  });

  @override
  State<AdvancedAssessmentGame> createState() => _AdvancedAssessmentGameState();
}

class _AdvancedAssessmentGameState extends State<AdvancedAssessmentGame>
    with WidgetsBindingObserver {
  final Set<int> _selected = {};
  final Set<int> _spokenCorrectly = {};
  final Map<int, int> _paintedTargets = {};
  final Map<int, int> _sortedTargets = {};
  final Map<int, int> _privacyMarkers = {};
  final List<int> _sequencePlaced = [];
  final List<Offset> _tracePoints = [];
  final Set<int> _traceEdges = {};
  final AudioPlayer _wordPlayer = AudioPlayer();
  final Map<int, VideoPlayerController> _shapeBalloonControllers = {};
  late final List<int> _memoryOrder;
  late final List<int> _sequenceOrder;
  Timer? _memoryTimer;
  int? _paintColorIndex;
  int? _activeSpeechIndex;
  int? _wrongIndex;
  bool _listening = false;
  final SpeechResultGuard _speechResultGuard = SpeechResultGuard();
  bool _completed = false;
  bool _memoryHidden = false;
  String _message = '';

  AssessmentActivityEntity get activity => widget.activity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _memoryOrder = List.generate(activity.options.length, (index) => index)
      ..shuffle();
    _sequenceOrder = List.generate(activity.options.length, (index) => index)
      ..shuffle();
    if (activity.type == AssessmentGameType.memoryReveal) {
      _memoryTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _memoryHidden = true);
      });
    }
    if (activity.type == AssessmentGameType.shapeBalloons) {
      unawaited(_initializeShapeBalloonVideos());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _memoryTimer?.cancel();
    _wordPlayer.stop();
    _wordPlayer.dispose();
    for (final controller in _shapeBalloonControllers.values) {
      unawaited(controller.dispose());
    }
    if (_listening) {
      widget.speechService.stopListening();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      for (final entry in _shapeBalloonControllers.entries) {
        if (!_selected.contains(entry.key) && entry.value.value.isInitialized) {
          unawaited(entry.value.play());
        }
      }
      return;
    }

    final shouldStop =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (!shouldStop) return;

    _speechResultGuard.cancel();
    _listening = false;
    unawaited(_wordPlayer.stop());
    unawaited(widget.speechService.stopSpeaking());
    unawaited(widget.speechService.stopListening());
    for (final controller in _shapeBalloonControllers.values) {
      unawaited(controller.pause());
    }
  }

  Future<void> _initializeShapeBalloonVideos() async {
    final paths = activity.videoPaths;
    if (paths == null || paths.isEmpty) return;

    await Future.wait(
      paths.asMap().entries.map((entry) async {
        final controller = VideoPlayerController.asset(entry.value);
        _shapeBalloonControllers[entry.key] = controller;
        try {
          await controller.initialize();
          await controller.setLooping(true);
          await controller.setVolume(0);
          if (mounted) await controller.play();
        } catch (_) {
          _shapeBalloonControllers.remove(entry.key);
          await controller.dispose();
        }
      }),
    );

    if (mounted) setState(() {});
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 16),
        Expanded(
          child: switch (activity.type) {
            AssessmentGameType.selectMany => _buildSelectMany(),
            AssessmentGameType.colorMix => _buildColorMix(),
            AssessmentGameType.coloring => _buildColoring(),
            AssessmentGameType.speechPicture => _buildSpeechPicture(),
            AssessmentGameType.balloonPop => _buildBalloonPop(),
            AssessmentGameType.conveyorSort => _buildSorter(false),
            AssessmentGameType.saladMaker => _buildSorter(true),
            AssessmentGameType.memoryReveal => _buildMemoryReveal(),
            AssessmentGameType.songRepeat => _buildSongRepeat(),
            AssessmentGameType.shapeBalloons => _buildShapeBalloons(),
            AssessmentGameType.traceShape => _buildTraceShape(),
            AssessmentGameType.faceBuilder => _buildFaceBuilder(),
            AssessmentGameType.bodyPartsBuilder => _buildBodyPartsBuilder(),
            AssessmentGameType.bodyPrivacyMarkers => _buildBodyPrivacyMarkers(),
            AssessmentGameType.sequenceTrain => _buildSequenceTrain(),
            AssessmentGameType.puzzle => _buildPuzzle(),
            AssessmentGameType.cameraIdentity => _buildCameraIdentity(),
            AssessmentGameType.nameAndGender => _buildNameAndGender(),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  Widget _buildSelectMany() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: activity.options.asMap().entries.map((entry) {
              final selected = _selected.contains(entry.key);
              return GestureDetector(
                onTap: _completed
                    ? null
                    : () => setState(() {
                        selected
                            ? _selected.remove(entry.key)
                            : _selected.add(entry.key);
                        _message = '';
                        widget.speechService.speak(entry.value);
                      }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 132,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? _colorAt(entry.key).withValues(alpha: .2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected ? _colorAt(entry.key) : Colors.white,
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
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: _colorAt(entry.key),
                          shape: BoxShape.circle,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _actionButton('تأكد من الألوان', () {
            final correct = activity.correctOptionIndexes.toSet();
            if (_selected.length == correct.length &&
                _selected.containsAll(correct)) {
              _finish();
            } else {
              widget.onIncorrect?.call();
              setState(() {
                _message = 'جرّب مرة تانية واختار ٣ ألوان فقط 🎨';
                _selected.clear();
              });
            }
          }),
          if (_message.isNotEmpty) _statusText(_message),
        ],
      ),
    );
  }

  Widget _buildColorMix() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _mixCircle(_colorAt(0)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                ),
              ),
              _mixCircle(_colorAt(1)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '=',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: _completed && activity.correctOptionIndex != null
                      ? _colorAt(activity.correctOptionIndex! + 2)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 3),
                ),
                alignment: Alignment.center,
                child: _completed
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : const Text('؟', style: TextStyle(fontSize: 30)),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'اختار الفرشاة الصحيحة',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            children: activity.options.asMap().entries.map((entry) {
              final color = _colorAt(entry.key + 2);
              return GestureDetector(
                onTap: _completed
                    ? null
                    : () {
                        widget.speechService.speak(entry.value);
                        if (entry.key == activity.correctOptionIndex) {
                          setState(() => _message = '');
                          _finish();
                        } else {
                          widget.onIncorrect?.call();
                          setState(() {
                            _wrongIndex = entry.key;
                            _message = 'قريب! جرّب الفرشاة التانية';
                          });
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _wrongIndex == entry.key
                        ? Colors.red.shade50
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _wrongIndex == entry.key ? Colors.red : color,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.brush_rounded, color: color, size: 44),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_message.isNotEmpty) _statusText(_message),
        ],
      ),
    );
  }

  Widget _buildColoring() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: activity.targets.asMap().entries.map((entry) {
              final paintIndex = _paintedTargets[entry.key];
              final imagePath =
                  activity.targetImagePaths != null &&
                      activity.targetImagePaths!.length > entry.key &&
                      activity.targetImagePaths![entry.key].isNotEmpty
                  ? activity.targetImagePaths![entry.key]
                  : null;
              return GestureDetector(
                onTap: _completed || _paintColorIndex == null
                    ? null
                    : () {
                        bool isCorrect = false;

                        // Check if targets are generic (e.g., 'دائرة ١', 'دائرة ٢')
                        bool isGeneric =
                            activity.targets.isNotEmpty &&
                            activity.targets.every((t) => t.contains('دائرة'));

                        if (isGeneric) {
                          // Valid colors are the first 'targets.length' colors in options.
                          if (_paintColorIndex! < activity.targets.length) {
                            // Ensure this color hasn't been used on another circle yet
                            final alreadyUsed = _paintedTargets.entries.any(
                              (e) =>
                                  e.value == _paintColorIndex! &&
                                  e.key != entry.key,
                            );
                            if (!alreadyUsed) {
                              isCorrect = true;
                            }
                          }
                        } else {
                          // For specific targets (like fruits), the color index must match target index.
                          isCorrect = _paintColorIndex == entry.key;
                        }

                        if (isCorrect) {
                          setState(() {
                            _paintedTargets[entry.key] = _paintColorIndex!;
                            _wrongIndex = null;
                          });
                          widget.onCorrectStep?.call();
                          if (_paintedTargets.length ==
                              activity.targets.length) {
                            _finish();
                          }
                        } else {
                          widget.onIncorrect?.call();
                          setState(() => _wrongIndex = _paintColorIndex);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: imagePath == null ? 126 : 154,
                  height: imagePath == null ? 126 : 164,
                  decoration: BoxDecoration(
                    color: paintIndex == null
                        ? Colors.white
                        : _colorAt(paintIndex).withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: paintIndex == null
                          ? Colors.grey.shade300
                          : _colorAt(paintIndex),
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (imagePath != null)
                        if (paintIndex == null)
                          Image.asset(
                            imagePath,
                            width: 116,
                            height: 110,
                            fit: BoxFit.contain,
                          )
                        else
                          imagePath.contains('uncolored_')
                              ? Image.asset(
                                  imagePath
                                      .replaceFirst('uncolored_', 'colored_')
                                      .replaceFirst('.jpg', '_game.jpg'),
                                  width: 116,
                                  height: 110,
                                  fit: BoxFit.contain,
                                )
                              : ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    _colorAt(paintIndex),
                                    BlendMode.modulate,
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    width: 116,
                                    height: 110,
                                    fit: BoxFit.contain,
                                  ),
                                )
                      else
                        Text(
                          _itemEmoji(entry.value),
                          style: const TextStyle(fontSize: 52),
                        ),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            children: activity.options.asMap().entries.map((entry) {
              final selected = _paintColorIndex == entry.key;
              return GestureDetector(
                onTap: _completed
                    ? null
                    : () {
                        setState(() => _paintColorIndex = entry.key);
                        widget.speechService.speak(entry.value);
                      },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _colorAt(entry.key),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _colorAt(entry.key),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(Icons.brush, color: Colors.white),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'اختار لونًا ثم المس الصورة 🖌️',
            style: TextStyle(
              color: AppColors.textMid,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechPicture() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: activity.options.asMap().entries.map((entry) {
              final done = _spokenCorrectly.contains(entry.key);
              final active = _activeSpeechIndex == entry.key;
              return Container(
                width: 145,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: done
                      ? Colors.green.withValues(alpha: .14)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: done
                        ? Colors.green
                        : active
                        ? AppColors.blue
                        : Colors.white,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Column(
                  children: [
                    if (activity.imagePaths != null &&
                        activity.imagePaths!.length > entry.key &&
                        activity.imagePaths![entry.key].isNotEmpty)
                      Image.asset(
                        activity.imagePaths![entry.key],
                        width: 82,
                        height: 72,
                        fit: BoxFit.contain,
                      )
                    else
                      Text(
                        _itemEmoji(entry.value),
                        style: const TextStyle(fontSize: 58),
                      ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'اسمع الكلمة',
                          onPressed: _listening
                              ? null
                              : () => _playWord(entry.key, entry.value),
                          icon: const Icon(Icons.volume_up_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: 'انطق الكلمة',
                          onPressed: done || _listening
                              ? null
                              : () => _listenFor(entry.key),
                          icon: Icon(done ? Icons.check : Icons.mic_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (_listening) ...[
            const SizedBox(height: 18),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'أنا سامعك... انطق اسم الفاكهة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
          if (_message.isNotEmpty) _statusText(_message),
        ],
      ),
    );
  }

  Future<void> _playWord(int index, String fallbackWord) async {
    await widget.speechService.stopSpeaking();

    final paths = activity.audioPaths;
    if (paths == null || index >= paths.length || paths[index].isEmpty) {
      await widget.speechService.speak(fallbackWord);
      return;
    }

    try {
      await AudioOutputService.playAsset(_wordPlayer, paths[index]);
    } catch (error) {
      debugPrint('Error playing word audio: $error');
      await widget.speechService.speak(fallbackWord);
    }
  }

  Future<void> _listenFor(int index) async {
    if (_listening || _completed || _spokenCorrectly.contains(index)) return;

    await _wordPlayer.stop();
    await widget.speechService.stopSpeaking();
    if (!mounted) return;
    final attemptId = _speechResultGuard.beginAttempt();
    setState(() {
      _activeSpeechIndex = index;
      _listening = true;
      _message = '';
    });
    final started = await widget.speechService.startListening(
      onResult: (results) {
        if (!mounted ||
            results.isEmpty ||
            !_speechResultGuard.claim(attemptId)) {
          return;
        }
        unawaited(widget.speechService.stopListening());
        final expected = _normalize(activity.options[index]);
        final heard = _normalize(results.first);
        final correct = heard.contains(expected) || expected.contains(heard);
        final newlyCorrect = correct && _spokenCorrectly.add(index);
        setState(() {
          _listening = false;
          if (correct) {
            _message = 'سمعتك صح! ممتاز 👏';
          } else {
            _message = 'سمعت «${results.first}»… اسمع الكلمة وحاول تاني';
          }
        });
        if (newlyCorrect) {
          widget.onCorrectStep?.call();
        } else if (!correct) {
          widget.onIncorrect?.call();
        }
        if (correct && _spokenCorrectly.length == activity.options.length) {
          _finish();
        }
      },
      onError: (_) {
        if (!mounted || !_speechResultGuard.claim(attemptId)) {
          return;
        }
        widget.onIncorrect?.call();
        setState(() {
          _listening = false;
          _message = 'الميكروفون غير متاح الآن، حاول مرة تانية';
        });
      },
    );
    if (!started && mounted && _speechResultGuard.claim(attemptId)) {
      setState(() => _listening = false);
    }
  }

  Widget _buildBalloonPop() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: activity.options.asMap().entries.map((entry) {
          final popped = _selected.contains(entry.key);
          return GestureDetector(
            onTap: _completed || popped
                ? null
                : () {
                    setState(() => _selected.add(entry.key));
                    if (entry.key == activity.correctOptionIndex) {
                      _finish();
                    } else {
                      widget.onIncorrect?.call();
                      setState(
                        () =>
                            _message = 'بوب! دي مش الإجابة… جرّب بالونة تانية',
                      );
                    }
                  },
            child: AnimatedScale(
              scale: popped ? 0 : 1,
              duration: const Duration(milliseconds: 260),
              child: _FloatingWidget(
                index: entry.key,
                child: SizedBox(
                  width: 130,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Text('│', style: TextStyle(fontSize: 32)),
                      ),
                      Positioned(
                        top: 0,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            _colorAt(entry.key),
                            BlendMode.modulate,
                          ),
                          child: Image.asset(
                            'assets/image/balloon.png',
                            width: 120,
                            height: 140,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSorter(bool saladMaker) {
    final remaining = activity.options.asMap().entries.where(
      (entry) => !_sortedTargets.containsKey(entry.key),
    );
    return Column(
      children: [
        Row(
          children: activity.targets.asMap().entries.map((target) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    final optionIndex = details.data;
                    if (activity.correctTargetIndexes[optionIndex] ==
                        target.key) {
                      setState(() {
                        _wrongIndex = null;
                        _sortedTargets[optionIndex] = target.key;
                      });
                      widget.onCorrectStep?.call();
                      if (_sortedTargets.length == activity.options.length) {
                        _finish();
                      }
                    } else {
                      widget.onIncorrect?.call();
                      setState(() => _wrongIndex = optionIndex);
                    }
                  },
                  builder: (context, candidates, rejects) {
                    final count = _sortedTargets.values
                        .where((value) => value == target.key)
                        .length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 142,
                      decoration: BoxDecoration(
                        color: candidates.isNotEmpty
                            ? Colors.green.withValues(alpha: .18)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: candidates.isNotEmpty
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (activity.targetImagePaths != null &&
                              activity.targetImagePaths!.length > target.key &&
                              activity.targetImagePaths![target.key].isNotEmpty)
                            Image.asset(
                              activity.targetImagePaths![target.key],
                              width: 60,
                              height: 60,
                            )
                          else
                            Text(
                              target.key == 0
                                  ? saladMaker
                                        ? '🥗'
                                        : '🍽️'
                                  : '✖️',
                              style: const TextStyle(fontSize: 52),
                            ),
                          Text(
                            target.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          Text('$count'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade600, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              15,
              (index) => Container(width: 4, color: Colors.grey.shade600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: remaining.map((entry) {
                final card = Container(
                  width: 88,
                  height: 88,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _wrongIndex == entry.key
                        ? Colors.red.shade50
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _wrongIndex == entry.key
                          ? Colors.red
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (activity.imagePaths != null &&
                          activity.imagePaths!.length > entry.key &&
                          activity.imagePaths![entry.key].isNotEmpty)
                        Image.asset(
                          activity.imagePaths![entry.key],
                          width: 45,
                          height: 45,
                        )
                      else
                        Text(
                          _itemEmoji(entry.value),
                          style: const TextStyle(fontSize: 35),
                        ),
                      Text(
                        entry.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                );
                return Draggable<int>(
                  data: entry.key,
                  feedback: Material(color: Colors.transparent, child: card),
                  childWhenDragging: Opacity(opacity: .2, child: card),
                  child: card,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryReveal() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _memoryHidden
                ? 'اختار أماكن الحواس الخمس من ذاكرتك'
                : 'احفظ أماكن الكروت… ستختفي بعد ٥ ثوانٍ',
            key: ValueKey(_memoryHidden),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _memoryHidden ? AppColors.textDark : AppColors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .86,
            ),
            itemCount: _memoryOrder.length,
            itemBuilder: (context, position) {
              final optionIndex = _memoryOrder[position];
              final selected = _selected.contains(optionIndex);
              final wrong = _wrongIndex == optionIndex;
              final showFace = !_memoryHidden || selected || wrong;
              return GestureDetector(
                onTap: !_memoryHidden || _completed || selected
                    ? null
                    : () => _selectMemoryCard(optionIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  decoration: BoxDecoration(
                    gradient: showFace
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xff5C6BC0), Color(0xff26A69A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: showFace
                        ? wrong
                              ? Colors.red.shade50
                              : selected
                              ? Colors.green.shade50
                              : Colors.white
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: wrong
                          ? Colors.red
                          : selected
                          ? Colors.green
                          : Colors.white,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: showFace
                        ? Column(
                            key: ValueKey('face-$optionIndex'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              activity.imagePaths != null &&
                                      activity.imagePaths!.length >
                                          optionIndex &&
                                      activity
                                          .imagePaths![optionIndex]
                                          .isNotEmpty
                                  ? Image.asset(
                                      activity.imagePaths![optionIndex],
                                      height: 52,
                                      fit: BoxFit.contain,
                                    )
                                  : Text(
                                      _itemEmoji(activity.options[optionIndex]),
                                      style: const TextStyle(fontSize: 42),
                                    ),
                              const SizedBox(height: 5),
                              Text(
                                activity.options[optionIndex],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.question_mark_rounded,
                            key: ValueKey('back'),
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_message.isNotEmpty) _statusText(_message),
      ],
    );
  }

  void _selectMemoryCard(int optionIndex) {
    if (activity.correctOptionIndexes.contains(optionIndex)) {
      widget.onCorrectStep?.call();
      setState(() {
        _selected.add(optionIndex);
        _message = 'أحسنت! وجدت حاسة 👏';
      });
      if (_selected.length == activity.correctOptionIndexes.length) {
        _finish();
      }
      return;
    }

    widget.onIncorrect?.call();
    setState(() {
      _wrongIndex = optionIndex;
      _message = 'هذه ليست من الحواس الخمس… تذكّر مكانًا آخر';
    });
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted && _wrongIndex == optionIndex) {
        setState(() => _wrongIndex = null);
      }
    });
  }

  Widget _buildSongRepeat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 290,
            child: ElevatedButton.icon(
              onPressed: activity.videoUrl == null
                  ? null
                  : () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SongVideoPlayerPage(
                            videoPath: activity.videoUrl!,
                          ),
                        ),
                      );
                      if (!mounted || result != true) return;

                      const praises = ['برافو!', 'أحسنت!', 'شاطر!'];
                      final praise =
                          praises[DateTime.now().millisecond % praises.length];
                      setState(() => _message = praise);
                      unawaited(widget.speechService.speak(praise));
                      _finish();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 30),
              label: const Text(
                'مشاهدة الأغنية فيديو',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 24),
            _statusText(_message),
          ],
        ],
      ),
    );
  }

  Widget _buildShapeBalloons() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: activity.options.asMap().entries.map((entry) {
              final popped = _selected.contains(entry.key);
              return GestureDetector(
                onTap: popped || _completed
                    ? null
                    : () {
                        final controller = _shapeBalloonControllers[entry.key];
                        if (controller != null) {
                          unawaited(controller.pause());
                        }
                        setState(() => _selected.add(entry.key));
                        widget.onCorrectStep?.call();
                        if (_selected.length == activity.options.length) {
                          _finish();
                        }
                      },
                child: AnimatedScale(
                  scale: popped ? 0 : 1,
                  duration: const Duration(milliseconds: 260),
                  child: _buildShapeBalloonTile(entry.key, entry.value),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'فرقّعت ${_selected.length} من ${activity.options.length}',
            style: const TextStyle(
              color: AppColors.textMid,
              fontWeight: FontWeight.w900,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeBalloonTile(int index, String label) {
    final controller = _shapeBalloonControllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return SizedBox(
        width: 138,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.circle, color: _colorAt(index), size: 128),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _build3DShape(label),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              child: Text('│', style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      );
    }

    final videoSize = controller.value.size;
    return SizedBox(
      width: 138,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ColoredBox(
                color: Colors.white,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: videoSize.width,
                    height: videoSize.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceShape() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: GestureDetector(
              onPanStart: (details) => _traceAt(details.localPosition),
              onPanUpdate: (details) => _traceAt(details.localPosition),
              onPanEnd: (_) {
                if (_traceEdges.length == 4) {
                  _finish();
                } else {
                  setState(() {
                    _message =
                        'مرّر القلم على الأضلاع الأربعة — أكملت ${_traceEdges.length}';
                  });
                }
              },
              child: CustomPaint(
                size: const Size(270, 270),
                painter: _ShapeTracePainter(
                  points: _tracePoints,
                  completedEdges: _traceEdges,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  _traceEdges.contains(index)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _traceEdges.contains(index)
                      ? Colors.amber
                      : Colors.grey,
                  size: 30,
                ),
              ),
            ),
          ),
          if (_message.isNotEmpty) _statusText(_message),
        ],
      ),
    );
  }

  void _traceAt(Offset point) {
    const min = 35.0;
    const max = 235.0;
    const tolerance = 25.0;
    final newlyCompleted = <int>{};
    if ((point.dy - min).abs() < tolerance &&
        point.dx >= min &&
        point.dx <= max) {
      newlyCompleted.add(0);
    }
    if ((point.dx - max).abs() < tolerance &&
        point.dy >= min &&
        point.dy <= max) {
      newlyCompleted.add(1);
    }
    if ((point.dy - max).abs() < tolerance &&
        point.dx >= min &&
        point.dx <= max) {
      newlyCompleted.add(2);
    }
    if ((point.dx - min).abs() < tolerance &&
        point.dy >= min &&
        point.dy <= max) {
      newlyCompleted.add(3);
    }
    final oldCount = _traceEdges.length;
    setState(() {
      _tracePoints.add(point);
      _traceEdges.addAll(newlyCompleted);
      _message = '';
    });
    if (_traceEdges.length > oldCount) {
      widget.onCorrectStep?.call();
    }
  }

  Widget _buildFaceBuilder() {
    final remaining = activity.options.asMap().entries.where(
      (entry) => !_sortedTargets.containsKey(entry.key),
    );
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SizedBox(
              width: 290,
              height: 285,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 205,
                    height: 245,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFD5B5),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color(0xffC68B64),
                        width: 3,
                      ),
                    ),
                  ),
                  _faceTarget(0, const Offset(0, -90)), // Hair (lowered)
                  _faceTarget(4, const Offset(0, -15)), // Ears
                  _faceTarget(3, const Offset(0, -35)), // Eyes
                  _faceTarget(1, const Offset(0, 15)), // Nose
                  _faceTarget(2, const Offset(0, 65)), // Mouth
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: remaining.map((entry) {
            final card = Container(
              width: 82,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.blue, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (activity.imagePaths != null &&
                      activity.imagePaths!.length > entry.key &&
                      activity.imagePaths![entry.key].isNotEmpty)
                    Image.asset(
                      activity.imagePaths![entry.key],
                      width: 38,
                      height: 38,
                    )
                  else
                    Text(
                      _facePartEmoji(entry.key),
                      style: const TextStyle(fontSize: 28),
                    ),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            );
            return Draggable<int>(
              data: entry.key,
              feedback: Material(color: Colors.transparent, child: card),
              childWhenDragging: Opacity(opacity: .25, child: card),
              child: card,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBodyPartsBuilder() {
    final remaining = activity.options.asMap().entries.where(
      (entry) => !_sortedTargets.containsKey(entry.key),
    );

    return Column(
      children: [
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 939,
                height: 820,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 939,
                      height: 1280,
                      child: Image.asset(
                        activity.iconPath ??
                            'assets/image/body_parts_board_empty.jpeg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    _positionedBodyTarget(0, 143, 105),
                    _positionedBodyTarget(1, 143, 239),
                    _positionedBodyTarget(2, 143, 373),
                    _positionedBodyTarget(3, 143, 507),
                    _positionedBodyTarget(4, 143, 641),
                    _positionedBodyTarget(5, 677, 105),
                    _positionedBodyTarget(6, 677, 239),
                    _positionedBodyTarget(7, 677, 373),
                    _positionedBodyTarget(8, 677, 507),
                    _positionedBodyTarget(9, 677, 641),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: remaining.map((entry) {
                final card = Container(
                  width: 85,
                  height: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        (activity.imagePaths != null &&
                            activity.imagePaths!.length > entry.key &&
                            activity.imagePaths![entry.key].isNotEmpty)
                        ? Transform.scale(
                            scale: 1.12,
                            child: Image.asset(
                              activity.imagePaths![entry.key],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                            ),
                          )
                        : Center(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                  ),
                );
                return Draggable<int>(
                  data: entry.key,
                  feedback: Material(color: Colors.transparent, child: card),
                  childWhenDragging: Opacity(opacity: .25, child: card),
                  child: card,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _positionedBodyTarget(int targetIndex, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      width: 132,
      height: 132,
      child: _bodyTarget(targetIndex),
    );
  }

  Widget _bodyTarget(int targetIndex) {
    final filled = _sortedTargets.containsKey(targetIndex);
    final targetName = activity.targets.length > targetIndex
        ? activity.targets[targetIndex]
        : '';
    final imagePath =
        (activity.imagePaths != null &&
            activity.imagePaths!.length > targetIndex)
        ? activity.imagePaths![targetIndex]
        : '';

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        if (details.data == targetIndex) {
          setState(() => _sortedTargets[targetIndex] = targetIndex);
          widget.onCorrectStep?.call();
          if (_sortedTargets.length == activity.options.length) {
            _finish();
          }
        } else {
          widget.onIncorrect?.call();
          setState(() => _message = 'هذا الجزء له مكان آخر ✖');
        }
      },
      builder: (context, candidates, rejects) {
        final active = candidates.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : (active
                      ? Colors.green.withValues(alpha: .25)
                      : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(
              color: filled
                  ? Colors.green
                  : (active ? Colors.green : Colors.transparent),
              width: 4,
            ),
          ),
          child: filled
              ? ClipOval(
                  child: imagePath.isNotEmpty
                      ? Transform.scale(
                          scale: 1.12,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Text(
                                    targetName,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                          ),
                        )
                      : Center(
                          child: Text(
                            targetName,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBodyPrivacyMarkers() {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 839,
          height: 1280,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  activity.iconPath ??
                      'assets/image/privacy_body_board_empty.jpeg',
                  fit: BoxFit.fill,
                ),
              ),
              _positionedPrivacyTarget(0, 75, 255, 120),
              _positionedPrivacyTarget(1, 520, 25, 125),
              _positionedPrivacyTarget(2, 355, 325, 125),
              _positionedPrivacyTarget(3, 572, 275, 110),
              _positionedPrivacyTarget(4, 548, 393, 155),
              _positionedPrivacyTarget(5, 548, 545, 155),
              _positionedPrivacyTarget(6, 150, 548, 160),
              Positioned(
                left: 95,
                top: 990,
                width: 270,
                height: 270,
                child: _privacyMarkerSource(0),
              ),
              Positioned(
                left: 470,
                top: 990,
                width: 270,
                height: 270,
                child: _privacyMarkerSource(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyMarkerSource(int markerIndex) {
    final label = markerIndex == 1 ? 'علامة صح' : 'علامة خطأ';
    return Draggable<int>(
      data: markerIndex,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(-50, -50),
          child: SizedBox(
            width: 100,
            height: 100,
            child: _privacyMarkerImage(markerIndex),
          ),
        ),
      ),
      child: Semantics(
        button: true,
        label: label,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }

  Widget _positionedPrivacyTarget(
    int targetIndex,
    double left,
    double top,
    double size,
  ) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (_) =>
            !_privacyMarkers.containsKey(targetIndex),
        onAcceptWithDetails: (details) {
          final expectedMarker =
              activity.correctTargetIndexes.length > targetIndex
              ? activity.correctTargetIndexes[targetIndex]
              : -1;
          if (details.data != expectedMarker) {
            widget.onIncorrect?.call();
            setState(() => _message = 'جرّب العلامة الأخرى ✋');
            return;
          }

          setState(() {
            _privacyMarkers[targetIndex] = details.data;
            _message = '';
          });
          widget.onCorrectStep?.call();
          if (_privacyMarkers.length == activity.targets.length) {
            _finish();
          }
        },
        builder: (context, candidates, rejectedData) {
          final markerIndex = _privacyMarkers[targetIndex];
          final active = candidates.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: .18)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: active
                  ? Border.all(color: AppColors.primary, width: 5)
                  : null,
            ),
            child: markerIndex == null
                ? null
                : _privacyMarkerImage(markerIndex),
          );
        },
      ),
    );
  }

  Widget _privacyMarkerImage(int markerIndex) {
    final paths = activity.imagePaths;
    if (paths == null || paths.length <= markerIndex) {
      return Icon(
        markerIndex == 1 ? Icons.check_circle : Icons.cancel,
        color: markerIndex == 1 ? Colors.green : Colors.red,
      );
    }

    return ClipOval(
      child: Transform.scale(
        scale: markerIndex == 1 ? 1.12 : 1.34,
        child: Image.asset(paths[markerIndex], fit: BoxFit.cover),
      ),
    );
  }

  Widget _faceTarget(int targetIndex, Offset offset) {
    final filled = _sortedTargets.containsKey(targetIndex);

    Widget emptyBox(bool active, double w, double h) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: active
              ? Colors.green.withValues(alpha: .25)
              : Colors.white.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? Colors.green : Colors.brown.shade200,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          '؟',
          style: TextStyle(color: Colors.brown, fontSize: 24),
        ),
      );
    }

    return Transform.translate(
      offset: offset,
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          if (details.data == targetIndex) {
            setState(() => _sortedTargets[targetIndex] = targetIndex);
            widget.onCorrectStep?.call();
            if (_sortedTargets.length == activity.options.length) {
              _finish();
            }
          } else {
            widget.onIncorrect?.call();
            setState(() => _message = 'هذا الجزء له مكان آخر في الوجه ✖');
          }
        },
        builder: (context, candidates, rejects) {
          final active = candidates.isNotEmpty;
          final imagePath =
              (activity.imagePaths != null &&
                  activity.imagePaths!.length > targetIndex)
              ? activity.imagePaths![targetIndex]
              : '';

          if (!filled) {
            if (targetIndex == 4) {
              // Ears
              return SizedBox(
                width: 190,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    emptyBox(active, 35, 55),
                    emptyBox(active, 35, 55),
                  ],
                ),
              );
            }
            if (targetIndex == 3) {
              // Eyes
              return SizedBox(
                width: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    emptyBox(active, 46, 36),
                    emptyBox(active, 46, 36),
                  ],
                ),
              );
            }
            return emptyBox(
              active,
              targetIndex == 0 ? 145 : 60,
              targetIndex == 0 ? 58 : 46,
            );
          }

          // FILLED STATE
          if (imagePath.isNotEmpty) {
            final skinColor = const Color(0xffFFD5B5);
            if (targetIndex == 4) {
              // Ears
              return SizedBox(
                width: 190,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Image.asset(
                        imagePath,
                        width: 42,
                        height: 60,
                        color: skinColor,
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                    Image.asset(
                      imagePath,
                      width: 42,
                      height: 60,
                      color: skinColor,
                      colorBlendMode: BlendMode.multiply,
                    ),
                  ],
                ),
              );
            }
            if (targetIndex == 3) {
              // Eyes
              return SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      imagePath,
                      width: 50,
                      height: 40,
                      color: skinColor,
                      colorBlendMode: BlendMode.multiply,
                    ),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Image.asset(
                        imagePath,
                        width: 50,
                        height: 40,
                        color: skinColor,
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Image.asset(
              imagePath,
              width: targetIndex == 0 ? 150 : 64,
              height: targetIndex == 0 ? 80 : 64,
              fit: BoxFit.contain,
              color: targetIndex == 0
                  ? null
                  : skinColor, // Don't blend hair with skin color to avoid top box
              colorBlendMode: targetIndex == 0 ? null : BlendMode.multiply,
            );
          }

          return Text(
            _facePartEmoji(targetIndex),
            style: TextStyle(fontSize: targetIndex == 0 ? 48 : 34),
          );
        },
      ),
    );
  }

  Widget _buildSequenceTrain() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: [
              const Text('🚂', style: TextStyle(fontSize: 58)),
              ...List.generate(activity.options.length, (index) {
                final placed = _sequencePlaced.length > index
                    ? _sequencePlaced[index]
                    : null;
                return Container(
                  width: 78,
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: placed == null
                        ? Colors.white
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.blue, width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (placed != null)
                        if (activity.imagePaths != null &&
                            activity.imagePaths!.length > placed &&
                            activity.imagePaths![placed].isNotEmpty)
                          Image.asset(
                            activity.imagePaths![placed],
                            width: 38,
                            height: 38,
                          )
                        else
                          Text(
                            _sequenceEmoji(placed),
                            style: const TextStyle(fontSize: 30),
                          ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _sequenceOrder
                  .where((index) => !_sequencePlaced.contains(index))
                  .map(
                    (index) => GestureDetector(
                      onTap: () => _selectSequenceEvent(index),
                      child: Container(
                        width: 155,
                        constraints: const BoxConstraints(minHeight: 110),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _wrongIndex == index
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (activity.imagePaths != null &&
                                activity.imagePaths!.length > index &&
                                activity.imagePaths![index].isNotEmpty)
                              Image.asset(
                                activity.imagePaths![index],
                                width: 50,
                                height: 50,
                              )
                            else
                              Text(
                                _sequenceEmoji(index),
                                style: const TextStyle(fontSize: 35),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              activity.options[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (_message.isNotEmpty) _statusText(_message),
      ],
    );
  }

  void _selectSequenceEvent(int index) {
    final expected = _sequencePlaced.length;
    if (index == expected) {
      setState(() {
        _sequencePlaced.add(index);
        _wrongIndex = null;
        _message = 'خطوة صحيحة ✔';
      });
      widget.onCorrectStep?.call();
      if (_sequencePlaced.length == activity.options.length) {
        _finish();
      }
      return;
    }
    widget.onIncorrect?.call();
    setState(() {
      _wrongIndex = index;
      _message = 'الترتيب غير صحيح ✖ فكّر في الخطوة التي تأتي أولًا';
    });
  }

  Widget _buildPuzzle() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: activity.targets.asMap().entries.map((entry) {
              final targetIndex = entry.key;
              final placedList =
                  _sortedTargets.entries
                      .where((e) => e.value == targetIndex)
                      .map((e) => e.key)
                      .toList()
                    ..sort(); // Sort so they appear in correct order (e.g. right half then left half)

              // Check if we have accepted all expected pieces for this target
              final expectedCount = activity.correctTargetIndexes
                  .where((idx) => idx == targetIndex)
                  .length;
              final isFull = placedList.length >= expectedCount;

              return DragTarget<int>(
                onWillAcceptWithDetails: (_) => !isFull && !_completed,
                onAcceptWithDetails: (details) {
                  final draggedIndex = details.data;
                  if (activity.correctTargetIndexes[draggedIndex] ==
                      targetIndex) {
                    setState(() {
                      _sortedTargets[draggedIndex] = targetIndex;
                      _wrongIndex = null;
                      if (_sortedTargets.length == activity.options.length) {
                        _finish();
                      }
                    });
                    widget.onCorrectStep?.call();
                  } else {
                    setState(() => _wrongIndex = draggedIndex);
                    widget.onIncorrect?.call();
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  final isHover = candidateData.isNotEmpty;
                  final color = _colorAt(targetIndex);

                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isHover
                          ? color.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHover ? color : Colors.grey.shade300,
                        width: 3,
                        style: placedList.isNotEmpty
                            ? BorderStyle.solid
                            : BorderStyle.none,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: placedList.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: placedList.map((pIndex) {
                              if (activity.imagePaths != null &&
                                  activity.imagePaths!.length > pIndex &&
                                  activity.imagePaths![pIndex].isNotEmpty) {
                                return Image.asset(
                                  activity.imagePaths![pIndex],
                                  width: 67,
                                  height: 134,
                                  fit: BoxFit.fill,
                                );
                              }
                              return Text(
                                _itemEmoji(activity.options[pIndex]),
                                style: const TextStyle(fontSize: 60),
                              );
                            }).toList(),
                          )
                        : Text(
                            entry.value,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: activity.options.asMap().entries.map((entry) {
              final isPlaced = _sortedTargets.containsKey(entry.key);
              if (isPlaced) return const SizedBox.shrink();

              final isWrong = _wrongIndex == entry.key;
              final child = Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isWrong ? Colors.red.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isWrong ? Colors.red : _colorAt(entry.key),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child:
                    activity.imagePaths != null &&
                        activity.imagePaths!.length > entry.key &&
                        activity.imagePaths![entry.key].isNotEmpty
                    ? Image.asset(
                        activity.imagePaths![entry.key],
                        width: 80,
                        height: 80,
                      )
                    : Text(
                        _itemEmoji(entry.value),
                        style: const TextStyle(fontSize: 50),
                      ),
              );

              return Draggable<int>(
                data: entry.key,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(scale: 1.1, child: child),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: child),
                child: child,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _shapeSymbol(String label) {
    if (label.contains('مربع')) return '□';
    if (label.contains('مثلث')) return '△';
    if (label.contains('دائرة')) return '○';
    if (label.contains('مستطيل')) return '▭';
    return '';
  }

  Widget _build3DShape(String label) {
    if (label.contains('مربع')) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 4),
              blurRadius: 4,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade300],
          ),
        ),
      );
    }
    if (label.contains('دائرة')) {
      return Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 4),
              blurRadius: 4,
            ),
          ],
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.4),
            radius: 0.8,
            colors: [Colors.white, Colors.grey],
          ),
        ),
      );
    }
    if (label.contains('مستطيل')) {
      return Container(
        width: 60,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 4),
              blurRadius: 4,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade300],
          ),
        ),
      );
    }
    if (label.contains('مثلث')) {
      return Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        child: const Icon(
          Icons.change_history_rounded,
          size: 58,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black26, offset: Offset(2, 4), blurRadius: 4),
          ],
        ),
      );
    }
    return const SizedBox(height: 48);
  }

  String _facePartEmoji(int index) {
    return switch (index) {
      0 => '💇',
      1 => '👃',
      2 => '👄',
      3 => '👀',
      _ => '👂👂',
    };
  }

  String _sequenceEmoji(int index) {
    return switch (index) {
      0 => '✋',
      1 => '📣',
      2 => '👨‍👩‍👧',
      _ => '👮',
    };
  }

  Widget _mixCircle(Color color) => Container(
    width: 66,
    height: 66,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _actionButton(String label, VoidCallback? onPressed) => FilledButton(
    onPressed: _completed ? null : onPressed,
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        fontFamily: 'Tajawal',
      ),
    ),
  );

  Widget _statusText(String text) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xffD78300),
        fontWeight: FontWeight.w900,
        fontFamily: 'Tajawal',
      ),
    ),
  );

  Color _colorAt(int index) {
    if (activity.colorValues.isNotEmpty) {
      return Color(activity.colorValues[index % activity.colorValues.length]);
    }
    const fallback = [
      Color(0xffF44336),
      Color(0xff2196F3),
      Color(0xffFFCA28),
      Color(0xff8E24AA),
      Color(0xff43A047),
      Color(0xffFB8C00),
    ];
    return fallback[index % fallback.length];
  }

  String _normalize(String text) {
    var value = text.trim().replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    value = value.replaceAll(RegExp(r'[أإآ]'), 'ا');
    value = value.replaceAll('ة', 'ه').replaceAll('ى', 'ي');
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  String _itemEmoji(String label) {
    if (label.contains('دائرة')) return '⚪';
    if (label.contains('اليد')) return '✋';
    if (label.contains('الأذن')) return '👂';
    if (label.contains('العين')) return '👁️';
    if (label.contains('اللسان')) return '👅';
    if (label.contains('الأنف')) return '👃';
    if (label.contains('القطة')) return '🐱';
    if (label.contains('البقرة')) return '🐄';
    if (label.contains('تفاح')) return '🍎';
    if (label.contains('بطيخ')) return '🍉';
    if (label.contains('برتقال')) return '🍊';
    if (label.contains('فراول')) return '🍓';
    if (label.contains('عنب')) return '🍇';
    if (label.contains('مانجا')) return '🥭';
    if (label.contains('جوافة')) return '🍐';
    if (label.contains('طماطم')) return '🍅';
    if (label.contains('خيار')) return '🥒';
    if (label.contains('بصل')) return '🧅';
    if (label.contains('خس')) return '🥬';
    if (label.contains('ليمون')) return '🍋';
    if (label.contains('جزر')) return '🥕';
    if (label.contains('فلفل')) return '🫑';
    if (label.contains('بنجر')) return '🫜';
    if (label.contains('باذنجان')) return '🍆';
    if (label.contains('ذرة')) return '🌽';
    if (label.contains('بطاطس')) return '🥔';
    if (label.contains('موز')) return '🍌';
    return '🥗';
  }

  Widget _buildCameraIdentity() {
    return _CameraIdentityWidget(onCompleted: _finish);
  }

  Widget _buildNameAndGender() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (_listening) {
                widget.speechService.stopListening();
                setState(() => _listening = false);
              } else {
                setState(() => _listening = true);
                widget.speechService.startListening(
                  onResult: (text) {},
                  onError: (error) {},
                );
              }
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _listening
                    ? Colors.red.withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: _listening ? Colors.red : Colors.black,
                  width: 5,
                ),
              ),
              child: Icon(
                Icons.mic,
                size: 80,
                color: _listening ? Colors.red : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'ما هو نوعك؟',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderOption(0, 'ولد'),
              _buildGenderOption(1, 'بنت'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(int index, String label) {
    return GestureDetector(
      onTap: () {
        if (!_completed) {
          _finish();
        }
      },
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Image.asset(activity.imagePaths![index], fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

class _ShapeTracePainter extends CustomPainter {
  final List<Offset> points;
  final Set<int> completedEdges;

  const _ShapeTracePainter({
    required this.points,
    required this.completedEdges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const min = 35.0;
    const max = 235.0;
    final guide = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final completed = Paint()
      ..color = const Color(0xff4ECE6C)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final edges = [
      (const Offset(min, min), const Offset(max, min)),
      (const Offset(max, min), const Offset(max, max)),
      (const Offset(max, max), const Offset(min, max)),
      (const Offset(min, max), const Offset(min, min)),
    ];

    for (var edgeIndex = 0; edgeIndex < edges.length; edgeIndex++) {
      final edge = edges[edgeIndex];
      if (completedEdges.contains(edgeIndex)) {
        canvas.drawLine(edge.$1, edge.$2, completed);
        continue;
      }
      for (var step = 0; step < 10; step += 2) {
        final start = Offset.lerp(edge.$1, edge.$2, step / 10)!;
        final end = Offset.lerp(edge.$1, edge.$2, (step + 1) / 10)!;
        canvas.drawLine(start, end, guide);
      }
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.blue.withValues(alpha: .65)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.drawCircle(
      points.isEmpty ? const Offset(min, min) : points.last,
      11,
      Paint()..color = Colors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final int index;
  const _FloatingWidget({required this.child, this.index = 0});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + (widget.index * 200)),
    )..repeat(reverse: true);
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
        return Transform.translate(
          offset: Offset(0, 10 * _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _CameraIdentityWidget extends StatefulWidget {
  final VoidCallback onCompleted;

  const _CameraIdentityWidget({required this.onCompleted});

  @override
  State<_CameraIdentityWidget> createState() => _CameraIdentityWidgetState();
}

class _CameraIdentityWidgetState extends State<_CameraIdentityWidget> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _hasCamera = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _hasCamera = false);
        return;
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) setState(() => _hasCamera = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCamera) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'الكاميرا غير متوفرة (أنت تستخدم محاكي)',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: widget.onCompleted,
            child: const Text(
              'تخطي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                setState(() => _isRecording = !_isRecording);
              },
              child: Text(
                _isRecording ? 'جاري التسجيل...' : 'بدء التسجيل',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                widget.onCompleted();
              },
              child: const Text(
                'إنهاء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
