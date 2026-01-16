import 'package:flutter/material.dart';
import 'screens/configuration_screen.dart';

void main() {
  runApp(const TjCronometroApp());
}

class TjCronometroApp extends StatelessWidget {
  const TjCronometroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TJ Cronómetro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConfigurationScreen(),
    );
  }
}
