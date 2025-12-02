// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:alzheimer_games_app/data/models/user_model/user_model.dart';
import 'package:alzheimer_games_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/game_model/otd_model.dart';
import 'otd_level_selection_screen.dart';
import 'otd_levels.dart';

class OneTouchGame extends StatefulWidget {
  final int level;
  const OneTouchGame({super.key, this.level = 0});

  @override
  _OneTouchGameState createState() => _OneTouchGameState();
}

class _OneTouchGameState extends State<OneTouchGame> {
  late List<Node> nodes;
  late List<Line> lines;
  int? currentNode;
  late int currentLevelIndex;
  PlayerModel? currentPlayer;
  int get scoreOtd => currentPlayer?.scoreOtd ?? 0;
  bool get isLevelComplete => lines.every((line) => line.isDrawn);

  @override
  void initState() {
    super.initState();
    currentLevelIndex = widget.level;
    _loadLevel(currentLevelIndex);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    final user = await userRepository.getCurrentPlayer();
    setState(() {
      currentPlayer = user;
    });
  }

  void _loadLevel(int levelIndex) {
    setState(() {
      final level = levels[levelIndex];
      nodes = level.nodes;
      lines = level.lines.map((line) => Line(line.startNodeIndex, line.endNodeIndex)).toList();
      currentNode = null;
    });
  }

  void _onPanStart(Offset position, Offset puzzleOffset, double scale) {
    for (int i = 0; i < nodes.length; i++) {
      final nodePosition = nodes[i].position * scale + puzzleOffset;
      if ((nodePosition - position).distance < 25) {
        setState(() {
          currentNode = i;
        });
        break;
      }
    }
  }

  void _onPanUpdate(Offset position, Offset puzzleOffset, double scale) {
    if (currentNode == null) return;

    for (int i = 0; i < nodes.length; i++) {
      if (i == currentNode) continue;

      final nodePosition = nodes[i].position * scale + puzzleOffset;
      if ((nodePosition - position).distance < 25) {
        final lineIndex = lines.indexWhere((line) =>
        ((line.startNodeIndex == currentNode && line.endNodeIndex == i) ||
            (line.endNodeIndex == currentNode && line.startNodeIndex == i)) &&
            !line.isDrawn,
        );

        if (lineIndex != -1) {
          HapticFeedback.lightImpact();
          setState(() {
            lines[lineIndex].isDrawn = true;
            currentNode = i;
            if (isLevelComplete) {
              _showLevelCompleteDialog();
            }
          });
        }
        break;
      }
    }
  }

  void _showLevelCompleteDialog() {
    if (currentPlayer == null) return;
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    final newScore = scoreOtd + 10;
    final updatedLevels = Map<String, List<int>>.from(currentPlayer!.completedLevels ?? {});
    final otdLevels = updatedLevels['otd'] ?? [];
    if (!otdLevels.contains(currentLevelIndex)) {
      otdLevels.add(currentLevelIndex);
      updatedLevels['otd'] = otdLevels;
    }

    userRepository.updateUser(
      scoreOtd: newScore,
      completedLevels: updatedLevels,
    );

    setState(() {
      currentPlayer = PlayerModel(
        userId: currentPlayer!.userId,
        userName: currentPlayer!.userName,
        scoreMemory: currentPlayer!.scoreMemory,
        scorePuzzle: currentPlayer!.scorePuzzle,
        scoreTrivia: currentPlayer!.scoreTrivia,
        scorePattern: currentPlayer!.scorePattern,
        scoreOtd: newScore,
        completedLevels: updatedLevels,
      );
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Nivel Completado!'),
        content: Text('¡Felicidades! Has completado el nivel ${currentLevelIndex + 1}.'),
        actions: [
          if (currentLevelIndex < levels.length - 1)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentLevelIndex++;
                  _loadLevel(currentLevelIndex);
                });
              },
              child: const Text('Siguiente Nivel'),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, navigate back or show a game completion message
              },
              child: const Text('Jugar de Nuevo'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
            'OTD - Nivel ${currentLevelIndex + 1}',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Text(
              'Puntuación: $scoreOtd',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.list, color: Colors.black),
              tooltip: 'Seleccionar Nivel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtdLevelSelectionScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              tooltip: 'Reiniciar Nivel',
              onPressed: () => _loadLevel(currentLevelIndex),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (nodes.isEmpty) return Container(color: Colors.deepPurple.shade50);
      
            double minX = double.infinity, minY = double.infinity;
            double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
            for (var node in nodes) {
              minX = min(minX, node.position.dx);
              minY = min(minY, node.position.dy);
              maxX = max(maxX, node.position.dx);
              maxY = max(maxY, node.position.dy);
            }
      
            final puzzleWidth = maxX - minX;
            final puzzleHeight = maxY - minY;
      
            final availableWidth = constraints.maxWidth * 0.8; // 80% of width for padding
            final availableHeight = constraints.maxHeight * 0.8; // 80% of height for padding
      
            final scaleX = availableWidth / puzzleWidth;
            final scaleY = availableHeight / puzzleHeight;
            final scale = min(scaleX, scaleY);
      
            final scaledPuzzleWidth = puzzleWidth * scale;
            final scaledPuzzleHeight = puzzleHeight * scale;
      
            final puzzleCenterX = minX * scale + scaledPuzzleWidth / 2;
            final puzzleCenterY = minY * scale + scaledPuzzleHeight / 2;
      
            final screenCenter = constraints.biggest.center(Offset.zero);
            final puzzleOffset = Offset(screenCenter.dx - puzzleCenterX, screenCenter.dy - puzzleCenterY);
      
            return GestureDetector(
              onPanStart: (details) => _onPanStart(details.localPosition, puzzleOffset, scale),
              onPanUpdate: (details) => _onPanUpdate(details.localPosition, puzzleOffset, scale),
              onPanEnd: (_) {
                if (!isLevelComplete) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('¡Has fallado!'),
                      content: const Text('¿Quieres intentar de nuevo?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _loadLevel(currentLevelIndex);
                          },
                          child: const Text('Reiniciar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Container(
                color: Colors.deepPurple.shade50,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PuzzlePainter(nodes, lines, currentNode, puzzleOffset, scale),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  final List<Node> nodes;
  final List<Line> lines;
  final int? currentNode;
  final Offset puzzleOffset;
  final double scale;

  PuzzlePainter(this.nodes, this.lines, this.currentNode, this.puzzleOffset, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint();

    // Dibujar líneas
    for (var line in lines) {
      final p1 = nodes[line.startNodeIndex].position * scale + puzzleOffset;
      final p2 = nodes[line.endNodeIndex].position * scale + puzzleOffset;
      linePaint.color = line.isDrawn ? Colors.greenAccent : Colors.grey.shade400;
      canvas.drawLine(p1, p2, linePaint);
    }

    // Dibujar nodos
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final position = node.position * scale + puzzleOffset;
      if (i == currentNode) {
        nodePaint.color = Colors.orangeAccent;
        canvas.drawCircle(position, 18, nodePaint);
      }
      nodePaint.color = Colors.deepPurple;
      canvas.drawCircle(position, 15, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
