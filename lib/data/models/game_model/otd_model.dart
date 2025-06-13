import 'package:flutter/material.dart';

class Node {
  final Offset position;
  Node(this.position);
}

class Line {
  final int startNodeIndex;
  final int endNodeIndex;
  bool isDrawn = false;

  Line(this.startNodeIndex, this.endNodeIndex);
}