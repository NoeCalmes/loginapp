import 'package:firebase1/screens/home_screen.dart';
import 'package:firebase1/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // En cours
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Utilisateur connecté
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Non Connecté
        return const LoginScreen();
      },
    );
  }
}