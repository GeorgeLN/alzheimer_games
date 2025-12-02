import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/game_model/memorama_card_model.dart';
import './memorama_view_model.dart'; // Import ViewModel

class MemoramaScreen extends StatefulWidget {
  const MemoramaScreen({super.key});

  @override
  State<MemoramaScreen> createState() => _MemoramaScreenState();
}

class _MemoramaScreenState extends State<MemoramaScreen> with TickerProviderStateMixin {
  int gridSize = 4;
  late List<CardModel> cards;
  List<int> selectedIndices = [];
  bool canTap = true;
  int score = 0;
  final List<int> gridOptions = [2, 4, 6];

  MemoramaViewModel? _viewModel; // ViewModel instance

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    _viewModel = GetIt.I<MemoramaViewModel>(); // Initialize ViewModel
    int initialScore = await _viewModel!.loadInitialScore();
    _generateCards(initialScore: initialScore);
  }

  void _generateCards({int initialScore = 0}) {
    List<int> values = List.generate(gridSize * gridSize ~/ 2, (index) => index);
    values = [...values, ...values];
    values.shuffle(Random());
    cards = values.map((value) => CardModel(value: value)).toList();
    score = initialScore;
    selectedIndices.clear();
    // It's important to check if the widget is still mounted before calling setState,
    // especially after async operations.
    if (mounted) {
      setState(() {});
    }
  }

  void _onCardTap(int index) async {
    if (!canTap || cards[index].isFlipped || cards[index].isMatched) return;

    setState(() {
      cards[index].isFlipped = true;
      selectedIndices.add(index);
    });

    if (selectedIndices.length == 2) {
      canTap = false;
      await Future.delayed(const Duration(milliseconds: 800));

      int i1 = selectedIndices[0];
      int i2 = selectedIndices[1];

      if (cards[i1].value == cards[i2].value) {
        setState(() {
          cards[i1].isMatched = true;
          cards[i2].isMatched = true;
          score += 10;
        });

        bool allMatched = cards.every((card) => card.isMatched);
        if (allMatched) {
          print('Memorama completado! Puntaje final: $score');
          _viewModel?.saveGameScore(score);
          _showGameCompletedDialog(score);
        }
      } else {
        setState(() {
          cards[i1].isFlipped = false;
          cards[i2].isFlipped = false;
          score = max(0, score - 2);
        });
      }

      selectedIndices.clear();
      canTap = true;
    }
  }

  void _showGameCompletedDialog(int finalScore) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (_) => AlertDialog(
        title: const Text('¡Memorama Completado!'),
        content: Text('Puntaje obtenido: $finalScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateCards(); // Reinicia el juego, score se reinicia a 0 por defecto
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
        backgroundColor: Color.fromRGBO(146, 122, 255, 1),

        appBar: AppBar(
          backgroundColor: Color.fromRGBO(146, 122, 255, 1),
          title: Text(
            'Memorama',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          actions: [
            DropdownButton<int>(
              value: gridSize,
              dropdownColor: Colors.grey[200],
              items: gridOptions.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('${size}x$size'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    gridSize = value;
                    _generateCards();
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              tooltip: 'Reiniciar nivel',
              onPressed: () => _generateCards(), // Reinicia el juego, score se reinicia a 0 por defecto
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Puntaje: $score', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: cards[index].isFlipped || cards[index].isMatched
                            ? Colors.amber
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: cards[index].isFlipped || cards[index].isMatched ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '${cards[index].value}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
