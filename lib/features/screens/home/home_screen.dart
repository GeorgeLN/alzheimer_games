
import 'package:alzheimer_games_app/data/core/inject.dart';
import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final juegos = [
      {'nombre': 'Memorama (Juego de memoria)', 'route': '/memorama'},
      {'nombre': 'Rompecabezas deslizante', 'route': '/puzzle'},
      {'nombre': 'Trivia', 'route': '/trivia'},
      {'nombre': 'Encaje de Figuras', 'route': '/encaje_figura'},
    ];

    String firstName = _player?.userName ?? '';
    firstName = firstName.split(' ')[0];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hola! ',
                        style: TextStyle(
                          color: Color(0xFFFFB74D), // Naranja
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      TextSpan(
                        text: firstName,
                        style: TextStyle(
                          color: Color(0xFF232946), // Azul oscuro
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '¿En qué te gustaría trabajar hoy?',
                  style: TextStyle(
                    color: Color(0xFF232946),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFF4F4F6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Progreso',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Actividades',
                            style: TextStyle(
                              color: Color(0xFF232946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Metas',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: juegos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(juegos[index]['nombre']!),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    leading: CircleAvatar(
                      child: Icon(Icons.games_rounded),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, juegos[index]['route']!);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}