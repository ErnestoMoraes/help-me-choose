import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_me_choose/screens/onboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Escolha de Restaurante',
      home: const OnboardingScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.chakraPetchTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
