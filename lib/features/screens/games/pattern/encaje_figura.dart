// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import './pattern_view_model.dart'; // Import ViewModel

class FiguraEncajeScreen extends StatefulWidget {
  const FiguraEncajeScreen({super.key});

  @override
  State<FiguraEncajeScreen> createState() => _FiguraEncajeScreenState();
}

class _FiguraEncajeScreenState extends State<FiguraEncajeScreen> {
  final Map<String, IconData> figurasFacil = {
    'Círculo': Icons.circle,
    'Cuadrado': Icons.square,
    'Triángulo': Icons.change_history_rounded,
  };

  final Map<String, IconData> figurasMedio = {
    'Círculo': Icons.circle,
    'Cuadrado': Icons.square,
    'Triángulo': Icons.change_history_rounded,
    'Estrella': Icons.star,
    'Corazón': Icons.favorite,
  };

  final Map<String, IconData> figurasDificil = {
    'Círculo': Icons.circle,
    'Cuadrado': Icons.square,
    'Triángulo': Icons.change_history_rounded,
    'Estrella': Icons.star,
    'Corazón': Icons.favorite,
    'Rombo': Icons.diamond,
    'Pentágono': Icons.pentagon,
  };

  late Map<String, IconData> figuras;

  String? figuraObjetivo;
  String? figuraArrastrada;
  int score = 0;
  String nivel = 'Fácil';

  final List<String> niveles = ['Fácil', 'Medio', 'Difícil'];
  PatternViewModel? _viewModel; // ViewModel instance

  @override
  void initState() {
    super.initState();
    _initializeGameScreen();
  }

  Future<void> _initializeGameScreen() async {
    _viewModel = GetIt.I<PatternViewModel>(); // Initialize ViewModel
    int initialScore = await _viewModel!.loadInitialScore();
    // Asegurarse de que el widget sigue montado después de la operación asíncrona
    if (mounted) {
      _cambiarNivel(nivel, initialScore: initialScore);
    }
  }

  void _nuevaFiguraObjetivo() {
    figuraObjetivo = (figuras.keys.toList()..shuffle()).first;
    figuraArrastrada = null;
    setState(() {});
  }

  void _verificarEncaje(String figura) {
    if (figura == figuraObjetivo) {
      setState(() {
        score += 10;
      });
      _viewModel?.saveGameScore(score); // Save score after updating
    } else {
      setState(() {
        score = score > 0 ? score - 1 : 0;
      });
    }
    Future.delayed(const Duration(seconds: 1), _nuevaFiguraObjetivo);
  }

  void _cambiarNivel(String nuevoNivel, {int initialScore = 0}) {
    setState(() {
      nivel = nuevoNivel;
      if (nivel == 'Fácil') {
        figuras = figurasFacil;
      } else if (nivel == 'Medio') {
        figuras = figurasMedio;
      } else {
        figuras = figurasDificil;
      }
      score = initialScore; // Usar initialScore aquí
      _nuevaFiguraObjetivo();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> opciones = figuras.keys.toList()..shuffle();

    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton<String>(
            value: nivel,
            dropdownColor: Colors.grey[200],
            items: niveles.map((n) {
              return DropdownMenuItem(
                value: n,
                child: Text(n),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _cambiarNivel(value);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar juego',
            onPressed: () {
              // Al reiniciar, el score se establece a 0, y se llama a _cambiarNivel
              // para regenerar las figuras del nivel actual con score 0.
              _cambiarNivel(nivel, initialScore: 0);
            },
          )
        ],
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text('Puntaje: $score', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
          const Text('Arrastra la figura correcta al contorno:', style: TextStyle(fontSize: 18)),
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
                child: figuraObjetivo != null
                    ? Icon(figuras[figuraObjetivo], size: 100, color: Colors.white24)
                    : const SizedBox(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: opciones.map((figura) {
              return Draggable<String>(
                data: figura,
                feedback: Icon(figuras[figura], size: 100, color: Colors.amber),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Icon(figuras[figura], size: 100),
                ),
                child: Icon(figuras[figura], size: 100),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
