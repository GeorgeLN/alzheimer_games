import 'package:alzheimer_games_app/data/models/models.dart';
import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:flutter/material.dart';

enum TriviaState {
  loading,
  error,
  empty,
  content,
  levelUp,
  repeatLevel,
  gameFinished,
}

enum AnswerState {
  neutral,
  correct,
  incorrect,
}

class TriviaViewModel with ChangeNotifier {
  final QuestionRepository questionRepository;
  final UserRepository userRepository;
  final FirestoreService firestoreService;
  final AuthService authService;

  TriviaState _state = TriviaState.loading;
  TriviaState get state => _state;

  QuestionModel? questionModel;
  PlayerModel? playerModel;
  List<String> _questionIds = [];
  List<AnswerState> answerStates = [];

  int _currentQuestionIndex = 0;
  int get currentQuestionNumber => _currentQuestionIndex + 1;
  int get totalLevelQuestions => _questionIds.length;

  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  int _correctAnswers = 0;

  TriviaViewModel({
    required this.questionRepository,
    required this.userRepository,
    required this.firestoreService,
    required this.authService,
  });

  void initialize() async {
    _setState(TriviaState.loading);
    try {
      final userId = await authService.getUserId();
      if (userId != null) {
        firestoreService.loadPlayerStream(userId: userId).listen((player) {
          playerModel = player;
          notifyListeners();
        });
      }
      await _loadQuestionsForCurrentLevel();
    } catch (e) {
      _setState(TriviaState.error);
    }
  }

  Future<void> _loadQuestionsForCurrentLevel() async {
    try {
      _questionIds = await questionRepository.loadListQuestions(level: _currentLevel);
      if (_questionIds.isNotEmpty) {
        _questionIds.shuffle();
        _questionIds = _questionIds.take(7).toList();
        _currentQuestionIndex = 0;
        _correctAnswers = 0;
        await _loadQuestion();
      } else {
        _setState(TriviaState.empty);
      }
    } catch (e) {
      _setState(TriviaState.error);
    }
  }

  Future<void> _loadQuestion() async {
    try {
      _setState(TriviaState.loading);
      await Future.delayed(const Duration(seconds: 1));
      questionModel = await questionRepository.loadQuestion(
        questionId: _questionIds[_currentQuestionIndex],
      );
      answerStates = List.generate(questionModel!.options.length, (_) => AnswerState.neutral);
      _setState( TriviaState.content);
    } catch (e) {
      _setState(TriviaState.error);
    }
  }

  Future<void> checkAnswer(int selectedOptionIndex) async {
    if (selectedOptionIndex == questionModel!.correctIndex) {
      _correctAnswers++;
      answerStates[selectedOptionIndex] = AnswerState.correct;
    } else {
      answerStates[selectedOptionIndex] = AnswerState.incorrect;
      answerStates[questionModel!.correctIndex] = AnswerState.correct;
    }
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentQuestionIndex < _questionIds.length - 1) {
      _currentQuestionIndex++;
      _loadQuestion();
    } else {
      _levelEnd();
    }
  }

  void _levelEnd() {
    if (_correctAnswers == _questionIds.length) {
      if (_currentLevel < 3) {
        _currentLevel++;
        _setState(TriviaState.levelUp);
      } else {
        _setState(TriviaState.gameFinished);
      }
    } else {
      _setState(TriviaState.repeatLevel);
    }
  }

  void nextLevel() {
    _loadQuestionsForCurrentLevel();
  }

  void repeatLevel() {
    _loadQuestionsForCurrentLevel();
  }

  void restartGame() {
    _currentLevel = 1;
    _loadQuestionsForCurrentLevel();
  }

  void _setState(TriviaState newState) {
    _state = newState;
    notifyListeners();
  }
}
