import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {

  TriviaViewModel? viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel?.initialize();
      // Listen to changes in viewModel to update highestTriviaScore
      viewModel?.addListener(_updateHighestScoreFromViewModel);
    });
  }

  void _updateHighestScoreFromViewModel() {
    if (mounted && viewModel?.playerModel?.scoreTrivia != null) {
      setState(() {
        highestTriviaScore = viewModel!.playerModel!.scoreTrivia ?? 0;
      });
    }
  }

  @override
  void dispose() {
    viewModel?.removeListener(_updateHighestScoreFromViewModel);
    super.dispose();
  }

  int score = 0;
  int highestTriviaScore = 0; // Added state variable
  bool answered = false;
  int? selectedAnswer;

  void _selectAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == viewModel!.questionModel!.correctIndex) {
        score += 10;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (viewModel!.currentQuestion < viewModel!.questionIds.length - 1) {
        viewModel!.nextQuestion();
        selectedAnswer = null;
        answered = false;
      } else {
        _showFinalDialog();
      }
    });
  }

  void _showFinalDialog() {
    // Guardar el puntaje de la sesión actual (la lógica de si es mayor está en el VM)
    viewModel?.saveGameScore(score);

    // Actualizar el highestTriviaScore local si el score actual es mayor
    if (score > highestTriviaScore) {
      if (mounted) {
        setState(() {
          highestTriviaScore = score;
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Juego Terminado!'),
        content: Text('Puntaje final: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                viewModel!.resetQuestion();
                score = 0;
                selectedAnswer = null;
                answered = false;
              });
            },
            child: const Text('Reiniciar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    viewModel = context.watch();
    //QuestionModel q = questions[currentQuestion];

    if (viewModel!.status == TriviaS.loading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (viewModel!.status == TriviaS.error) {
      return Scaffold(
        body: const Center(child: Text('Error al cargar la pregunta')),
      );
    }

    final q = viewModel!.questionModel!;
    
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Color.fromRGBO(241, 193, 100, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(241, 193, 100, 1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pregunta ${viewModel!.currentQuestion + 1} de ${viewModel!.questionIds.length}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                q.question,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...List.generate(q.options.length, (index) {
                Color color = Colors.white;
                if (answered) {
                  if (index == q.correctIndex) {
                    color = Colors.green;
                  } else if (index == selectedAnswer) {
                    color = Colors.red;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    onPressed: () => _selectAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(q.options[index], style: const TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                );
              }),
              const SizedBox(height: 30),
              Text('Puntaje de la partida: $score',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Text('Mejor Puntaje Trivia: $highestTriviaScore',
                  style: const TextStyle(fontSize: 20, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
