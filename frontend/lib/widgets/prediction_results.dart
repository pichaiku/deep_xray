import 'package:flutter/material.dart';

class PredictionResults extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;

  const PredictionResults({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            height: 95,
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                final confidence = prediction['confidence'] as double;
                final color = confidence > 0.7
                    ? Colors.green
                    : confidence > 0.3
                        ? Colors.orange
                        : Colors.red;

                return Card(
                  child: ListTile(
                    title: Text(prediction['condition'] as String),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prediction['description'] as String),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.bar_chart, size: 16, color: color),
                            const SizedBox(width: 4),
                            Text(
                              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
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