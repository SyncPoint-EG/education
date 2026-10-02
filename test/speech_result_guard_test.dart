import 'package:education/core/services/speech_result_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts only the first callback from a speech attempt', () {
    final guard = SpeechResultGuard();
    final attempt = guard.beginAttempt();

    expect(guard.claim(attempt), isTrue);
    expect(guard.claim(attempt), isFalse);
    expect(guard.claim(attempt), isFalse);
  });

  test('ignores stale callbacks after a new attempt starts', () {
    final guard = SpeechResultGuard();
    final staleAttempt = guard.beginAttempt();
    final activeAttempt = guard.beginAttempt();

    expect(guard.claim(staleAttempt), isFalse);
    expect(guard.claim(activeAttempt), isTrue);
  });

  test('ignores callbacks after cancellation', () {
    final guard = SpeechResultGuard();
    final attempt = guard.beginAttempt();

    guard.cancel();

    expect(guard.claim(attempt), isFalse);
  });
}
