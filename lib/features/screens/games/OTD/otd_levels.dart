import 'package:flutter/material.dart';
import '../../../../data/models/game_model/otd_model.dart';

class Level {
  final List<Node> nodes;
  final List<Line> lines;

  Level({required this.nodes, required this.lines});
}

final List<Level> levels = [
  // Level 1: Square
  Level(
    nodes: [
      Node(const Offset(100, 100)),
      Node(const Offset(200, 100)),
      Node(const Offset(100, 200)),
      Node(const Offset(200, 200)),
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 3),
      Line(2, 3),
    ],
  ),
  // Level 2: Triangle
  Level(
    nodes: [
      Node(const Offset(150, 100)),
      Node(const Offset(100, 200)),
      Node(const Offset(200, 200)),
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 2),
    ],
  ),
  // Level 3: House
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(100, 100)), // 1
      Node(const Offset(200, 100)), // 2
      Node(const Offset(100, 200)), // 3
      Node(const Offset(200, 200)), // 4
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 2),
      Line(1, 3),
      Line(2, 4),
      Line(3, 4),
    ],
  ),
];
