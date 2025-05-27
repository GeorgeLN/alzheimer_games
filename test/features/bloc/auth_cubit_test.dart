import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/services/authentication/firebase_auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_user_service.dart';
import 'package:alzheimer_games_app/features/bloc/auth_cubit.dart';
import 'package:alzheimer_games_app/features/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';


// Mocks
class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}
class MockFirestoreUserService extends Mock implements FirestoreUserService {}
class MockUser extends Mock implements User {
  @override
  final String uid = 'test_uid'; // Necesario para PlayerModel.initial y verificaciones
  @override
  final String email = 'test@example.com'; // Añadido por si es necesario
}
class MockUserCredential extends Mock implements UserCredential {}


void main() {
  late AuthCubit authCubit;
  late MockFirebaseAuthService mockAuthService;
  late MockFirestoreUserService mockUserService;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  
  // Un controlador de stream para simular authStateChanges
  late StreamController<User?> authStateController;

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
    mockUserService = MockFirestoreUserService();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authStateController = StreamController<User?>();

    // Configuración por defecto para los mocks
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateController.stream);
    when(() => mockAuthService.currentUser).thenReturn(null); // Estado inicial por defecto: no logueado
    when(() => mockUserCredential.user).thenReturn(mockUser);


    authCubit = AuthCubit(
      authService: mockAuthService,
      userService: mockUserService,
    );
  });

  tearDown(() {
    authStateController.close();
    authCubit.close();
  });

  group('AuthCubit Tests', () {
    // Test para el estado inicial del AuthCubit
    // Se espera que el estado sea AuthInitial justo después de la creación,
    // antes de que cualquier evento del stream authStateChanges sea procesado.
    test('estado inicial debería ser AuthInitial', () {
      // Es importante que el stream no emita nada síncronamente durante la creación del AuthCubit
      // para que esta prueba pase consistentemente.
      expect(authCubit.state, AuthInitial());
    });

    blocTest<AuthCubit, AuthState>(
      'debería emitir [Authenticated] cuando authStateChanges emite un User',
      setUp: () {
        // Asegura que el estado inicial no sea Authenticated por currentUser
        when(() => mockAuthService.currentUser).thenReturn(null); 
        // Re-crear el cubit aquí o asegurar que el `act` sea el primer emisor del stream
        // El AuthCubit ya está creado en el setUp general, y su stream está escuchando.
      },
      build: () => authCubit, // authCubit ya está escuchando authStateController.stream
      act: (cubit) => authStateController.add(mockUser),
      expect: () => [Authenticated(mockUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'debería emitir [Unauthenticated] cuando authStateChanges emite null',
       setUp: () {
        // Para simular un cambio de Authenticated a Unauthenticated,
        // primero simulamos que el usuario estaba autenticado.
        when(() => mockAuthService.currentUser).thenReturn(mockUser);
        // Recreamos el AuthCubit para que _monitorAuthStateChanges coja este currentUser
        // o podríamos emitir un usuario en el stream primero.
        // El cubit del setUp general ya está creado con currentUser siendo null.
        // Para esta prueba específica, es mejor controlar el flujo de estados.
        
        // Opción 1: Recrear el cubit después de cambiar currentUser (más limpio para el setup)
        // authCubit = AuthCubit(authService: mockAuthService, userService: mockUserService);
        // Esto haría que el estado inicial del cubit (después de procesar currentUser) sea Authenticated.
        
        // Opción 2: Emitir un User primero, luego null (más realista para el flujo)
        // No se necesita setUp adicional si el authCubit del setUp general se usa.
        // El estado inicial del cubit del setUp general será Unauthenticated (si checkInitialAuthStatus se llama o el stream emite null)
        // o AuthInitial.
        // Si el estado inicial es AuthInitial, y luego emitimos mockUser, luego null:
        // Esperaríamos: [Authenticated(mockUser), Unauthenticated()]
        // Si el estado inicial ya es Unauthenticated (porque currentUser es null y el stream no ha emitido User):
        // Esperaríamos: [Unauthenticated()] si el stream emite null directamente.
      },
      build: () => authCubit, // Usamos el cubit del setUp general.
      act: (cubit) {
        //authStateController.add(mockUser); // Opcional: para asegurar que estaba Authenticated
        authStateController.add(null); // Simula logout o que el stream emite null
      },
      // Si el estado inicial del cubit ya era Unauthenticated (currentUser=null), y el stream emite null,
      // el estado no cambiará si ya es Unauthenticated.
      // Si el AuthCubit comienza en AuthInitial, y el stream emite null, entonces espera [Unauthenticated()].
      // Si queremos probar el cambio de Authenticated -> Unauthenticated:
      // expect: () => [Authenticated(mockUser), Unauthenticated()]
      // Para ello, el `act` debería ser:
      // act: (cubit) {
      //   authStateController.add(mockUser);
      //   authStateController.add(null);
      // }
      // Dado que la prueba anterior cubre User -> Authenticated, esta puede cubrir null -> Unauthenticated
      expect: () => [Unauthenticated()],
    );
    
    group('checkInitialAuthStatus', () {
        blocTest<AuthCubit, AuthState>(
        'debería emitir [Authenticated] si currentUser no es null',
        setUp: () {
            when(() => mockAuthService.currentUser).thenReturn(mockUser);
            // El stream no debe emitir nada que interfiera.
        },
        // Construir un nuevo cubit para esta prueba específica es más aislado.
        build: () => AuthCubit(authService: mockAuthService, userService: mockUserService),
        act: (cubit) => cubit.checkInitialAuthStatus(), 
        expect: () => [Authenticated(mockUser)],
        );

        blocTest<AuthCubit, AuthState>(
        'debería emitir [Unauthenticated] si currentUser es null',
        setUp: () {
            when(() => mockAuthService.currentUser).thenReturn(null);
        },
        build: () => AuthCubit(authService: mockAuthService, userService: mockUserService),
        act: (cubit) => cubit.checkInitialAuthStatus(),
        expect: () => [Unauthenticated()],
        );
    });


    group('signUp', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password';
      const testName = 'Test User';

      blocTest<AuthCubit, AuthState>(
        'éxito: emite [AuthLoading], luego Authenticated (via stream)',
        setUp: () {
          when(() => mockAuthService.createUserWithEmailAndPassword(testEmail, testPassword))
              .thenAnswer((_) async => mockUserCredential); // mockUserCredential.user es mockUser
          when(() => mockUserService.createUserDocument(any(that: isA<PlayerModel>())))
              .thenAnswer((_) async {});
        },
        build: () => authCubit,
        act: (cubit) async {
          await cubit.signUp(testEmail, testPassword, testName);
          // Simular que Firebase Auth emite el nuevo usuario después del registro exitoso
          authStateController.add(mockUser); 
        },
        expect: () => [AuthLoading(), Authenticated(mockUser)],
        verify: (_) {
          verify(() => mockAuthService.createUserWithEmailAndPassword(testEmail, testPassword)).called(1);
          verify(() => mockUserService.createUserDocument(any(that: isA<PlayerModel>()
              .having((p) => p.userName, 'userName', testName)
              .having((p) => p.userId, 'userId', 'test_uid')))).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'falla (AuthService devuelve null UserCredential): emite [AuthLoading, AuthError]',
        setUp: () {
          when(() => mockAuthService.createUserWithEmailAndPassword(testEmail, testPassword))
              .thenAnswer((_) async => null); 
        },
        build: () => authCubit,
        act: (cubit) => cubit.signUp(testEmail, testPassword, testName),
        expect: () => [AuthLoading(), const AuthError('No se pudo crear el usuario.')],
      );
      
      blocTest<AuthCubit, AuthState>(
        'falla (AuthService lanza FirebaseAuthException): emite [AuthLoading, AuthError]',
        setUp: () {
          final exception = FirebaseAuthException(code: 'email-already-in-use', message: 'Email en uso');
          when(() => mockAuthService.createUserWithEmailAndPassword(testEmail, testPassword))
              .thenThrow(exception);
        },
        build: () => authCubit,
        act: (cubit) => cubit.signUp(testEmail, testPassword, testName),
        expect: () => [AuthLoading(), AuthError(exception.message ?? 'Error de autenticación desconocido.')],
      );

      blocTest<AuthCubit, AuthState>(
        'falla (UserService lanza Exception): emite [AuthLoading, AuthError]',
        setUp: () {
          final exception = Exception('Firestore error');
          when(() => mockAuthService.createUserWithEmailAndPassword(testEmail, testPassword))
              .thenAnswer((_) async => mockUserCredential);
          when(() => mockUserService.createUserDocument(any(that: isA<PlayerModel>())))
              .thenThrow(exception);
        },
        build: () => authCubit,
        act: (cubit) => cubit.signUp(testEmail, testPassword, testName),
        expect: () => [AuthLoading(), AuthError(exception.toString())],
      );
    });

    group('signIn', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password';

      blocTest<AuthCubit, AuthState>(
        'éxito: emite [AuthLoading], luego Authenticated (via stream)',
        setUp: () {
          when(() => mockAuthService.signInWithEmailAndPassword(testEmail, testPassword))
              .thenAnswer((_) async => mockUserCredential);
        },
        build: () => authCubit,
        act: (cubit) async {
          await cubit.signIn(testEmail, testPassword);
          // Simular que Firebase Auth emite el usuario después del login
          authStateController.add(mockUser);
        },
        expect: () => [AuthLoading(), Authenticated(mockUser)],
        verify: (_) {
          verify(() => mockAuthService.signInWithEmailAndPassword(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'falla (AuthService devuelve null UserCredential): emite [AuthLoading, AuthError]',
        setUp: () {
          when(() => mockAuthService.signInWithEmailAndPassword(testEmail, testPassword))
              .thenAnswer((_) async => null);
        },
        build: () => authCubit,
        act: (cubit) => cubit.signIn(testEmail, testPassword),
        expect: () => [AuthLoading(), const AuthError('Credenciales incorrectas o error en el inicio de sesión.')],
      );

      blocTest<AuthCubit, AuthState>(
        'falla (AuthService lanza FirebaseAuthException): emite [AuthLoading, AuthError]',
        setUp: () {
          final exception = FirebaseAuthException(code: 'user-not-found', message: 'Usuario no encontrado');
          when(() => mockAuthService.signInWithEmailAndPassword(testEmail, testPassword))
              .thenThrow(exception);
        },
        build: () => authCubit,
        act: (cubit) => cubit.signIn(testEmail, testPassword),
        expect: () => [AuthLoading(), AuthError(exception.message ?? 'Error de autenticación desconocido.')],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'éxito: emite [AuthLoading], luego Unauthenticated (via stream)',
        setUp: () {
          when(() => mockAuthService.signOut()).thenAnswer((_) async {});
           // Simular que el cubit estaba en estado Authenticated
          when(() => mockAuthService.currentUser).thenReturn(mockUser);
          authCubit = AuthCubit(authService: mockAuthService, userService: mockUserService);
          // Forzar el estado inicial a Authenticated para esta prueba
          authStateController.add(mockUser); 
        },
        build: () => authCubit,
        act: (cubit) async {
          await cubit.signOut();
          // Simular que Firebase Auth emite null después del logout
          authStateController.add(null);
        },
        // El primer Authenticated es por el setUp.
        // Luego AuthLoading por signOut, luego Unauthenticated por el stream.
        expect: () => [Authenticated(mockUser), AuthLoading(), Unauthenticated()],
        verify: (_) {
          verify(() => mockAuthService.signOut()).called(1);
        },
      );


       blocTest<AuthCubit, AuthState>(
        'falla (AuthService lanza Exception): emite [AuthLoading, AuthError]',
        setUp: () {
          final exception = Exception('Logout error');
          when(() => mockAuthService.signOut()).thenThrow(exception);
        },
        build: () => authCubit,
        act: (cubit) => cubit.signOut(),
        expect: () => [AuthLoading(), AuthError(exception.toString())],
      );
    });
  });
}
