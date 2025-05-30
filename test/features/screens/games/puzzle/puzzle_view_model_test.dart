import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/features/screens/games/puzzle/puzzle_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Assuming the mocks are generated in a shared file or a specific one for this test.
// Re-using from memorama if in same dir or use a common one.
// Adjust if your project structure for mocks is different.
@GenerateNiceMocks([MockSpec<UserRepository>()])
import '../memorama/memorama_view_model_test.mocks.dart'; 

void main() {
  late PuzzleViewModel viewModel;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository(); // Generated mock class
    viewModel = PuzzleViewModel(userRepository: mockUserRepository);
  });

  final testPlayer = PlayerModel(
    userId: 'testUserPuzzle',
    userName: 'Puzzle Tester',
    scoreMemory: 50,
    scorePuzzle: 0, // Initial puzzle score (or any value)
    scoreTrivia: 150,
    scorePattern: 200,
  );
  const newPuzzleScore = 100; // Puzzle score is always 100 upon completion

  group('PuzzleViewModel - saveGameScore', () {
    test('should call UserRepository.getCurrentPlayer and UserRepository.updateUser with correct scores', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async => testPlayer);
      when(mockUserRepository.updateUser(
        scoreMemory: anyNamed('scoreMemory'),
        scorePuzzle: anyNamed('scorePuzzle'),
        scoreTrivia: anyNamed('scoreTrivia'),
        scorePattern: anyNamed('scorePattern'),
      )).thenAnswer((_) async {}); // Simulate successful update

      // Act
      await viewModel.saveGameScore(newPuzzleScore);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: newPuzzleScore, // New puzzle score (100)
        scoreTrivia: testPlayer.scoreTrivia,
        scorePattern: testPlayer.scorePattern,
      )).called(1);
    });

    test('should handle error when UserRepository.getCurrentPlayer throws an exception', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenThrow(Exception('Failed to get current player for puzzle'));

      // Act
      await expectLater(viewModel.saveGameScore(newPuzzleScore), completes);
      
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
      )).thenThrow(Exception('Failed to update user for puzzle'));

      // Act
      await expectLater(viewModel.saveGameScore(newPuzzleScore), completes);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: newPuzzleScore,
        scoreTrivia: testPlayer.scoreTrivia,
        scorePattern: testPlayer.scorePattern,
      )).called(1);
    });
  });
}

// Note on Mocks:
// The import `../memorama/memorama_view_model_test.mocks.dart` is used here again
// with the assumption that `MockUserRepository` is defined there due to mock generation
// for the Memorama tests. In a real project, ensure this path is correct or use a
// centralized mock file, or generate mocks per test suite.
// If this file needed its own mock generation:
// 1. Remove: import '../memorama/memorama_view_model_test.mocks.dart';
// 2. Add here: @GenerateNiceMocks([MockSpec<UserRepository>()])
// 3. Add here: import 'puzzle_view_model_test.mocks.dart'; // (and run build_runner)
// This structure is due to the limitations of the current environment.
