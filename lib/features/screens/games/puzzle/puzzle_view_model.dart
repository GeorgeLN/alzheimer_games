import 'package:flutter/foundation.dart';
import 'package:alzheimer_games_app/data/models/user_model/user_model.dart'; // Added
import 'package:alzheimer_games_app/data/repositories/user_repository.dart'; // Added

enum PuzzleStatus {
  loading,
  content,
  error,
  empty,
}

class PuzzleViewModel with ChangeNotifier {
  final UserRepository userRepository; // Added
  var status = PuzzleStatus.loading;

  PuzzleViewModel({required this.userRepository}); // Added constructor

  Future<int> loadInitialScore() async {
    try {
      PlayerModel player = await userRepository.getCurrentPlayer();
      return player.scorePuzzle ?? 0;
    } catch (e) {
      print('Error al cargar puntaje inicial de Puzzle: $e');
      return 0;
    }
  }

  Future<void> initialize() async {
    try {
      emitLoading();
      
      emitContent();
    } catch (_) {
      emitError();
    }
  }

  Future<void> saveGameScore(int newScore) async { // Added method
    try {
      PlayerModel currentPlayer = await userRepository.getCurrentPlayer();
      await userRepository.updateUser(
        scorePuzzle: newScore,
        scoreMemory: currentPlayer.scoreMemory,
        scorePattern: currentPlayer.scorePattern,
        scoreTrivia: currentPlayer.scoreTrivia,
      );
      print('Puntaje de Puzzle guardado: $newScore');
    } catch (e) {
      print('Error al guardar puntaje de Puzzle: $e');
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