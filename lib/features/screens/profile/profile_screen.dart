import 'package:alzheimer_games_app/data/core/inject.dart';
import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserRepository _userRepository;
  PlayerModel? _player;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userRepository = inject<UserRepository>();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final player = await _userRepository.getCurrentPlayer();
      setState(() {
        _player = player;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos del usuario: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {  
    var size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              //Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                // Llamar al método signOut del AuthCubit
                context.read<AuthCubit>().signOut();
                Navigator.of(context).pushReplacementNamed('/first'); 
              },
            ),
          ],
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _errorMessage != null
                  ? Text(_errorMessage!, style: const TextStyle(color: Colors.red))
                  : _player != null
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_circle, size: size.width * 0.35, color: Colors.blueGrey),
                              const SizedBox(height: 24),
                              TextFormField(
                                initialValue: _player?.userName ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Nombre de usuario',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: FirebaseAuth.instance.currentUser?.email ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Correo electrónico',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                readOnly: true,
                              ),
                              if (!_isLoading && _errorMessage == null && _player != null)
                                Card(
                                  margin: const EdgeInsets.only(top: 24.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Puntuaciones',
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildScoreRow('Memorama', _player!.scoreMemory),
                                        _buildScoreRow('Puzzle', _player!.scorePuzzle),
                                        _buildScoreRow('Trivia', _player!.scoreTrivia),
                                        _buildScoreRow('Encaje de Figuras', _player!.scorePattern),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : const Text('No se encontraron datos del usuario.'),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String gameName, int? score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(gameName, style: Theme.of(context).textTheme.bodyLarge),
          Text(score?.toString() ?? '0', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}