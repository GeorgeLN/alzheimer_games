
import 'package:alzheimer_games_app/data/models/game_model/question_model.dart';
import 'package:alzheimer_games_app/data/models/models.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';

class QuestionRepository {
  
  QuestionRepository({
    required this.firestoreService,
  });

  final FirestoreService firestoreService;

  //LOAD
  Future<QuestionModel> loadQuestion({required String questionId}) async {
    return firestoreService.loadQuestion(gameId: questionId);
  }

  Future<List<String>> loadListQuestions({required int level}) async {
    return firestoreService.loadListQuestions(level: level);
  }
}