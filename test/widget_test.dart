// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:education/main.dart';
import 'package:education/core/services/storage_service.dart';
import 'package:education/core/services/speech_service.dart';

class FakeStorageService implements StorageService {
  @override
  Future<void> init() async {}
  @override
  String? getString(String key) => null;
  @override
  Future<void> setString(String key, String value) async {}
  @override
  Future<void> remove(String key) async {}
  @override
  Future<void> clear() async {}
}

class FakeSpeechService implements SpeechService {
  @override
  Future<void> init() async {}
  @override
  Future<void> speak(String text, {Function? onEnd}) async {}
  @override
  Future<void> stopSpeaking() async {}
  @override
  Future<bool> startListening({
    required Function(List<String> results) onResult,
    required Function(String error) onError,
  }) async => true;
  @override
  Future<void> stopListening() async {}
  @override
  bool get isListening => false;
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final storageService = FakeStorageService();
    final speechService = FakeSpeechService();

    await tester.pumpWidget(
      MyApp(
        storageService: storageService,
        speechService: speechService,
      ),
    );

    // Verify that the splash screen is displayed
    expect(find.text('استمع وتحدث'), findsOneWidget);
    expect(find.text('برنامج تعليمي للأطفال'), findsOneWidget);

    // Let the 2-second navigation timer fire and transition
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
