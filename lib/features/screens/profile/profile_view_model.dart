
import 'package:flutter/material.dart';

import '../../../data/models/user_model/user_model.dart';
import '../../../data/repositories/user_repository.dart';

enum ProfileStatus {
  content,
  loading,
  error,
}

class ProfileViewModel with ChangeNotifier {
  var status = ProfileStatus.loading;
  final String userId;
  final UserRepository userRepository;
  PlayerModel? userModel;

  ProfileViewModel({
    required this.userId,
    required this.userRepository,
  });

  void loadUser() async {
    try {
      emitLoading();
      userModel = await userRepository.loadUser(
        userId: userId,
      );
      emitContent();
    } catch (e) {
      emitError();
    }
  }

  void emitError() {
    status = ProfileStatus.error;
    notifyListeners();
  }

  void emitLoading() {
    status = ProfileStatus.loading;
    notifyListeners();
  }

  void emitContent() {
    status = ProfileStatus.content;
    notifyListeners();
  }
}