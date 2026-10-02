import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'audio_output_service.dart';

abstract class SpeechService {
  Future<void> init();
  Future<void> speak(String text, {Function? onEnd});
  Future<void> stopSpeaking();
  Future<bool> startListening({
    required Function(List<String> results) onResult,
    required Function(String error) onError,
  });
  Future<void> stopListening();
  bool get isListening;
}

class SpeechServiceImpl implements SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSpeechInitialized = false;

  @override
  Future<void> init() async {
    // Initialize TTS
    await _flutterTts.setLanguage("ar-EG");
    await _flutterTts.setSpeechRate(0.45); // Slower rate for children
    await _flutterTts.setPitch(1.15); // Slightly higher pitch for kids

    // TTS is output-only. speech_to_text manages playAndRecord while listening
    // and restores this playback category when it stops.
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }

  @override
  Future<void> speak(String text, {Function? onEnd}) async {
    await _flutterTts.stop();
    await AudioOutputService.configureForPlayback();
    await _configureTtsOutput();
    if (onEnd != null) {
      _flutterTts.setCompletionHandler(() {
        onEnd();
      });
    } else {
      _flutterTts.setCompletionHandler(() {});
    }
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  @override
  Future<bool> startListening({
    required Function(List<String> results) onResult,
    required Function(String error) onError,
  }) async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            unawaited(AudioOutputService.configureForPlayback());
          }
        },
        onError: (errorNotification) {
          onError(errorNotification.errorMsg);
        },
      );
    }

    if (!_isSpeechInitialized) {
      onError("التعرف على الصوت غير متاح في هذا الجهاز");
      return false;
    }

    if (_speechToText.isListening) {
      return true;
    }

    await _speechToText.listen(
      localeId: 'ar-EG',
      onResult: (result) {
        if (result.finalResult || result.recognizedWords.isNotEmpty) {
          final word = result.recognizedWords.trim();
          if (word.isNotEmpty) {
            onResult([word]);
          }
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 4),
    );
    return true;
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
    await AudioOutputService.configureForPlayback();
  }

  @override
  bool get isListening => _speechToText.isListening;

  Future<void> _configureTtsOutput() {
    return _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }
}
