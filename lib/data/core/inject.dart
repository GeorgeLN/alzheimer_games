
import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// ViewModel imports
import '../../features/screens/games/memorama/memorama_view_model.dart';
import '../../features/screens/games/pattern/pattern_view_model.dart';
import '../../features/screens/games/puzzle/puzzle_view_model.dart';
import '../../features/screens/games/trivia/trivia_view_model.dart'; // Added

// Repository imports already present
import '../repositories/user_repository.dart'; // Ensure this is imported if not already for clarity

import '../services/authentication/auth_service.dart';
import '../services/firestore/firestore_service.dart';

GetIt inject = GetIt.instance;

Future<void> setupInjection() async {
  inject.registerLazySingleton<FirestoreService>(() {
    return FirestoreService(FirebaseFirestore.instance);
  });

  inject.registerLazySingleton<AuthService>(() {
    return AuthService(FirebaseAuth.instance);
  });

  inject.registerLazySingleton<QuestionRepository>(() {
    return QuestionRepository(
      firestoreService: inject<FirestoreService>(),
    );
  });

  // inject.registerLazySingleton<AuthUserRepository>(() {
  //   return AuthUserRepository(
  //     authService: inject<AuthService>(),
  //     firestoreService: inject<FirestoreService>(),
  //   );
  // });

  inject.registerLazySingleton<UserRepository>(() {
    return UserRepository(
      authService: inject<AuthService>(),
      firestoreService: inject<FirestoreService>(),
    );
  });

  // Register ViewModels
  inject.registerFactory(() => MemoramaViewModel(userRepository: inject<UserRepository>()));
  inject.registerFactory(() => PatternViewModel(userRepository: inject<UserRepository>()));
  inject.registerFactory(() => PuzzleViewModel(userRepository: inject<UserRepository>()));
  inject.registerFactory(() => TriviaViewModel( // Added
        questionRepository: inject<QuestionRepository>(),
        firestoreService: inject<FirestoreService>(),
        authService: inject<AuthService>(),
        userRepository: inject<UserRepository>(),
      ));
}