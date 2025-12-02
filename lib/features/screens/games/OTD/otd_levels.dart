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
  // Level 4: Star
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(120, 120)), // 1
      Node(const Offset(200, 80)), // 2
      Node(const Offset(100, 80)), // 3
      Node(const Offset(180, 120)), // 4
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(0, 3),
      Line(0, 4),
      Line(1, 2),
      Line(2, 4),
      Line(4, 3),
    ],
  ),

  // Level 5: Boat
  Level(
    nodes: [
      Node(const Offset(100, 150)), // 0
      Node(const Offset(200, 150)), // 1
      Node(const Offset(125, 200)), // 2
      Node(const Offset(175, 200)), // 3
      Node(const Offset(150, 100)), // 4
      Node(const Offset(150, 50)), // 5
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 3),
      Line(2, 3),
      Line(0, 4),
      Line(1, 4),
      Line(4, 5),
      Line(0, 5),
    ],
  ),

  // Level 6: "A" letter
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(100, 200)), // 1
      Node(const Offset(200, 200)), // 2
      Node(const Offset(125, 125)), // 3
      Node(const Offset(175, 125)), // 4
    ],
    lines: [
      Line(1, 0),
      Line(0, 2),
      Line(2, 4),
      Line(4, 3),
    ],
  ),

  // Level 7: "8" number
  Level(
    nodes: [
      Node(const Offset(150, 125)), // 0
      Node(const Offset(125, 100)), // 1
      Node(const Offset(175, 100)), // 2
      Node(const Offset(125, 150)), // 3
      Node(const Offset(175, 150)), // 4
      Node(const Offset(125, 75)), // 5
      Node(const Offset(175, 75)), // 6
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(0, 3),
      Line(0, 4),
      Line(1, 2),
      Line(3, 4),
      Line(1, 5),
      Line(2, 6),
      Line(5, 6),
    ],
  ),

  // Level 8: Crystal
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(100, 100)), // 1
      Node(const Offset(200, 100)), // 2
      Node(const Offset(150, 125)), // 3
      Node(const Offset(100, 150)), // 4
      Node(const Offset(200, 150)), // 5
      Node(const Offset(150, 200)), // 6
      Node(const Offset(250, 200)), // 7
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 2),
      Line(1, 3),
      Line(2, 3),
      Line(1, 4),
      Line(2, 5),
      Line(4, 6),
      Line(5, 6),
      Line(6, 7),
    ],
  ),

  // Level 9: Complex Star
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(100, 100)), // 1
      Node(const Offset(200, 100)), // 2
      Node(const Offset(100, 150)), // 3
      Node(const Offset(200, 150)), // 4
      Node(const Offset(150, 200)), // 5
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 3),
      Line(1, 4),
      Line(2, 3),
      Line(2, 4),
      Line(3, 5),
      Line(4, 5),
      Line(1, 2),
    ],
  ),

  // Level 10: Intricate Pattern
  Level(
    nodes: [
      Node(const Offset(150, 50)), // 0
      Node(const Offset(100, 100)), // 1
      Node(const Offset(200, 100)), // 2
      Node(const Offset(150, 150)), // 3
      Node(const Offset(100, 200)), // 4
      Node(const Offset(200, 200)), // 5
    ],
    lines: [
      Line(0, 1),
      Line(0, 2),
      Line(1, 2),
      Line(1, 3),
      Line(2, 3),
      Line(1, 4),
      Line(3, 4),
      Line(3, 5),
      Line(2, 5),
      Line(4, 5),
    ],
  ),
];
