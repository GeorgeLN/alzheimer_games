import 'package:flutter/foundation.dart';

enum PuzzleStatus {
  loading,
  content,
  error,
  empty,
}

class PuzzleViewModel with ChangeNotifier {
  var status = PuzzleStatus.loading;

  Future<void> initialize() async {
    try {
      emitLoading();
      
      emitContent();
    } catch (_) {
      emitError();
    }
  }
  
  void emitLoading() {
    status = PuzzleStatus.loading;
    notifyListeners();
  }
  
  void emitContent() {
    status = PuzzleStatus.content;
    notifyListeners();
  }
  
  void emitError() {
    status = PuzzleStatus.error;
    notifyListeners();
  }
  
  void emitEmpty() {
    status = PuzzleStatus.empty;
    notifyListeners();
  }
}