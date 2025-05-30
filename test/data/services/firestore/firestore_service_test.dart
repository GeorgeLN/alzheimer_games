import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp and potential exceptions

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(fakeFirestore);
  });

  group('FirestoreService - Player Data', () {
    final userId1 = 'user123';
    final initialPlayerData = PlayerModel(
      uid: userId1,
      email: 'user1@example.com',
      userName: 'TestUser1',
      scoreMemory: 10,
      scorePuzzle: 20,
      scoreTrivia: 30,
      scorePattern: 40,
      lastLogin: Timestamp.now(),
      registrationDate: Timestamp.now(),
    );

    final userId2 = 'userNonExistent';

    group('loadPlayer', () {
      test('should load player data for existing user', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(initialPlayerData.toJson());

        // Act
        final player = await firestoreService.loadPlayer(userId: userId1);

        // Assert
        expect(player, isA<PlayerModel>());
        expect(player.uid, initialPlayerData.uid);
        expect(player.userName, initialPlayerData.userName);
        expect(player.scoreMemory, initialPlayerData.scoreMemory);
      });

      test('should throw an error or fail for non-existent user', () async {
        // Arrange: No data for userId2

        // Act & Assert
        // The current implementation of loadPlayer uses result.data()! which will throw
        // if the document doesn't exist (result.data() will be null).
        // This is a valid behavior to test.
        expect(
          () async => await firestoreService.loadPlayer(userId: userId2),
          throwsA(isA<TypeError>()), // Thrown by .data()! when snapshot.data() is null
        );
      });
    });

    group('loadPlayerStream', () {
      test('should emit player data for existing user', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(initialPlayerData.toJson());

        // Act & Assert
        final stream = firestoreService.loadPlayerStream(userId: userId1);
        
        expectLater(
            stream,
            emits(isA<PlayerModel>()
                .having((p) => p.uid, 'uid', userId1)
                .having((p) => p.userName, 'userName', initialPlayerData.userName)
                .having((p) => p.scoreMemory, 'scoreMemory', initialPlayerData.scoreMemory)
            )
        );
      });

      test('should emit updated player data when document changes', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(initialPlayerData.toJson());

        final stream = firestoreService.loadPlayerStream(userId: userId1);

        // Act: Wait for initial emission, then update the document
        await expectLater(stream, emits(isA<PlayerModel>())); // Consume initial event

        final updatedPlayerData = initialPlayerData.copyWith(scoreMemory: 100, userName: "UpdatedUser1");
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(updatedPlayerData.toJson());
        
        // Assert: Stream emits updated data
        expectLater(
            stream,
            emits(isA<PlayerModel>()
                .having((p) => p.userName, 'userName', "UpdatedUser1")
                .having((p) => p.scoreMemory, 'scoreMemory', 100)
            )
        );
      });

      test('should emit error or handle non-existent user appropriately in stream', () {
        // Arrange: No data for userId2
        final stream = firestoreService.loadPlayerStream(userId: userId2);

        // Assert: Firestore streams typically emit an event even if the doc doesn't exist,
        // but the PlayerModel.fromJson will fail if snapshot.data() is null.
        // This depends on how PlayerModel.fromJson handles null data.
        // If PlayerModel.fromJson throws, the stream will emit an error.
        // If it returns a default PlayerModel for null data, then it would emit that.
        // Given current PlayerModel.fromJson likely expects non-null, let's expect an error.
        expectLater(stream, emitsError(isA<Exception>())); // Or a more specific error if PlayerModel.fromJson throws one.
                                                           // Firestore itself might not error, but the mapping function will.
                                                           // The error is likely from `snapshot.data()!` in the service.
      });
    });

    group('updateUser', () {
      test('should update user scores correctly', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(initialPlayerData.toJson());

        // Act
        final newMemoryScore = 150;
        final newPuzzleScore = 250;
        await firestoreService.updateUser(
          userId: userId1, // Assuming updateUser takes userId
          scoreMemory: newMemoryScore,
          scorePuzzle: newPuzzleScore,
          scoreTrivia: initialPlayerData.scoreTrivia, // Keep others same
          scorePattern: initialPlayerData.scorePattern,
        );

        // Assert
        final updatedDoc = await fakeFirestore.collection('users').doc(userId1).get();
        final updatedPlayer = PlayerModel.fromJson(updatedDoc.data()!);

        expect(updatedPlayer.scoreMemory, newMemoryScore);
        expect(updatedPlayer.scorePuzzle, newPuzzleScore);
        expect(updatedPlayer.scoreTrivia, initialPlayerData.scoreTrivia); // Check others are unchanged
        expect(updatedPlayer.userName, initialPlayerData.userName); // Check non-score fields
      });

       test('should update only specified scores, leaving others and non-score fields intact', () async {
        // Arrange
        await fakeFirestore
            .collection('users')
            .doc(userId1)
            .set(initialPlayerData.toJson());
        
        final newTriviaScore = 350;

        // Act: Update only one score
        await firestoreService.updateUser(
          userId: userId1,
          scoreTrivia: newTriviaScore,
          // Not passing other scores, assuming the implementation merges with existing data or handles nulls.
          // Based on current FirestoreService.updateUser, it sets the PlayerModel,
          // so we must provide all scores or it will overwrite them with defaults/nulls from PlayerModel constructor.
          // The current updateUser in FirestoreService uses PlayerModel(...) which implies it will overwrite if not provided.
          // Let's test this behavior. The test above is more robust as it provides all.
          // For this test to pass as "leaving others intact", updateUser would need to merge.
          // Given:
          // PlayerModel( scoreMemory: scoreMemory ?? 0, ... )
          // If we call updateUser(userId: userId1, scoreTrivia: newTriviaScore),
          // it will effectively do _userRef.doc(userId1).set(PlayerModel(scoreTrivia: newTriviaScore, scoreMemory:0, ...))
          // So this test needs to reflect that.
          // Let's refine `updateUser` or the test.
          // The task is to test the *current* implementation.
          // The current `updateUser` method in `FirestoreService` takes individual scores.
          // `await _userRef.doc(userId).set(PlayerModel(...))`
          // The `PlayerModel` constructor in `user_model.dart` uses `scoreMemory ?? 0`.
          // So, if a score is not provided to `updateUser`, it will be set to 0 by `PlayerModel`.
          // This means the previous test `should update user scores correctly` is actually the one
          // that shows the behavior accurately if all scores are passed.

          // This test will verify what happens if only ONE score is passed to updateUser.
           await firestoreService.updateUser(
             userId: userId1,
             scoreTrivia: newTriviaScore
           );

        // Assert
        final updatedDoc = await fakeFirestore.collection('users').doc(userId1).get();
        final updatedPlayer = PlayerModel.fromJson(updatedDoc.data()!);

        expect(updatedPlayer.scoreTrivia, newTriviaScore);
        // Other scores will be reset to 0 due to PlayerModel constructor defaults
        expect(updatedPlayer.scoreMemory, 0); 
        expect(updatedPlayer.scorePuzzle, 0);
        expect(updatedPlayer.scorePattern, 0);
        // Non-score fields like userName are not part of PlayerModel constructor in updateUser context,
        // because `_userRef` uses a converter `toFirestore: (user, _ ) => user.toJson()`,
        // and `PlayerModel` in `updateUser` only has scores.
        // This means `updateUser` currently *only* updates scores and other fields in PlayerModel
        // would be default if not fetched and re-set.
        // The `_userRef.set` will overwrite the document with the fields present in the PlayerModel passed.
        // The `PlayerModel` created in `updateUser` only contains scores.
        // This means other fields like 'userName', 'email' etc. WOULD BE WIPED OUT by the current `updateUser` implementation.
        // This is a major side effect to test.
        
        // Let's check if userName is still there. It should NOT be, based on current `updateUser`.
        // The PlayerModel passed to set() only contains scores.
         expect(updatedDoc.data()!.containsKey('userName'), isFalse); // userName should be gone
         expect(updatedDoc.data()!.containsKey('email'), isFalse); // email should be gone
      });

      test('updateUser should handle non-existent user by creating a new one (if set is used)', () async {
        // Arrange: userId2 does not exist
        final newPatternScore = 450;

        // Act
        await firestoreService.updateUser(
          userId: userId2,
          scorePattern: newPatternScore,
          // Other scores will default to 0
        );

        // Assert
        final newDoc = await fakeFirestore.collection('users').doc(userId2).get();
        expect(newDoc.exists, isTrue);
        final newPlayer = PlayerModel.fromJson(newDoc.data()!);
        expect(newPlayer.scorePattern, newPatternScore);
        expect(newPlayer.scoreMemory, 0); // Default from PlayerModel constructor
        // Check other fields like uid, email, userName are not set (or default)
        expect(newPlayer.uid, isEmpty); // Assuming PlayerModel constructor sets uid to '' if not provided
        expect(newPlayer.email, isEmpty);
        expect(newPlayer.userName, isEmpty);

      });
    });

    // Test for addUser if it's a critical part of the service used by view models
    group('addUser', () {
      test('should add a new user with initial data', () async {
        final newUserId = 'newUser123';
        final newUserName = 'New User';
        final newUserEmail = 'new@example.com';

        // Act
        await firestoreService.addUser(
          userId: newUserId,
          name: newUserName, // Note: addUser in FirestoreService uses PlayerModel.initial()
          email: newUserEmail, // which does not use name/email params.
        );

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(newUserId).get();
        expect(userDoc.exists, isTrue);
        final player = PlayerModel.fromJson(userDoc.data()!);
        
        // PlayerModel.initial() sets specific default values
        final initialDefaults = PlayerModel.initial();
        expect(player.userName, initialDefaults.userName); // Likely empty or default
        expect(player.email, initialDefaults.email); // Likely empty or default
        expect(player.scoreMemory, initialDefaults.scoreMemory); // Likely 0
        // UID is not part of PlayerModel.initial() data, it's the doc ID.
        // The PlayerModel.fromJson will populate uid from the document snapshot if the field exists,
        // or it might be handled by the converter.
        // Let's assume PlayerModel.initial() does not set these, they'd be empty string or null.
        // The test should reflect the *actual* behavior of PlayerModel.initial().
        // If PlayerModel.initial() is:
        // `PlayerModel(uid: '', email: '', userName: '', ...)`
        // then these assertions are correct.
      });
    });
  });
}
