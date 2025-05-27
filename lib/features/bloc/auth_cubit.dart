import 'dart:async';
import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/services/authentication/firebase_auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart'; // Importar los estados definidos

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthService _authService;
  final FirestoreUserService _userService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({
    required FirebaseAuthService authService,
    required FirestoreUserService userService,
  })  : _authService = authService,
        _userService = userService,
        super(AuthInitial()) {
    _monitorAuthStateChanges();
  }

  void _monitorAuthStateChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signUp(String email, String password, String userName) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
      if (userCredential?.user != null) {
        final newUser = PlayerModel.initial(
          userId: userCredential!.user!.uid,
          userName: userName,
        );
        await _userService.createUserDocument(newUser);
        // El Stream _monitorAuthStateChanges se encargará de emitir Authenticated
      } else {
        emit(const AuthError('No se pudo crear el usuario.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Error de autenticación desconocido.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential?.user == null) {
         emit(const AuthError('Credenciales incorrectas o error en el inicio de sesión.'));
      }
      // El Stream _monitorAuthStateChanges se encargará de emitir Authenticated si es exitoso
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Error de autenticación desconocido.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      // El Stream _monitorAuthStateChanges se encargará de emitir Unauthenticated
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Método para verificar el estado actual (puede ser útil al inicio)
  // Aunque _monitorAuthStateChanges ya hace esto al suscribirse.
  void checkInitialAuthStatus() {
    final currentUser = _authService.currentUser; // Asumiendo que FirebaseAuthService tiene un getter para currentUser
    if (currentUser != null) {
      emit(Authenticated(currentUser));
    } else {
      emit(Unauthenticated());
    }
  }


  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
