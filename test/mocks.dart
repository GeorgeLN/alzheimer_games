import 'package:alzheimer_games_app/data/repositories/question_repository.dart';
import 'package:alzheimer_games_app/data/services/authentication/auth_service.dart';
import 'package:alzheimer_games_app/data/services/firestore/firestore_service.dart';
import 'package:mocktail/mocktail.dart';

class QuestionRepositoryMock extends Mock implements QuestionRepository {}

class AuthServiceMock extends Mock implements AuthService {}

class FirestoreServiceMock extends Mock implements FirestoreService {}

