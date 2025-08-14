// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/game_model/otd_model.dart';
import 'otd_levels.dart';

class OneTouchGame extends StatefulWidget {
  const OneTouchGame({super.key});

  @override
  _OneTouchGameState createState() => _OneTouchGameState();
}

class _OneTouchGameState extends State<OneTouchGame> {
  late List<Node> nodes;
  late List<Line> lines;
  int? currentNode;
  int currentLevelIndex = 0;
  bool get isLevelComplete => lines.every((line) => line.isDrawn);

  @override
  void initState() {
    super.initState();
    _loadLevel(currentLevelIndex);
  }

  void _loadLevel(int levelIndex) {
    setState(() {
      final level = levels[levelIndex];
      nodes = level.nodes;
      lines = level.lines.map((line) => Line(line.startNodeIndex, line.endNodeIndex)).toList();
      currentNode = null;
    });
  }

  void _onPanStart(Offset position, Offset puzzleOffset) {
    for (int i = 0; i < nodes.length; i++) {
      final nodePosition = nodes[i].position + puzzleOffset;
      if ((nodePosition - position).distance < 25) {
        setState(() {
          currentNode = i;
        });
        break;
      }
    }
  }

  void _onPanUpdate(Offset position, Offset puzzleOffset) {
    if (currentNode == null) return;

    for (int i = 0; i < nodes.length; i++) {
      if (i == currentNode) continue;

      final nodePosition = nodes[i].position + puzzleOffset;
      if ((nodePosition - position).distance < 25) {
        final lineIndex = lines.indexWhere(
          (line) =>
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

  Offset _calculatePuzzleOffset(Size size) {
    if (nodes.isEmpty) return Offset.zero;

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
    final puzzleCenterX = minX + puzzleWidth / 2;
    final puzzleCenterY = minY + puzzleHeight / 2;

    final center = size.center(Offset.zero);
    return Offset(center.dx - puzzleCenterX, center.dy - puzzleCenterY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('One Touch Drawing - Nivel ${currentLevelIndex + 1}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar Nivel',
            onPressed: () => _loadLevel(currentLevelIndex),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final puzzleOffset = _calculatePuzzleOffset(size);

          return GestureDetector(
            onPanStart: (details) => _onPanStart(details.localPosition, puzzleOffset),
            onPanUpdate: (details) => _onPanUpdate(details.localPosition, puzzleOffset),
            child: Container(
              color: Colors.deepPurple.shade50,
              child: CustomPaint(
                size: Size.infinite,
                painter: PuzzlePainter(nodes, lines, currentNode, puzzleOffset),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  final List<Node> nodes;
  final List<Line> lines;
  final int? currentNode;
  final Offset puzzleOffset;

  PuzzlePainter(this.nodes, this.lines, this.currentNode, this.puzzleOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint();

    // Dibujar líneas
    for (var line in lines) {
      final p1 = nodes[line.startNodeIndex].position + puzzleOffset;
      final p2 = nodes[line.endNodeIndex].position + puzzleOffset;
      linePaint.color = line.isDrawn ? Colors.greenAccent : Colors.grey.shade400;
      canvas.drawLine(p1, p2, linePaint);
    }

    // Dibujar nodos
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final position = node.position + puzzleOffset;
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

  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}
