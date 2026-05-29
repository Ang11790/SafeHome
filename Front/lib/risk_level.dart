import 'package:flutter/material.dart';

class RiskLevelScreen extends StatefulWidget {
  const RiskLevelScreen({super.key});

  @override
  State<RiskLevelScreen> createState() => _RiskLevelScreenState();
}

class _RiskLevelScreenState extends State<RiskLevelScreen> {
  final List<String> _questions = const [
    '¿Has recibido amenazas directas recientemente?',
    '¿La persona agresora controla tus salidas, llamadas o dinero?',
    '¿Ha habido agresion fisica en el ultimo mes?',
    '¿Temes por tu vida o la de tus hijos/familia?',
    '¿La violencia ha aumentado en frecuencia o intensidad?',
    '¿Tienes una red de apoyo cercana y activa?',
  ];

  final Map<int, bool> _answers = {};

  int _score() {
    int total = 0;
    for (int i = 0; i < _questions.length; i++) {
      final bool answer = _answers[i] ?? false;
      if (i == 5) {
        if (!answer) {
          total += 2;
        }
      } else if (answer) {
        total += 2;
      }
    }
    return total;
  }

  String _riskLabel(int score) {
    if (score >= 9) return 'Riesgo alto';
    if (score >= 5) return 'Riesgo medio';
    return 'Riesgo bajo';
  }

  Color _riskColor(int score) {
    if (score >= 9) return Colors.red;
    if (score >= 5) return Colors.orange;
    return Colors.green;
  }

  void _showResult() {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responde todas las preguntas para calcular el riesgo.')),
      );
      return;
    }

    final int score = _score();
    final String label = _riskLabel(score);
    final Color color = _riskColor(score);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado de la encuesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puntaje: $score / 12'),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Esta encuesta es orientativa. Si hay peligro inmediato, contacta emergencias y busca apoyo profesional.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuesta de riesgo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Responde esta encuesta sobre violencia para estimar nivel de riesgo.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _questions.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ${_questions[i]}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Si'),
                            value: true,
                            groupValue: _answers[i],
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                _answers[i] = value ?? false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('No'),
                            value: false,
                            groupValue: _answers[i],
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                _answers[i] = value ?? false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showResult,
              icon: const Icon(Icons.assessment),
              label: const Text('Calcular nivel de riesgo'),
            ),
          ),
        ],
      ),
    );
  }
}
