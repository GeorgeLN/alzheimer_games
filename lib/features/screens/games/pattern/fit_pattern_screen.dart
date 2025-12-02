// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:google_fonts/google_fonts.dart';
import './pattern_view_model.dart'; // Import ViewModel

class FitPatternScreen extends StatefulWidget {
  const FitPatternScreen({super.key});

  @override
  State<FitPatternScreen> createState() => _FitPatternScreenState();
}

class _FitPatternScreenState extends State<FitPatternScreen> {
  final Map<String, IconData> todasLasFiguras = {
    'Círculo': Icons.circle,
    'Cuadrado': Icons.square,
    'Triángulo': Icons.change_history_rounded,
    'Estrella': Icons.star,
    'Corazón': Icons.favorite,
    'Rombo': Icons.diamond,
    'Pentágono': Icons.pentagon,
  };

  late Map<String, IconData> figurasEnJuego; // Figures currently in the game
  late Map<String, IconData> figuras; // Figures displayed in the UI, same as figurasEnJuego

  String? figuraObjetivo;
  String? figuraArrastrada;
  int score = 0;
  int correctasConsecutivas = 0; // Track consecutive correct answers
  PatternViewModel? _viewModel; // ViewModel instance

  @override
  void initState() {
    super.initState();
    _initializeGameScreen();
  }

  Future<void> _initializeGameScreen({bool reinicio = false}) async {
    if (!reinicio) {
      _viewModel = GetIt.I<PatternViewModel>(); // Initialize ViewModel only once
    }
    // Load score from ViewModel, but don't use it for initial game score here.
    // The game score always starts at 0.
    await _viewModel!.loadInitialScore();
    int initialScore = 0;

    if (mounted) {
      correctasConsecutivas = 0;
      var allKeys = todasLasFiguras.keys.toList()..shuffle();
      figurasEnJuego = {};
      for (int i = 0; i < 3 && i < allKeys.length; i++) {
        figurasEnJuego[allKeys[i]] = todasLasFiguras[allKeys[i]]!;
      }
      figuras = Map.from(figurasEnJuego); // Initialize UI figures
      score = initialScore;
      _nuevaFiguraObjetivo();
    }
  }

  void _nuevaFiguraObjetivo() {
    if (figurasEnJuego.isEmpty) return; // Avoid error if no figures
    figuraObjetivo = (figurasEnJuego.keys.toList()..shuffle()).first;
    figuraArrastrada = null;
    setState(() {});
  }

  void _verificarEncaje(String figura) {
    setState(() {
      if (figura == figuraObjetivo) {
        score += 10;
        correctasConsecutivas++;
        if (correctasConsecutivas == 2) {
          correctasConsecutivas = 0;
          if (figurasEnJuego.length < todasLasFiguras.length) {
            var figurasDisponibles = todasLasFiguras.keys
                .where((key) => !figurasEnJuego.containsKey(key))
                .toList();
            if (figurasDisponibles.isNotEmpty) {
              var nuevaFiguraKey = (figurasDisponibles..shuffle()).first;
              figurasEnJuego[nuevaFiguraKey] = todasLasFiguras[nuevaFiguraKey]!;
              figuras = Map.from(figurasEnJuego); // Update UI figures
            }
          }
        }
      } else {
        score = score > 0 ? score - 1 : 0;
        correctasConsecutivas = 0;
      }
    });
    _viewModel?.saveGameScore(score); // Save score after updating
    Future.delayed(const Duration(seconds: 1), _nuevaFiguraObjetivo);
  }

  @override
  Widget build(BuildContext context) {
    if (figurasEnJuego.isEmpty) {
      // Handle the case where figures might not be initialized yet, though _initializeGameScreen should prevent this.
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    List<String> opciones = figurasEnJuego.keys.toList()..shuffle();

    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Color.fromRGBO(146, 122, 255, 1),

        appBar: AppBar(
          backgroundColor: Color.fromRGBO(146, 122, 255, 1),
          title: Text(
            'Encaje de Figuras',
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
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              tooltip: 'Reiniciar juego',
              onPressed: () {
                _initializeGameScreen(reinicio: true);
              },
            )
          ],
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text('Puntaje: $score', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text('Arrastra la figura correcta al contorno:', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: DragTarget<String>(
                onAccept: _verificarEncaje,
                builder: (context, candidateData, rejectedData) => Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: figuraObjetivo != null && figurasEnJuego.containsKey(figuraObjetivo)
                      ? Icon(figurasEnJuego[figuraObjetivo], size: 100, color: Colors.white24)
                      : const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: opciones.map((figuraNombre) {
                return Draggable<String>(
                  data: figuraNombre,
                  feedback: Icon(figurasEnJuego[figuraNombre], size: 100, color: Colors.amber),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Icon(figurasEnJuego[figuraNombre], size: 100),
                  ),
                  child: Icon(figurasEnJuego[figuraNombre], size: 100),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
