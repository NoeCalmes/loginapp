import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Tenter de créer le compte avec l'email et le mot de passe
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Inscription ok')));
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'Email déjà utilisé',
        'invalid-email' => 'Email invalide',
        'weak-password' => 'Mot de passe trop faible',
        _ => 'Erreur : ${e.code}',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailTextController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: passwordTextController,
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordTextController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le Mot de passe',
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
                    if (v != passwordTextController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                ElevatedButton(onPressed: register, child: Text("S'inscrire")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}