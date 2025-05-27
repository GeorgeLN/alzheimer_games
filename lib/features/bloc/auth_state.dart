import 'package:firebase_auth/firebase_auth.dart'; // Necesario para el tipo User
import 'package:equatable/equatable.dart';

// Clase base abstracta para los estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial: aún no se ha determinado el estado de autenticación
class AuthInitial extends AuthState {}

// Estado de carga: se está procesando una operación de autenticación (login, signup)
class AuthLoading extends AuthState {}

// Estado autenticado: el usuario ha iniciado sesión correctamente
class Authenticated extends AuthState {
  final User user; // Información del usuario de Firebase

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Estado no autenticado: el usuario no está conectado o ha cerrado sesión
class Unauthenticated extends AuthState {}

// Estado de error: ocurrió un problema durante la autenticación
class AuthError extends AuthState {
  final String message; // Mensaje de error

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
