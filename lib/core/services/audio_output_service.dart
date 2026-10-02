import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Keeps recorded-speech sessions from leaving regular app audio muted.
class AudioOutputService {
  const AudioOutputService._();

  /// Restores the output-only audio session used by assets, videos, and TTS.
  ///
  /// Android must be left to manage its media route. Setting
  /// `isSpeakerphoneOn` through audioplayers changes a device-wide telephony
  /// setting and can route normal media away from the expected speaker.
  static Future<void> configureForPlayback() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {},
        ),
      ),
    );
  }

  static Future<void> playAsset(AudioPlayer player, String assetPath) async {
    await configureForPlayback();
    await player.stop();
    await player.setVolume(1);
    await player.play(AssetSource(normalizeAssetPath(assetPath)));
  }

  static String normalizeAssetPath(String assetPath) {
    return assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
  }
}
