
import 'package:alzheimer_games_app/data/models/models.dart';
import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart'; // Added UserRepository import
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum TriviaStatus {
  content,
  loading,
  error,
  empty,
}

class TriviaViewModel with ChangeNotifier {
  var status = TriviaStatus.loading;
  final QuestionRepository questionRepository;
  final UserRepository userRepository; // Added UserRepository field
  QuestionModel? questionModel;
  PlayerModel? playerModel;
  final List<String> questionIds = [];

  int currentQuestion = 0;

  TriviaViewModel({
    required this.questionRepository,
    required this.firestoreService,
    required this.authService,
    required this.userRepository, // Added to constructor
  });
  
  final FirestoreService firestoreService;
  final AuthService authService;

  Future<void> saveGameScore(int newScore) async {
    try {
      PlayerModel currentPlayer = await userRepository.getCurrentPlayer();
      int currentTriviaScore = currentPlayer.scoreTrivia ?? 0;

      if (newScore > currentTriviaScore) {
        await userRepository.updateUser(
          scoreTrivia: newScore,
          scoreMemory: currentPlayer.scoreMemory,
          scorePattern: currentPlayer.scorePattern,
          scorePuzzle: currentPlayer.scorePuzzle,
        );
        playerModel?.scoreTrivia = newScore; // Update local model
        notifyListeners(); // Notify UI of change
        print('Puntaje de Trivia actualizado y guardado: $newScore');
      } else {
        print('Puntaje de Trivia no guardado, el nuevo puntaje ($newScore) no es mayor que el actual ($currentTriviaScore).');
      }
    } catch (e) {
      print('Error al guardar puntaje de Trivia: $e');
    }
  }

  void initialize() async {
    try {
      await loadListQuestions();
      final userId = await authService.getUserId();
      firestoreService.loadPlayerStream(userId: userId ?? '').listen((event) {
        playerModel = event;
        notifyListeners();
      });

      if (questionIds.isNotEmpty) {
        //Aquí se valida el nivel de las preguntas
        await loadQuestion(questionId: questionIds.first);
      } else {
        emitEmpty();
      }
    } catch (e) {
      emitError();
    }
  }

  void resetQuestion() {
    currentQuestion = 0;
    loadQuestion(questionId: questionIds[currentQuestion]);
  }

  void nextQuestion() async {
    if (currentQuestion < questionIds.length - 1) {
      currentQuestion ++;
      await loadQuestion(questionId: questionIds[currentQuestion]);
    }
  }

  Future<void> loadListQuestions() async {
    try {
      emitLoading();
      questionIds.addAll(await questionRepository.loadListQuestions());
      emitContent();
    } catch (e) {
      emitError();
    }
  }

  Future<void> loadQuestion({required String questionId}) async {    
    try {
      emitLoading();
      await Future.delayed(const Duration(seconds: 1));
      questionModel = await questionRepository.loadQuestion(
        questionId: questionId,
      );
      emitContent();
    } catch (e) {
      emitError();
    }
  }

  void emitError() {
    status = TriviaStatus.error;
    notifyListeners();
  }

  void emitLoading() {
    status = TriviaStatus.loading;
    notifyListeners();
  }

  void emitContent() {
    status = TriviaStatus.content;
    notifyListeners();
  }

  void emitEmpty() {
    status = TriviaStatus.empty;
    notifyListeners();
  }
}

