import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:alzheimer_games_app/features/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

// Mocks
class MockUserRepository extends Mock implements UserRepository {}
class MockFbUser extends Mock implements fb_auth.User {} // Mock for firebase_auth.User
class MockFirebaseAuth extends Mock implements fb_auth.FirebaseAuth {} // Mock for FirebaseAuth

// Global GetIt instance
final getIt = GetIt.instance;

void main() {
  // Declare mocks to be used in tests
  late MockUserRepository mockUserRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFbUser mockFbUser;

  setUp(() {
    // Initialize mocks before each test
    mockUserRepository = MockUserRepository();
    mockFirebaseAuth = MockFirebaseAuth(); // Initialize mockFirebaseAuth
    mockFbUser = MockFbUser();           // Initialize mockFbUser

    // Reset GetIt before each test to ensure a clean state
    getIt.reset();

    // Register mock UserRepository with GetIt
    getIt.registerLazySingleton<UserRepository>(() => mockUserRepository);

    // Setup default stubs for FirebaseAuth and User
    // This mockFirebaseAuth instance is NOT automatically used by `fb_auth.FirebaseAuth.instance`
    // The ProfileScreen calls `fb_auth.FirebaseAuth.instance` directly.
    // This is a known limitation when not using a specific FirebaseAuth mocking library.
    // We will stub the methods on `mockFbUser` which might be returned by a mock auth instance if we could inject it.
    when(mockFbUser.email).thenReturn('testuser@example.com'); // Default email for tests
    when(mockFbUser.displayName).thenReturn('Test User');      // Default display name
    when(mockFbUser.uid).thenReturn('test_uid_123');           // Default UID

    // Stub `mockFirebaseAuth.currentUser` to return `mockFbUser`.
    // This is useful if we could somehow make `fb_auth.FirebaseAuth.instance` return `mockFirebaseAuth`.
    when(mockFirebaseAuth.currentUser).thenReturn(mockFbUser);

    // WORKAROUND for `FirebaseAuth.instance`:
    // Since we cannot easily replace `FirebaseAuth.instance` itself without a library like `firebase_auth_mocks`
    // or modifying the app code to inject FirebaseAuth, tests relying on `FirebaseAuth.instance.currentUser.email`
    // will be affected. For the purpose of these tests, we will proceed by:
    // 1. Assuming `FirebaseAuth.instance.currentUser` might be null or a real user if the test environment has one.
    // 2. For the email TextField, we will primarily check for its existence rather than a specific value
    //    unless we can reliably mock `FirebaseAuth.instance`.
    // As a best-effort, if `firebase_auth_mocks` were available, we would use it.
    // Here, we acknowledge that the email field's value test might be flaky or test against a real logged-in user.
  });

  tearDown(() {
    // Reset GetIt after each test
    getIt.reset();
  });

  // Helper function to pump the ProfileScreen widget within a MaterialApp
  Future<void> pumpProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('Loading state shows CircularProgressIndicator', (WidgetTester tester) async {
    // Arrange
    when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async {
      // Simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));
      return PlayerModel(uid: '1', userName: 'Loading User', email: 'loading@example.com');
    });

    await pumpProfileScreen(tester);
    // Pump for a short duration to ensure the loading state is picked up
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Allow the Future to complete
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  });

  testWidgets('Error state shows error message', (WidgetTester tester) async {
    // Arrange
    when(mockUserRepository.getCurrentPlayer()).thenThrow(Exception('Failed to fetch user'));

    await pumpProfileScreen(tester);
    // Pump and settle to allow all frames to render, including error UI
    await tester.pumpAndSettle();

    // Assert
    expect(find.textContaining('Error al cargar los datos del usuario: Exception: Failed to fetch user'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Data displayed state shows user information and scores', (WidgetTester tester) async {
    // Arrange
    final player = PlayerModel(
      uid: 'player1',
      userName: 'TestPlayer',
      email: 'player.email@example.com', // This email is part of PlayerModel, not used in email field
      scoreMemory: 100,
      scorePuzzle: 150,
      scoreTrivia: 200,
      scorePattern: 250,
    );
    when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async => player);

    // Regarding FirebaseAuth.instance.currentUser.email:
    // As stated in setUp, we cannot easily mock this without firebase_auth_mocks or code changes.
    // For this test, we will assume `FirebaseAuth.instance.currentUser` might be null.
    // The `initialValue` in the TextFormField is `FirebaseAuth.instance.currentUser?.email ?? ''`.
    // So, if `currentUser` is null, it will display an empty string.
    // If a user *is* logged into the test environment (e.g. via a previous test or manual login),
    // their email will appear. This makes asserting a specific email value tricky.
    // We will assert that the TextFormField for email exists.

    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    // Assert Username (from PlayerModel)
    expect(find.widgetWithText(TextFormField, 'TestPlayer'), findsOneWidget);

    // Assert Email TextFormField exists
    // We find the TextFormField by its labelText 'Correo electrónico' as its value is unpredictable.
    final emailFieldFinder = find.ancestor(
      of: find.text('Correo electrónico'),
      matching: find.byType(TextFormField),
    );
    expect(emailFieldFinder, findsOneWidget);
    // To check the actual email value, if a mock user was reliably injected for FirebaseAuth.instance:
    // TextFormField emailFieldValue = tester.widget<TextFormField>(emailFieldFinder);
    // expect(emailFieldValue.initialValue, 'testuser@example.com'); // This would be ideal

    expect(find.text('Puntuaciones'), findsOneWidget);
    expect(find.text('Memoria'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Puzzle'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('Trivia'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('Patrón'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('Error al cargar los datos del usuario'), findsNothing);
  });

  testWidgets('Null scores are displayed as 0', (WidgetTester tester) async {
    // Arrange
    final playerWithNullScores = PlayerModel(
      uid: 'player2',
      userName: 'NullScorePlayer',
      email: 'null.score.player@example.com',
      scoreMemory: null,
      scorePuzzle: 75,
      scoreTrivia: null,
      scorePattern: 125,
    );
    when(mockUserRepository.getCurrentPlayer()).thenAnswer((_) async => playerWithNullScores);

    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    // Assert Username
    expect(find.widgetWithText(TextFormField, 'NullScorePlayer'), findsOneWidget);
    
    // Assert Email TextFormField exists (value is unpredictable as per previous test)
    final emailFieldFinder = find.ancestor(
      of: find.text('Correo electrónico'),
      matching: find.byType(TextFormField),
    );
    expect(emailFieldFinder, findsOneWidget);

    expect(find.text('Puntuaciones'), findsOneWidget);

    // Check scores, expecting '0' for null values.
    // Using helper to find score text within its specific row.
    WidgetPredicate findScoreInRow(String gameName, String scoreValue) {
      return (Widget widget) {
        if (widget is Row) {
          final rowChildren = <Widget>[];
          widget.children.forEach((child) {
            if (child is Expanded) { // Assuming score name/value might be wrapped in Expanded
              rowChildren.add(child.child);
            } else {
              rowChildren.add(child);
            }
          });

          bool hasGameName = false;
          bool hasScoreValue = false;
          for (var child in rowChildren) {
            if (child is Text && child.data == gameName) hasGameName = true;
            if (child is Text && child.data == scoreValue) hasScoreValue = true;
          }
          // A more robust way would be to find by specific Text widgets within the Row context.
          // This simplified check assumes direct Text children or Expanded > Text.
          // For the actual UI: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(gameName), Text(score)])
          // So, we can find Text(gameName) and then its sibling Text(scoreValue) within the Row.
          // This predicate is a bit too broad. Let's refine.
          return false; // Placeholder, will use specific finders below.
        }
        return false;
      };
    }

    // More specific assertions for scores:
    final memoryRowFinder = find.widgetWithText(Row, 'Memoria');
    expect(find.descendant(of: memoryRowFinder, matching: find.text('0')), findsOneWidget);
    
    final puzzleRowFinder = find.widgetWithText(Row, 'Puzzle');
    expect(find.descendant(of: puzzleRowFinder, matching: find.text('75')), findsOneWidget);

    final triviaRowFinder = find.widgetWithText(Row, 'Trivia');
    expect(find.descendant(of: triviaRowFinder, matching: find.text('0')), findsOneWidget);

    final patternRowFinder = find.widgetWithText(Row, 'Patrón');
    expect(find.descendant(of: patternRowFinder, matching: find.text('125')), findsOneWidget);
    
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
