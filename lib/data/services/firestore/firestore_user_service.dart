import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzheimer_games_app/data/models/user_model/user_model.dart'; // Asegúrate que esta ruta sea correcta

class FirestoreUserService {
  final FirebaseFirestore _db;
  final String _collectionPath = 'users'; // Nombre de la colección en Firestore

  // Constructor para permitir la inyección de FirebaseFirestore (para pruebas)
  // y usar la instancia por defecto en producción.
  FirestoreUserService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  // Crear o actualizar un documento de usuario
  Future<void> createUserDocument(PlayerModel user) async {
    try {
      if (user.userId == null || user.userId!.isEmpty) {
        throw ArgumentError('El userId no puede ser nulo o vacío.');
      }
      await _db.collection(_collectionPath).doc(user.userId).set(user.toJson());
    } on FirebaseException catch (e) {
      // Manejar errores específicos de Firestore aquí si es necesario
      print('Error al crear/actualizar el documento de usuario: ${e.message}');
      rethrow; // O maneja el error de forma diferente
    } catch (e) {
      print('Ocurrió un error inesperado al crear/actualizar el documento de usuario: $e');
      rethrow; // O maneja el error de forma diferente
    }
  }

  // Obtener un documento de usuario
  Future<PlayerModel?> getUserDocument(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('El userId no puede ser nulo o vacío.');
      }
      DocumentSnapshot doc = await _db.collection(_collectionPath).doc(userId).get();
      if (doc.exists) {
        return PlayerModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        // El documento no existe
        print('No se encontró ningún usuario con el ID: $userId');
        return null;
      }
    } on FirebaseException catch (e) {
      // Manejar errores específicos de Firestore aquí si es necesario
      print('Error al obtener el documento de usuario: ${e.message}');
      return null;
    } catch (e) {
      print('Ocurrió un error inesperado al obtener el documento de usuario: $e');
      return null;
    }
  }
}
