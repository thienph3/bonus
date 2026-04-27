import 'package:flutter/material.dart';

class StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final String state;
  final String message;
  final VoidCallback? onPressed;
  final String buttonLabel;

  const StepCard({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.message,
    required this.onPressed,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = switch (state) {
      'processing' => (Icons.hourglass_top, Colors.orange),
      'completed' => (Icons.check_circle, Colors.green),
      'error' => (Icons.error, Colors.red),
      _ => (Icons.circle_outlined, Colors.grey),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bước $step: $title',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(message,
                        style: TextStyle(
                            fontSize: 13,
                            color: state == 'error' ? Colors.red : Colors.green[700])),
                  ],
                  if (state == 'processing') ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
