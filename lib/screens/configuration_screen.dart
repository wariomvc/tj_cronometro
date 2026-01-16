import 'package:flutter/material.dart';
import 'countdown_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final TextEditingController _controller = TextEditingController(text: '5');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCountdown() {
    final minutes = int.tryParse(_controller.text) ?? 5;
    if (minutes > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountdownScreen(durationMinutes: minutes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Timer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Duración del Cronómetro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '5',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'minutos',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _navigateToCountdown,
                icon: const Icon(Icons.play_arrow, size: 32),
                label: const Text('Iniciar Timer', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
