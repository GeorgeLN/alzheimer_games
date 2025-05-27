
import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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
}