import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_me_choose/screens/home_screen.dart';
import 'package:help_me_choose/screens/login_screen.dart';
import 'package:help_me_choose/screens/onboard_screen.dart';
import 'package:help_me_choose/shared_preference/onboard_sp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final isOnboardingShown = await OnboardingManager.isOnboardingShown();
  final user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(
    isOnboardingShown: isOnboardingShown,
    user: user,
  ));
}

class MyApp extends StatelessWidget {
  final bool isOnboardingShown;
  final User? user;

  const MyApp({super.key, required this.isOnboardingShown, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help Me Choose',
      home: isOnboardingShown
          ? (user != null ? const HomeScreen() : const LoginScreen())
          : const OnboardingScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.chakraPetchTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
