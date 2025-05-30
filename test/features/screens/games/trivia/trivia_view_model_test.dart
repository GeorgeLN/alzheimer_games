import 'package:alzheimer_games_app/data/models/models.dart';
import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Assuming MockUserRepository is already generated from memorama tests
// If not, it should be part of the @GenerateNiceMocks list here.
@GenerateNiceMocks([
  MockSpec<QuestionRepository>(),
  MockSpec<FirestoreService>(),
  MockSpec<AuthService>(),
  MockSpec<UserRepository>() // Explicitly including it here for clarity and self-containment if needed
])
// The import will be specific to this file if UserRepository wasn't mocked elsewhere
import 'trivia_view_model_test.mocks.dart'; 

void main() {
  late TriviaViewModel viewModel;
  late MockUserRepository mockUserRepository;
  late MockQuestionRepository mockQuestionRepository;
  late MockFirestoreService mockFirestoreService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockQuestionRepository = MockQuestionRepository();
    mockFirestoreService = MockFirestoreService();
    mockAuthService = MockAuthService();

    // Mock calls made by TriviaViewModel's initialize() method
    // to ensure a stable state if initialize() were to be called.
    // For testing saveGameScore in isolation, these might not be strictly necessary
    // if saveGameScore doesn't rely on state set by initialize(),
    // but it's safer to provide default behaviors for them.
    when(mockAuthService.getUserId()).thenAnswer((_) async => 'testUserId');
    when(mockFirestoreService.loadPlayerStream(userId: anyNamed('userId')))
        .thenAnswer((_) => Stream.value(PlayerModel(userId: 'testUserId', userName: 'Test User')));
    when(mockQuestionRepository.loadListQuestions()).thenAnswer((_) async => ['q1']);
    when(mockQuestionRepository.loadQuestion(questionId: anyNamed('questionId')))
        .thenAnswer((_) async => QuestionModel(id: 'q1', question: 'Test Question?', options: ['Opt1', 'Opt2'], correctIndex: 0));

    viewModel = TriviaViewModel(
      questionRepository: mockQuestionRepository,
      firestoreService: mockFirestoreService,
      authService: mockAuthService,
      userRepository: mockUserRepository,
    );
    // Call initialize if it's part of the standard setup for the ViewModel.
    // However, for `saveGameScore`, it re-fetches the player model, so `viewModel.playerModel` state from `initialize`
    // is not directly used by `saveGameScore`. So, calling `viewModel.initialize()` here is optional
    // for this specific test's scope, but might be needed for other ViewModel tests.
    // For now, we assume `saveGameScore` is self-contained enough with its own `getCurrentPlayer`.
  });

  final testPlayer = PlayerModel(
    userId: 'testUserTrivia',
    userName: 'Trivia Tester',
    scoreMemory: 50,
    scorePuzzle: 100,
    scoreTrivia: 150, // Initial trivia score
    scorePattern: 200,
  );
  const newTriviaScore = 180;

  group('TriviaViewModel - saveGameScore', () {
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
      await viewModel.saveGameScore(newTriviaScore);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: testPlayer.scorePuzzle,
        scoreTrivia: newTriviaScore, // New trivia score
        scorePattern: testPlayer.scorePattern,
      )).called(1);
    });

    test('should handle error when UserRepository.getCurrentPlayer throws an exception', () async {
      // Arrange
      when(mockUserRepository.getCurrentPlayer()).thenThrow(Exception('Failed to get current player for trivia'));

      // Act
      await expectLater(viewModel.saveGameScore(newTriviaScore), completes);
      
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
      )).thenThrow(Exception('Failed to update user for trivia'));

      // Act
      await expectLater(viewModel.saveGameScore(newTriviaScore), completes);

      // Assert
      verify(mockUserRepository.getCurrentPlayer()).called(1);
      verify(mockUserRepository.updateUser(
        scoreMemory: testPlayer.scoreMemory,
        scorePuzzle: testPlayer.scorePuzzle,
        scoreTrivia: newTriviaScore,
        scorePattern: testPlayer.scorePattern,
      )).called(1);
    });
  });
}
