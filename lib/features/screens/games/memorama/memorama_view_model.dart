import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class MemoramaViewModel with ChangeNotifier {
  final UserRepository userRepository;

  MemoramaViewModel({required this.userRepository});

  Future<int> loadInitialScore() async {
    try {
      PlayerModel player = await userRepository.getCurrentPlayer();
      return player.scoreMemory ?? 0;
    } catch (e) {
      print('Error al cargar puntaje inicial de Memorama: $e');
      return 0;
    }
  }

  Future<void> saveGameScore(int newScore) async {
    try {
      // Obtener el PlayerModel actual para no sobrescribir otros puntajes
      // Asegúrate de que getCurrentPlayer() no requiera un userId si se obtiene el del usuario logueado
      PlayerModel currentPlayer = await userRepository.getCurrentPlayer(); 

      await userRepository.updateUser(
        // El método updateUser en UserRepository podría necesitar el userId explícitamente
        // o podría obtenerlo del AuthService interno.
        // Si necesita userId: userRepository.updateUser(userId: currentPlayer.uid, scoreMemory: newScore, ...);
        // Asumiendo que updateUser puede obtener el userId o ya lo tiene configurado.
        scoreMemory: newScore,
        scorePuzzle: currentPlayer.scorePuzzle,
        scoreTrivia: currentPlayer.scoreTrivia,
        scorePattern: currentPlayer.scorePattern,
        // Si tu updateUser requiere explícitamente el userId, asegúrate de pasarlo.
        // Por ejemplo: userId: currentPlayer.uid (si uid está disponible en PlayerModel)
        // o obtenerlo de AuthService si es necesario.
        // La instrucción original dice: "// userId ya lo maneja internamente userRepository.updateUser"
        // por lo que confiamos en esa afirmación.
      );
      // Notificar a la UI si es necesario. Para un guardado simple, podría no serlo.
      // notifyListeners(); 
    } catch (e) {
      // Manejar el error, por ejemplo, imprimirlo o exponer un estado de error.
      print('Error al guardar puntaje de Memorama: $e');
      // Considera re-lanzar el error o manejarlo de otra forma más visible para el usuario si es crítico.
      // throw e; // Opcional: relanzar para que la UI pueda manejarlo.
    }
  }
}
