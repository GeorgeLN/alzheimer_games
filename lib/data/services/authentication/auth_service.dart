
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(
    this._auth
  );

  final FirebaseAuth _auth;

  Future registerAcount(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user?.uid;
  }

  Future signInMailAndPass(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      
      if (user?.uid != null) {
        return user?.uid;
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-credential') {
        return 1;
      }
    }
  }

  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }
}