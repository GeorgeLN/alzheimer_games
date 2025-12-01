
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
      PlayerModel.initial(userId: userId, userName: name!),
    );
  }

  //READ
  Future<PlayerModel> loadPlayer ({
    required String userId,
  }) async {
    final result = await _userRef.doc(userId).get();
    return result.data()!;
  }

  Stream<PlayerModel> loadPlayerStream ({
    required String userId,
  }) {
    return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
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
    int? scoreOtd,
  }) async {
    final Map<String, Object?> scoresToUpdate = {};
    if (scoreMemory != null) {
      scoresToUpdate['score_memory'] = scoreMemory;
    }
    if (scoreTrivia != null) {
      scoresToUpdate['score_trivia'] = scoreTrivia;
    }
    if (scorePuzzle != null) {
      scoresToUpdate['score_puzzle'] = scorePuzzle;
    }
    if (scorePattern != null) {
      scoresToUpdate['score_pattern'] = scorePattern;
    }
    if (scoreOtd != null) {
      scoresToUpdate['score_otd'] = scoreOtd;
    }

    if (scoresToUpdate.isNotEmpty) {
      // Ensure userId is not null or empty before attempting to update.
      if (userId != null && userId.isNotEmpty) {
        await _userRef.doc(userId).update(scoresToUpdate);
      } else {
        // Handle the case where userId is null or empty, perhaps log an error or throw an exception.
        print('Error: userId is null or empty in updateUser.');
        // Depending on desired behavior, you might want to throw an exception:
        // throw ArgumentError('userId cannot be null or empty for updateUser');
      }
    }
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

  Future<List<String>> loadListQuestions({required int level}) async {
    final result = await firestore.collection('trivia_questions').where('level', isEqualTo: level).get();
    return result.docs.map((doc) => doc.id).toList();
  }
}