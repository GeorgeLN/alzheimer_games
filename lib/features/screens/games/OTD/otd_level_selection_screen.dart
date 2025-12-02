import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'otd_levels.dart';
import 'otd_screen.dart';

class OtdLevelSelectionScreen extends StatefulWidget {
  const OtdLevelSelectionScreen({super.key});

  @override
  State<OtdLevelSelectionScreen> createState() => _OtdLevelSelectionScreenState();
}

class _OtdLevelSelectionScreenState extends State<OtdLevelSelectionScreen> {
  PlayerModel? currentPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (mounted) {
      final userRepository = Provider.of<UserRepository>(context, listen: false);
      final user = await userRepository.getCurrentPlayer();
      if (mounted) {
        setState(() {
          currentPlayer = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar Nivel'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/otd');
            },
          ),
        ),
        body: currentPlayer == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final otdLevels = currentPlayer!.completedLevels?['otd'] ?? [];
                    final isUnlocked = index == 0 || otdLevels.contains(index - 1);
                    final isCompleted = otdLevels.contains(index);
                    
                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OneTouchGame(level: index),
                                ),
                              );
                            }
                          : null,
                      child: Card(
                        color: isUnlocked
                            ? (isCompleted ? Colors.deepPurple : Colors.white)
                            : Colors.grey,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isUnlocked ? Colors.black : Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
      ),
    );
  }
}
