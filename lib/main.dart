import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:alzheimer_games_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'data/repositories/question_repository.dart';
import 'features/bloc/bottom_nav_cubit.dart';
import 'features/screens/games/trivia/trivia_view_model.dart';
import 'features/screens/screens.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavCubit>(
          create: (context) => BottomNavCubit(),
        ),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzheimer Games',
      debugShowCheckedModeBanner: false,

      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/home': (context) => const HomeScreen(),
        '/puzzle': (context) => const SlidePuzzleScreen(),
        '/memorama': (context) => const MemoramaScreen(),
        '/trivia': (context) => ChangeNotifierProvider(
          create: (context) => TriviaViewModel(
            questionRepository: QuestionRepository(firestoreService: FirestoreService(FirebaseFirestore.instance)),
            firestoreService: FirestoreService(FirebaseFirestore.instance),
            authService: AuthService(FirebaseAuth.instance),
          ),
          child: const TriviaScreen(),
        ),
        '/encaje_figura': (context) => const FiguraEncajeScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}