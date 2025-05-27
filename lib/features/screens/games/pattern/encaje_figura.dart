// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _cambiarNivel(nivel);
  }

  void _nuevaFiguraObjetivo() {
    figuraObjetivo = (figuras.keys.toList()..shuffle()).first;
    figuraArrastrada = null;
    setState(() {});
  }

  void _verificarEncaje(String figura) {
    if (figura == figuraObjetivo) {
      setState(() {
        score++;
      });
    } else {
      setState(() {
        score = score > 0 ? score - 1 : 0;
      });
    }
    Future.delayed(const Duration(seconds: 1), _nuevaFiguraObjetivo);
  }

  void _cambiarNivel(String nuevoNivel) {
    setState(() {
      nivel = nuevoNivel;
      if (nivel == 'Fácil') {
        figuras = figurasFacil;
      } else if (nivel == 'Medio') {
        figuras = figurasMedio;
      } else {
        figuras = figurasDificil;
      }
      score = 0;
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
              setState(() {
                score = 0;
                _nuevaFiguraObjetivo();
              });
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
