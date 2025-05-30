
import 'package:alzheimer_games_app/data/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService(
    this.firestore,
  );

  final FirebaseFirestore firestore;

  CollectionReference<PlayerModel> get _userRef => firestore.collection('users').withConverter<PlayerModel>(
    fromFirestore: (snapshot, _ ) => PlayerModel.fromJson(snapshot.data()!),
    toFirestore: (user, _ ) => user.toJson(),
  );

  //CREATE
  Future<void> addUser ({
      String? userId,
      String? name,
      String? email,
    }) async {
    await _userRef.doc(userId!).set(
      PlayerModel.initial(userId: userId!, userName: name!),
    );
  }

  //READ
  Future<PlayerModel> loadPlayer ({
    final String user = 'OA504tapkjSaGRecQN5eLkfBLG13',
    required String userId,
  }) async {
    final result = await _userRef.doc(user).get();
    return result.data()!;
  }

  Stream<PlayerModel> loadPlayerStream ({
    final String user = 'OA504tapkjSaGRecQN5eLkfBLG13',
    required String userId,
  }) {
    return firestore.collection('users').doc(user).snapshots().map((snapshot) {
      return PlayerModel.fromJson(snapshot.data()!);
    });
  }

  //UPDATE
  Future<void> updateUser ({
    String? userId,
    int? scoreMemory,
    int? scoreTrivia,
    int? scorePuzzle,
    int? scorePattern,
  }) async {
    await _userRef.doc(
      userId
    ).set(
      PlayerModel(
        scoreMemory: scoreMemory ?? 0,
        scoreTrivia: scoreTrivia ?? 0,
        scorePuzzle: scorePuzzle ?? 0,
        scorePattern: scorePattern ?? 0,
      ),
    );
  }

  // SERVICES FOR TRIVIA GAME
  CollectionReference<QuestionModel> get _triviaRef => firestore.collection('trivia_questions').withConverter<QuestionModel>(
    fromFirestore: (snapshot, _ ) => QuestionModel.fromJson(snapshot.data()!),
    toFirestore: (question, _ ) => question.toJson(),
  );

  Future<QuestionModel> loadQuestion ({
    required String gameId,
  }) async {
    final result = await _triviaRef.doc(gameId).get();
    return result.data()!;
  }

  Future<List<String>> loadListQuestions() async {
    final result = await firestore.collection('trivia_questions').get();
    return result.docs.map((doc) => doc.id).toList();
  }
}