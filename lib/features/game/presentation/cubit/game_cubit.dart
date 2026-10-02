import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/speech_service.dart';
import '../../../map/domain/entities/level_entity.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

class GameState {
  final int currentExIndex;
  final int score;
  final bool isListening;
  final String recognizedText;
  final String feedbackStatus; // 'perfect', 'good', 'wrong', 'none'
  final bool isSessionComplete;
  final int earnedStars;
  final String error;

  GameState({
    this.currentExIndex = 0,
    this.score = 0,
    this.isListening = false,
    this.recognizedText = '',
    this.feedbackStatus = 'none',
    this.isSessionComplete = false,
    this.earnedStars = 0,
    this.error = '',
  });

  GameState copyWith({
    int? currentExIndex,
    int? score,
    bool? isListening,
    String? recognizedText,
    String? feedbackStatus,
    bool? isSessionComplete,
    int? earnedStars,
    String? error,
  }) {
    return GameState(
      currentExIndex: currentExIndex ?? this.currentExIndex,
      score: score ?? this.score,
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      earnedStars: earnedStars ?? this.earnedStars,
      error: error ?? this.error,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  final SpeechService _speechService;
  final ProfileCubit _profileCubit;
  late LevelEntity _level;

  GameCubit(this._speechService, this._profileCubit) : super(GameState());

  void startSession(LevelEntity level) {
    _level = level;
    emit(GameState(
      currentExIndex: 0,
      score: 0,
      isListening: false,
      recognizedText: '',
      feedbackStatus: 'none',
      isSessionComplete: false,
      earnedStars: 0,
      error: '',
    ));
    // Automatically play first exercise prompt
    playCurrentPrompt();
  }

  ExerciseEntity get currentExercise => _level.exercises[state.currentExIndex];
  int get totalExercises => _level.exercises.length;

  Future<void> playCurrentPrompt() async {
    final ex = currentExercise;
    String textToSpeak = ex.prompt;
    if (ex.type == ExerciseType.listenRepeat && ex.word != null) {
      textToSpeak = "قول ورايا: ${ex.word}";
    }
    await _speechService.speak(textToSpeak);
  }

  Future<void> startListening() async {
    emit(state.copyWith(isListening: true, recognizedText: '', feedbackStatus: 'none'));
    try {
      final success = await _speechService.startListening(
        onResult: (results) {
          _evaluateSpokenText(results);
        },
        onError: (err) {
          emit(state.copyWith(isListening: false, error: err));
        },
      );
      if (!success) {
        emit(state.copyWith(isListening: false));
      }
    } catch (e) {
      emit(state.copyWith(isListening: false, error: "تعذر فتح الميكروفون"));
    }
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    emit(state.copyWith(isListening: false));
  }

  void _evaluateSpokenText(List<String> spokenAlternatives) {
    if (spokenAlternatives.isEmpty) return;
    _speechService.stopListening();

    final ex = currentExercise;
    String status = 'wrong';
    String bestMatch = spokenAlternatives.first;

    if (ex.type == ExerciseType.listenRepeat && ex.word != null) {
      status = _checkWordMatch(spokenAlternatives, ex.word!);
    } else if (ex.type == ExerciseType.describeImage && ex.expectedWords != null) {
      status = _checkListMatch(spokenAlternatives, ex.expectedWords!);
    } else if (ex.type == ExerciseType.answerQuestion && ex.expectedAnswer != null) {
      status = _checkWordMatch(spokenAlternatives, ex.expectedAnswer!);
    }

    final int scoreIncrement = (status == 'perfect' || status == 'good') ? 1 : 0;

    emit(state.copyWith(
      isListening: false,
      recognizedText: bestMatch,
      feedbackStatus: status,
      score: state.score + scoreIncrement,
    ));
  }

  String _normalize(String text) {
    var str = text.trim();
    // Strip diacritics
    str = str.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    // Normalize Alif
    str = str.replaceAll(RegExp(r'[أإآ]'), 'ا');
    // Normalize Teh Marbuta
    str = str.replaceAll('ة', 'ه');
    // Normalize Alef Maksura
    str = str.replaceAll('ى', 'ي');
    // Strip non-alphanumeric
    str = str.replaceAll(RegExp(r'[^\u0621-\u064A\u0660-\u0669a-zA-Z0-9\s]'), '');
    return str.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _checkWordMatch(List<String> spokenAlternatives, String expected) {
    final expectedClean = _normalize(expected);

    for (final alternative in spokenAlternatives) {
      final alternativeClean = _normalize(alternative);
      if (alternativeClean == expectedClean) {
        return 'perfect';
      }
      if (alternativeClean.contains(expectedClean) || expectedClean.contains(alternativeClean)) {
        return 'good';
      }
    }
    return 'wrong';
  }

  String _checkListMatch(List<String> spokenAlternatives, List<String> expectedWords) {
    // If child says any of the expected words, it is a good/perfect match
    int matchCount = 0;
    final cleanExpected = expectedWords.map((w) => _normalize(w)).toList();

    for (final alternative in spokenAlternatives) {
      final alternativeClean = _normalize(alternative);
      for (final expected in cleanExpected) {
        if (alternativeClean.contains(expected)) {
          matchCount++;
        }
      }
    }

    if (matchCount >= expectedWords.length) {
      return 'perfect';
    } else if (matchCount > 0) {
      return 'good';
    }
    return 'wrong';
  }

  void nextExercise() {
    _speechService.stopSpeaking();
    
    if (state.currentExIndex + 1 >= totalExercises) {
      // Complete level session
      final int earnedStars = _calculateStars(state.score, totalExercises);
      _profileCubit.completeLevel(_level.id, earnedStars);

      emit(state.copyWith(
        isSessionComplete: true,
        earnedStars: earnedStars,
      ));
    } else {
      emit(state.copyWith(
        currentExIndex: state.currentExIndex + 1,
        feedbackStatus: 'none',
        recognizedText: '',
        error: '',
      ));
      playCurrentPrompt();
    }
  }

  void skipExercise() {
    _speechService.stopSpeaking();

    if (state.currentExIndex + 1 >= totalExercises) {
      final int earnedStars = _calculateStars(state.score, totalExercises);
      _profileCubit.completeLevel(_level.id, earnedStars);

      emit(state.copyWith(
        isSessionComplete: true,
        earnedStars: earnedStars,
      ));
    } else {
      emit(state.copyWith(
        currentExIndex: state.currentExIndex + 1,
        feedbackStatus: 'none',
        recognizedText: '',
        error: '',
      ));
      playCurrentPrompt();
    }
  }

  void repeatExercise() {
    emit(state.copyWith(feedbackStatus: 'none', recognizedText: '', error: ''));
    playCurrentPrompt();
  }

  int _calculateStars(int score, int total) {
    if (score == total) return 3;
    if (score >= total * 0.6) return 2;
    if (score > 0) return 1;
    return 0;
  }
}
