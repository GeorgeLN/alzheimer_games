
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';

import '../models/user_model/user_model.dart';

class UserRepository {

  UserRepository({
    required this.authService,
    required this.firestoreService,
  });

  final AuthService authService;
  final FirestoreService firestoreService;

  Future<void> createUser({
    String? userId,
    String? name,
    String? email,
    String? password,
  }) async {
    await authService.registerAcount(email!, password!);
    final userId = await authService.getUserId();
    await firestoreService.addUser(
      userId: userId,
      name: name,
      email: email,
    );
  }

  Future<PlayerModel> loadUser({required String userId}) async {
    return firestoreService.loadPlayer(userId: userId);
  }

  Future<void> updateUser({
    String? userId,
    int? scoreMemory,
    int? scoreTrivia,
    int? scorePuzzle,
    int? scorePattern,
    int? scoreOtd,
    Map<String, List<int>>? completedLevels,
  }) async {
    final userId = await authService.getUserId();
    await firestoreService.updateUser(
      userId: userId,
      scoreMemory: scoreMemory,
      scoreTrivia: scoreTrivia,
      scorePuzzle: scorePuzzle,
      scorePattern: scorePattern,
      scoreOtd: scoreOtd,
      completedLevels: completedLevels,
    );
  }

  Future<PlayerModel> getCurrentPlayer() async {
    final userId = await authService.getUserId();
    final player = await firestoreService.loadPlayer(userId: userId ?? '');

    return player;
  }
}