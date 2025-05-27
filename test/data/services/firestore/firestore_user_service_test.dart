import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreUserService firestoreUserService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    
    // Inyectar el mock de FirebaseFirestore
    firestoreUserService = FirestoreUserService(firestore: mockFirestore); 

    // Configuración general de los mocks para que devuelvan otros mocks
    when(() => mockFirestore.collection(any())).thenReturn(mockCollectionReference);
    when(() => mockCollectionReference.doc(any())).thenReturn(mockDocumentReference);
  });

  final testPlayerModel = PlayerModel(
    userId: 'testUserId',
    userName: 'Test User',
    scoreMemory: 0,
    scorePattern: 0,
    scorePuzzle: 0,
    scoreTrivia: 0,
  );
  final testPlayerData = testPlayerModel.toJson();

  group('FirestoreUserService Tests', () {
    group('createUserDocument', () {
      test('debería completarse exitosamente cuando los datos son válidos', () async {
        when(() => mockDocumentReference.set(testPlayerData)).thenAnswer((_) async {});
        
        await expectLater(firestoreUserService.createUserDocument(testPlayerModel), completes);
        verify(() => mockDocumentReference.set(testPlayerData)).called(1);
      });

      test('debería lanzar ArgumentError si userId es nulo', () async {
        final playerWithNullId = PlayerModel(userId: null, userName: 'Test');
        // expect is used for synchronous exceptions
        expect(() => firestoreUserService.createUserDocument(playerWithNullId), throwsArgumentError);
        verifyNever(() => mockDocumentReference.set(any()));
      });
      
      test('debería lanzar ArgumentError si userId está vacío', () async {
        final playerWithEmptyId = PlayerModel(userId: '', userName: 'Test');
        expect(() => firestoreUserService.createUserDocument(playerWithEmptyId), throwsArgumentError);
        verifyNever(() => mockDocumentReference.set(any()));
      });

      test('debería relanzar FirebaseException en error de Firestore', () async {
        final exception = FirebaseException(plugin: 'test', message: 'Firestore error');
        when(() => mockDocumentReference.set(testPlayerData)).thenThrow(exception);
        
        expect(() => firestoreUserService.createUserDocument(testPlayerModel), throwsA(isA<FirebaseException>()));
      });

      test('debería relanzar Exception en error general', () async {
        final exception = Exception('Generic error');
        when(() => mockDocumentReference.set(testPlayerData)).thenThrow(exception);

        expect(() => firestoreUserService.createUserDocument(testPlayerModel), throwsA(isA<Exception>()));
      });
    });

    group('getUserDocument', () {
      test('debería devolver PlayerModel si el documento existe', () async {
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(() => mockDocumentSnapshot.data()).thenReturn(testPlayerData);
        when(() => mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        
        final result = await firestoreUserService.getUserDocument('testUserId');
        
        expect(result, isA<PlayerModel>());
        expect(result?.userId, testPlayerModel.userId);
        expect(result?.userName, testPlayerModel.userName);
      });

      test('debería devolver null si el documento no existe', () async {
        when(() => mockDocumentSnapshot.exists).thenReturn(false);
        when(() => mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
        
        final result = await firestoreUserService.getUserDocument('nonExistentUserId');
        expect(result, null);
      });
      
      // La prueba para userId nulo no es aplicable directamente a la firma del método que espera String.
      // El chequeo de isEmpty es el relevante para ArgumentError.
      // test('debería lanzar ArgumentError si userId es nulo', () async { ... });

      test('debería lanzar ArgumentError si userId está vacío', () async {
        // El método getUserDocument ahora toma String userId, no String? userId
        // Por lo tanto, no se puede pasar null directamente.
        // El error se captura si la cadena está vacía.
        expect(() => firestoreUserService.getUserDocument(''), throwsArgumentError);
        verifyNever(() => mockDocumentReference.get());
      });

      test('debería devolver null y loguear en FirebaseException', () async {
        final exception = FirebaseException(plugin: 'test', message: 'Firestore error');
        when(() => mockDocumentReference.get()).thenThrow(exception);
        
        final result = await firestoreUserService.getUserDocument('testUserId');
        expect(result, null);
        // Verificar log si es posible (requeriría inyectar un logger y mockearlo)
      });

      test('debería devolver null y loguear en Exception general', () async {
        final exception = Exception('Generic error');
        when(() => mockDocumentReference.get()).thenThrow(exception);

        final result = await firestoreUserService.getUserDocument('testUserId');
        expect(result, null);
        // Verificar log si es posible
      });
    });
  });
}
