import 'package:alzheimer_games_app/features/screens/games/trivia/trivia_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  TriviaViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<TriviaViewModel>();
    _viewModel?.addListener(_onViewModelChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel?.initialize();
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    final state = _viewModel?.state;
    if (state == TriviaState.levelUp) {
      _showLevelUpDialog();
    } else if (state == TriviaState.repeatLevel) {
      _showRepeatLevelDialog();
    } else if (state == TriviaState.gameFinished) {
      _showGameFinishedDialog();
    }
  }

  void _selectAnswer(int index) {
    _viewModel?.checkAnswer(index);
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Nivel Completado!'),
        content: Text('¡Felicidades! Has avanzado al Nivel ${_viewModel?.currentLevel}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel?.nextLevel();
            },
            child: const Text('Continuar'),
          )
        ],
      ),
    );
  }

  void _showRepeatLevelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Nivel Fallido!'),
        content: const Text('No has contestado todas las preguntas correctamente. Debes repetir el nivel.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel?.repeatLevel();
            },
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  void _showGameFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Juego Completado!'),
        content: const Text('¡Felicidades! Has completado todos los niveles.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel?.restartGame();
            },
            child: const Text('Jugar de Nuevo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back from trivia screen
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TriviaViewModel>();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(146, 122, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(146, 122, 255, 1),
        title: Text(
          'Nivel ${viewModel.currentLevel}',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(TriviaViewModel viewModel) {
    switch (viewModel.state) {
      case TriviaState.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      case TriviaState.error:
        return const Center(child: Text('Error al cargar las preguntas.', style: TextStyle(color: Colors.white)));
      case TriviaState.empty:
        return const Center(child: Text('No hay preguntas para este nivel.', style: TextStyle(color: Colors.white)));
      case TriviaState.content:
      case TriviaState.levelUp:
      case TriviaState.repeatLevel:
      case TriviaState.gameFinished:
        return _buildContent(viewModel);
      }
  }

  Widget _buildContent(TriviaViewModel viewModel) {
    if (viewModel.questionModel == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    final q = viewModel.questionModel!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pregunta ${viewModel.currentQuestionNumber} de ${viewModel.totalLevelQuestions}',
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            q.question,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ...List.generate(q.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ElevatedButton(
                onPressed: () => _selectAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(q.options[index], style: const TextStyle(fontSize: 18, color: Colors.black)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
