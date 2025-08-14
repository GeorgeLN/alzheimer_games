import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:google_fonts/google_fonts.dart';
import './puzzle_view_model.dart'; // Import ViewModel

class SlidePuzzleScreen extends StatefulWidget {
  const SlidePuzzleScreen({super.key});

  @override
  State<SlidePuzzleScreen> createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  int gridSize = 3;
  List<int> tiles = [];
  int score = 0;
  final List<int> gridOptions = [3, 4, 5];
  int finalScore = 0;
  bool isCompleted = false;
  int highestOrLastPuzzleScore = 0; // Added state variable

  PuzzleViewModel? _viewModel; // ViewModel instance

  @override
  void initState() {
    super.initState();
    _initializeGameScreen();
  }

  Future<void> _initializeGameScreen() async {
    _viewModel = GetIt.I<PuzzleViewModel>(); // Initialize ViewModel
    if (_viewModel != null) {
      highestOrLastPuzzleScore = await _viewModel!.loadInitialScore();
    }
    // Ensure the widget is still mounted before calling setState or other methods
    if (mounted) {
      _initializePuzzle();
    }
  }

  void _initializePuzzle() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    do {
      tiles.shuffle();
    } while (!_isSolvable(tiles));
    score = 0;
    isCompleted = false;
    finalScore = 0;
    setState(() {});
  }

  void _checkIfSolved() {
    List<int> solvedTiles = List.generate(gridSize * gridSize, (i) => (i + 1) % (gridSize * gridSize));
    // Example for 3x3: solvedTiles will be [1, 2, 3, 4, 5, 6, 7, 8, 0]

    if (const ListEquality().equals(tiles, solvedTiles)) {
      setState(() {
        isCompleted = true;
        finalScore = 100; // Or any other logic to determine the score
        // Save score and update local highest score
        _viewModel?.saveGameScore(finalScore);
        if (finalScore > highestOrLastPuzzleScore) { // Update if current finalScore is better (though it's fixed here)
          highestOrLastPuzzleScore = finalScore;
        }
        // For simplicity, as per instructions, we can just update it
        // highestOrLastPuzzleScore = finalScore; 
      });
      // Optionally, disable further moves or show a dialog
    }
  }

  bool _isSolvable(List<int> list) {
    int invCount = 0;
    for (int i = 0; i < list.length - 1; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] != 0 && list[j] != 0 && list[i] > list[j]) {
          invCount++;
        }
      }
    }
    return invCount % 2 == 0;
  }

  void _moveTile(int index) {
    int emptyIndex = tiles.indexOf(0);
    List<int> possibleMoves = [
      emptyIndex - 1,
      emptyIndex + 1,
      emptyIndex - gridSize,
      emptyIndex + gridSize
    ];

    if (possibleMoves.contains(index) && _isValidMove(index, emptyIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
        score++;
      });
      _checkIfSolved();
    }
  }

  bool _isValidMove(int from, int to) {
    int fx = from % gridSize;
    int fy = from ~/ gridSize;
    int tx = to % gridSize;
    int ty = to ~/ gridSize;
    return (fx == tx && (fy - ty).abs() == 1) || (fy == ty && (fx - tx).abs() == 1);
  }

  void _handleSwipe(int index, DragEndDetails details) {
    Offset velocity = details.velocity.pixelsPerSecond;
    int dx = velocity.dx.abs() > velocity.dy.abs()
        ? (velocity.dx > 0 ? 1 : -1)
        : 0;
    int dy = velocity.dy.abs() > velocity.dx.abs()
        ? (velocity.dy > 0 ? 1 : -1)
        : 0;

    int targetX = index % gridSize + dx;
    int targetY = index ~/ gridSize + dy;
    int targetIndex = targetY * gridSize + targetX;

    if (targetX >= 0 && targetX < gridSize && targetY >= 0 && targetY < gridSize) {
      if (tiles[targetIndex] == 0) {
        _moveTile(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // double tileSize = MediaQuery.of(context).size.width / gridSize - 12;

    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: const Color.fromRGBO(146, 122, 255, 1),

        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(146, 122, 255, 1),
          title: Text(
            'Puzzle de Números',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            DropdownButton<int>(
              value: gridSize,
              dropdownColor: Colors.white,
              items: gridOptions.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('${size}x$size', style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    gridSize = value;
                    _initializePuzzle();
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              tooltip: 'Reiniciar nivel',
              onPressed: _initializePuzzle,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isCompleted 
                    ? '¡Resuelto! Puntaje: $finalScore (Movimientos: $score)\nMejor Puntaje: $highestOrLastPuzzleScore' 
                    : 'Movimientos: $score\nMejor Puntaje: $highestOrLastPuzzleScore',
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: isCompleted ? null : () => _moveTile(index),
                    onHorizontalDragEnd: isCompleted ? null : (details) => _handleSwipe(index, details),
                    onVerticalDragEnd: isCompleted ? null : (details) => _handleSwipe(index, details),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: tiles[index] == 0 ? Colors.transparent : const Color.fromRGBO(241, 193, 100, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          tiles[index] == 0 ? '' : '${tiles[index]}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
