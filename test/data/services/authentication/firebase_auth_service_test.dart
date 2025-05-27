import 'package:alzheimer_games_app/data/services/authentication/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late FirebaseAuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser; // Para el currentUser y authStateChanges
  late MockUserCredential mockUserCredential; // Para los retornos de signIn/createUser

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = FirebaseAuthService(firebaseAuth: mockFirebaseAuth);
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    // Configuración por defecto para UserCredential y User si es necesario
    // when(() => mockUserCredential.user).thenReturn(mockUser);
    // when(() => mockUser.uid).thenReturn('test_uid');
  });

  group('FirebaseAuthService Tests', () {
    
    group('currentUser', () {
      test('debería devolver User cuando _auth.currentUser no es null', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        expect(authService.currentUser, mockUser);
      });

      test('debería devolver null cuando _auth.currentUser es null', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);
        expect(authService.currentUser, null);
      });
    });

    group('authStateChanges', () {
      test('debería emitir User cuando el stream de Firebase emite User', () {
        when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
        expect(authService.authStateChanges, emits(mockUser));
      });

      test('debería emitir null cuando el stream de Firebase emite null', () {
         when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
        expect(authService.authStateChanges, emits(null));
      });
    });
    
    group('signInWithEmailAndPassword', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password';

      test('debería devolver UserCredential en caso de éxito', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: testEmail, password: testPassword))
            .thenAnswer((_) async => mockUserCredential);
        
        final result = await authService.signInWithEmailAndPassword(testEmail, testPassword);
        expect(result, mockUserCredential);
      });

      test('debería devolver null y loguear error en FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));
        
        final result = await authService.signInWithEmailAndPassword(testEmail, testPassword);
        expect(result, null);
        // Aquí podrías añadir expectAsync para verificar el log si tienes un logger inyectado
        // verify(() => logger.e(any(that: contains('Error de inicio de sesión')))).called(1); // Ejemplo
      });

       test('debería devolver null y loguear error en Exception general', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(Exception('Error genérico'));
        
        final result = await authService.signInWithEmailAndPassword(testEmail, testPassword);
        expect(result, null);
        // verify(() => logger.e(any(that: contains('Ocurrió un error inesperado')))).called(1); // Ejemplo
      });
    });

    group('createUserWithEmailAndPassword', () {
      const testEmail = 'newuser@example.com';
      const testPassword = 'newpassword';

      test('debería devolver UserCredential en caso de éxito', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: testEmail, password: testPassword))
            .thenAnswer((_) async => mockUserCredential);
        
        final result = await authService.createUserWithEmailAndPassword(testEmail, testPassword);
        expect(result, mockUserCredential);
      });

      test('debería devolver null y loguear error en FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
        
        final result = await authService.createUserWithEmailAndPassword(testEmail, testPassword);
        expect(result, null);
        // Verificar log
      });

       test('debería devolver null y loguear error en Exception general', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(Exception('Error genérico de creación'));
        
        final result = await authService.createUserWithEmailAndPassword(testEmail, testPassword);
        expect(result, null);
        // Verificar log
      });
    });

    group('signOut', () {
      test('debería completarse sin errores en caso de éxito', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {}); // Completa normalmente
        
        await expectLater(authService.signOut(), completes);
      });

      test('debería completarse y loguear error en caso de Exception', () async {
         when(() => mockFirebaseAuth.signOut()).thenThrow(Exception('Error al cerrar sesión'));

        // El método signOut en el servicio no relanza la excepción, solo la loguea.
        // Por lo tanto, la prueba debe esperar que se complete, no que lance un error.
        await expectLater(authService.signOut(), completes);
        // Verificar el log si es posible
      });
    });
  });
}
