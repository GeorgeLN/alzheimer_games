import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class PatternViewModel with ChangeNotifier {
  final UserRepository userRepository;

  PatternViewModel({required this.userRepository});

  Future<int> loadInitialScore() async {
    try {
      PlayerModel player = await userRepository.getCurrentPlayer();
      return player.scorePattern ?? 0;
    } catch (e) {
      print('Error al cargar puntaje inicial de Pattern: $e');
      return 0;
    }
  }

  Future<void> saveGameScore(int newScore) async {
    try {
      PlayerModel currentPlayer = await userRepository.getCurrentPlayer();
      await userRepository.updateUser(
        scorePattern: newScore, // Guardar el nuevo puntaje de Pattern
        scoreMemory: currentPlayer.scoreMemory,
        scorePuzzle: currentPlayer.scorePuzzle,
        scoreTrivia: currentPlayer.scoreTrivia,
        // Asumimos que updateUser obtiene el userId internamente o ya lo tiene configurado.
      );
      print('Puntaje de Pattern guardado: $newScore');
      // notifyListeners(); // Descomentar si la UI necesita reaccionar a este guardado.
    } catch (e) {
      print('Error al guardar puntaje de Pattern: $e');
      // Considera re-lanzar el error o manejarlo de otra forma si es crítico.
      // throw e;
    }
  }
}
