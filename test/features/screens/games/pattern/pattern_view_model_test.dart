import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/features/screens/games/pattern/pattern_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Assuming the mocks are generated in a shared file or a specific one for this test.
// For this example, let's assume it's generated in a way accessible like this:
// (Adjust if your project structure for mocks is different, e.g., a common mocks file)
@GenerateNiceMocks([MockSpec<UserRepository>()])
import '../memorama/memorama_view_model_test.mocks.dart'; // Re-using from memorama if in same dir or use a common one

void main() {
  late PatternViewModel viewModel;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository(); // This would be the generated mock class
    viewModel = PatternViewModel(userRepository: mockUserRepository);
  });

  final testPlayer = PlayerModel(
    userId: 'testUserPattern',
    userName: 'Pattern Tester',
    scoreMemory: 50,
    scorePuzzle: 100,
    scoreTrivia: 150,
    scorePattern: 200, // Initial pattern score
  );
  const newPatternScore = 250;

  group('PatternViewModel - saveGameScore', () {
    test('should call UserRepository.getCurrentPlayer and UserRepository.updateUser with correct scores', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async => testPlayer);
      when(mockUserRepository.updateUser(
        // userId is handled internally by updateUser
        scoreMemory: anyNamed('scoreMemory'),
        scorePuzzle: anyNamed('scorePuzzle'),
        scoreTrivia: anyNamed('scoreTrivia'),
        scorePattern: anyNamed('scorePattern'),
      )).thenAnswer((_) async {}); // Simulate successful update

      // Act
      await viewModel.saveGameScore(newPatternScore);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: testPlayer.scorePuzzle,
        scoreTrivia: testPlayer.scoreTrivia,
        scorePattern: newPatternScore, // New pattern score
      )).called(1);
    });

    test('should handle error when UserRepository.getCurrentPlayer throws an exception', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenThrow(Exception('Failed to get current player for pattern'));

      // Act
      await expectLater(viewModel.saveGameScore(newPatternScore), completes);
      
      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verifyNever(mockUserRepository.updateUser(
        scoreMemory: anyNamed('scoreMemory'),
        scorePuzzle: anyNamed('scorePuzzle'),
        scoreTrivia: anyNamed('scoreTrivia'),
        scorePattern: anyNamed('scorePattern'),
      ));
    });

    test('should handle error when UserRepository.updateUser throws an exception', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async => testPlayer);
      when(mockUserRepository.updateUser(
        scoreMemory: anyNamed('scoreMemory'),
        scorePuzzle: anyNamed('scorePuzzle'),
        scoreTrivia: anyNamed('scoreTrivia'),
        scorePattern: anyNamed('scorePattern'),
      )).thenThrow(Exception('Failed to update user for pattern'));

      // Act
      await expectLater(viewModel.saveGameScore(newPatternScore), completes);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: testPlayer.scorePuzzle,
        scoreTrivia: testPlayer.scoreTrivia,
        scorePattern: newPatternScore,
      )).called(1);
    });
  });
}

// Note on Mocks:
// The import `../memorama/memorama_view_model_test.mocks.dart` assumes that
// the @GenerateNiceMocks for UserRepository was already done for the Memorama tests
// and the generated file is located there and contains MockUserRepository.
// If UserRepository mock is generated in a different common location, adjust the import.
// If it needs to be generated specifically for this test, the @GenerateNiceMocks
// annotation would be here, and the import would be 'pattern_view_model_test.mocks.dart'.
// For simplicity and to avoid re-defining the annotation if it's already effectively
// covered by the Memorama test's mock generation, I'm re-using the import path.
// This implies that `memorama_view_model_test.mocks.dart` contains the necessary `MockUserRepository`.
// If this assumption is wrong, the import path would need to be:
// import 'pattern_view_model_test.mocks.dart';
// and the @GenerateNiceMocks annotation would be specific to this file.
// Given the environment, the actual generation isn't happening, so this is a structural setup.
// I'll proceed with the assumption that `memorama_view_model_test.mocks.dart` can be "reused"
// for the `MockUserRepository` class definition. In a real scenario, you'd either have a
// central mock file or generate per-test-suite.
//
// Corrected approach for clarity if this were a standalone test file needing its own mocks:
// (Remove the import '../memorama/memorama_view_model_test.mocks.dart';)
// (Add @GenerateNiceMocks([MockSpec<UserRepository>()]) here)
// (Add import 'pattern_view_model_test.mocks.dart';)
//
// For this exercise, I'll stick to the provided structure assuming the mock definition is somehow resolved
// by the existing memorama test mock generation.
// The critical part is the test logic itself.
// If I were to ensure this file is self-contained for mock generation, I would do:
// @GenerateNiceMocks([MockSpec<UserRepository>()])
// import 'pattern_view_model_test.mocks.dart'; // And ensure this file is created
// For now, I will use the memorama one as a placeholder for the mock definitions.
// This is a limitation of not being able to run build_runner.
// The best practice would be a shared mock file or per-suite generation.
// Let's assume `../memorama/memorama_view_model_test.mocks.dart` is effectively providing `MockUserRepository`.
