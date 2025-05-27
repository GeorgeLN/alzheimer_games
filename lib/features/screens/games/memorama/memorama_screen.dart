import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../data/models/game_model/memorama_card_model.dart';

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

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() {
    List<int> values = List.generate(gridSize * gridSize ~/ 2, (index) => index);
    values = [...values, ...values];
    values.shuffle(Random());
    cards = values.map((value) => CardModel(value: value)).toList();
    score = 0;
    selectedIndices.clear();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    //double cardSize = MediaQuery.of(context).size.width / gridSize - 20;

    return Scaffold(
      appBar: AppBar(
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar nivel',
            onPressed: _generateCards,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Puntaje: $score', style: const TextStyle(fontSize: 24)),
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
    );
  }
}
