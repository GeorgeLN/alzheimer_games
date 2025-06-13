// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../../../../data/models/game_model/otd_model.dart';

class OneTouchGame extends StatefulWidget {
  const OneTouchGame({super.key});

  @override
  _OneTouchGameState createState() => _OneTouchGameState();
}

class _OneTouchGameState extends State<OneTouchGame> {
  List<Node> nodes = [];
  List<Line> lines = [];
  int? currentNode;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    nodes = [
      Node(Offset(100, 100)),
      Node(Offset(200, 100)),
      Node(Offset(100, 200)),
      Node(Offset(200, 200)),
    ];

    lines = [
      Line(0, 1),
      Line(0, 2),
      Line(1, 3),
      Line(2, 3),
    ];
  }

  void _handleTap(Offset position) {
    for (int i = 0; i < nodes.length; i++) {
      if ((nodes[i].position - position).distance < 20) {
        if (currentNode == null) {
          setState(() => currentNode = i);
        } else {
          Line? validLine = lines.firstWhere(
            (line) =>
                ((line.startNodeIndex == currentNode && line.endNodeIndex == i) ||
                 (line.endNodeIndex == currentNode && line.startNodeIndex == i)) &&
                !line.isDrawn,
            orElse: () => Line(-1, -1),
          );

          if (validLine.startNodeIndex != -1) {
            setState(() {
              validLine.isDrawn = true;
              currentNode = i;
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _handleTap(details.localPosition),
      child: CustomPaint(
        size: Size.infinite,
        painter: PuzzlePainter(nodes, lines),
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  final List<Node> nodes;
  final List<Line> lines;

  PuzzlePainter(this.nodes, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..color = Colors.blue;

    // Dibujar líneas
    for (var line in lines) {
      final p1 = nodes[line.startNodeIndex].position;
      final p2 = nodes[line.endNodeIndex].position;
      paint.color = line.isDrawn ? Colors.green : Colors.blue;
      canvas.drawLine(p1, p2, paint);
    }

    // Dibujar nodos
    for (var node in nodes) {
      canvas.drawCircle(node.position, 10, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
