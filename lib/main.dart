import 'package:alzheimer_games_app/data/core/inject.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:alzheimer_games_app/features/screens/games/OTD/otd_screen.dart';
import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_view_model.dart';
import 'package:alzheimer_games_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'data/repositories/question_repository.dart';
import 'features/bloc/bottom_nav_cubit.dart';
import 'package:alzheimer_games_app/features/bloc/auth_cubit.dart';
import 'package:alzheimer_games_app/data/services/authentication/firebase_auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_user_service.dart';
import 'package:alzheimer_games_app/features/screens/screens.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupInjection();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(FirebaseFirestore.instance),
        ),
        ProxyProvider2<AuthService, FirestoreService, UserRepository>(
          update: (_, authService, firestoreService, __) =>
              UserRepository(authService: authService, firestoreService: firestoreService),
        ),
        BlocProvider<BottomNavCubit>(
          create: (context) => BottomNavCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authService: FirebaseAuthService(), // Instanciar el servicio
            userService: FirestoreUserService(),  // Instanciar el servicio
          )..checkInitialAuthStatus(), // Opcional: llamar para un estado inicial síncrono si es necesario
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Alzheimer Games',
        debugShowCheckedModeBanner: false,
      
        initialRoute: '/', // Changed initialRoute
        routes: {
          '/': (context) => const AuthWrapperScreen(), // Nueva ruta inicial
          '/first': (context) => const FirstScreen(),
          '/landing': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),   // Nueva ruta para Login
          '/signup': (context) => const SignUpScreen(), // Nueva ruta para SignUp
          '/home': (context) => const HomeScreen(),
          '/puzzle': (context) => const SlidePuzzleScreen(),
          '/memorama': (context) => const MemoramaScreen(),
          '/trivia': (context) => ChangeNotifierProvider(
            create: (context) => TriviaViewModel(
              userRepository: context.read<UserRepository>(),
              questionRepository: QuestionRepository(firestoreService: context.read<FirestoreService>()),
              firestoreService: context.read<FirestoreService>(),
              authService: context.read<AuthService>(),
            ),
            child: const TriviaScreen(),
          ),
          '/encaje_figura': (context) => const FitPatternScreen(),
          '/otd': (context) => const OneTouchGame(),
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const AuthWrapperScreen());
        },
      ),
    );
  }
}