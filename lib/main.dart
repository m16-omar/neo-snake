import 'package:flutter/material.dart';
import 'src/views/widgets/splash_screen.dart';
import 'src/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
