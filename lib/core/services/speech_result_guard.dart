/// Ensures that only the first callback from a speech-recognition attempt is
/// handled. Speech engines may emit the same partial/final result repeatedly.
class SpeechResultGuard {
  int _activeAttempt = 0;
  bool _handled = true;

  int beginAttempt() {
    _handled = false;
    return ++_activeAttempt;
  }

  bool claim(int attemptId) {
    if (attemptId != _activeAttempt || _handled) return false;
    _handled = true;
    return true;
  }

  void cancel() {
    _activeAttempt++;
    _handled = true;
  }
}
