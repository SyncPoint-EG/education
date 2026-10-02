import 'package:education/core/services/audio_output_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioOutputService.normalizeAssetPath', () {
    test('removes the Flutter assets prefix', () {
      expect(
        AudioOutputService.normalizeAssetPath('assets/audio/cat.m4a'),
        'audio/cat.m4a',
      );
    });

    test('keeps an already relative asset path unchanged', () {
      expect(
        AudioOutputService.normalizeAssetPath('audio/cat.m4a'),
        'audio/cat.m4a',
      );
    });
  });
}
