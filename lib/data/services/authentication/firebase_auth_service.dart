import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  // Constructor para permitir la inyección de FirebaseAuth (para pruebas)
  // y usar la instancia por defecto en producción.
  FirebaseAuthService({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream para escuchar los cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Iniciar sesión con correo y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth aquí si es necesario
      // Por ejemplo, usuario no encontrado, contraseña incorrecta
      print('Error de inicio de sesión: ${e.message}');
      return null;
    } catch (e) {
      print('Ocurrió un error inesperado durante el inicio de sesión: $e');
      return null;
    }
  }

  // Registrar un nuevo usuario con correo y contraseña
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth aquí si es necesario
      // Por ejemplo, correo ya en uso, contraseña débil
      print('Error de registro: ${e.message}');
      return null;
    } catch (e) {
      print('Ocurrió un error inesperado durante el registro: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Ocurrió un error durante el cierre de sesión: $e');
    }
  }
}
