import 'package:firebase1/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final displayNameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  bool _isSubmitting = false;

  // États pour les indicateurs de mot de passe
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _showPasswordRequirements = false; // Afficher seulement si on écrit

  @override
  void initState() {
    super.initState();
    // Écouter les changements du mot de passe
    passwordTextController.addListener(_validatePasswordStrength);
  }

  void _validatePasswordStrength() {
    final password = passwordTextController.text;
    setState(() {
      // Afficher les contraintes seulement si l'utilisateur a commencé à écrire
      _showPasswordRequirements = password.isNotEmpty;
      _hasMinLength = password.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|_\-+=\[\]\\/<>]').hasMatch(password);
    });
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      // Tenter de créer le compte avec l'email et le mot de passe
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text,
      );

      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName(displayNameTextController.text.trim());
      await userCredential.user?.reload();

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inscription réussie ! Vérifiez votre email.')),
        );
        // L'AuthGate détectera automatiquement la connexion et affichera HomeScreen
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'email-already-in-use' => 'Email déjà utilisé',
        'invalid-email' => 'Email invalide',
        'weak-password' => 'Mot de passe trop faible',
        _ => 'Erreur : ${e.code}',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    displayNameTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Retour à la connexion',
          onPressed: _isSubmitting ? null : () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: displayNameTextController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'affichage',
                    hintText: 'Jean Dupont',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final trimmed = (v ?? '').trim();
                    if (trimmed.isEmpty) return 'Nom requis';
                    if (trimmed.length < 2) return 'Au moins 2 caractères';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: emailTextController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final trimmed = (v ?? '').trim();
                    if (trimmed.isEmpty) return 'Email requis';
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(trimmed)) return 'Format d\'email invalide';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: passwordTextController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (!_hasMinLength || !_hasNumber || !_hasSpecialChar) {
                      return 'Mot de passe ne respecte pas les critères';
                    }
                    return null;
                  },
                ),
                // Indicateurs visuels - affichés seulement quand on écrit
                if (_showPasswordRequirements) ...[
                  SizedBox(height: 8),
                  Semantics(
                    label: 'Critères du mot de passe',
                    child: Column(
                      children: [
                        _PasswordRequirement(
                          text: 'Au moins 8 caractères',
                          isMet: _hasMinLength,
                        ),
                        _PasswordRequirement(
                          text: 'Au moins 1 chiffre (0-9)',
                          isMet: _hasNumber,
                        ),
                        _PasswordRequirement(
                          text: 'Au moins 1 symbole (!@#\$%...)',
                          isMet: _hasSpecialChar,
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordTextController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le Mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
                    if (v != passwordTextController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : register,
                    child: _isSubmitting
                        ? Semantics(
                            label: 'Inscription en cours, veuillez patienter',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Inscription...'),
                              ],
                            ),
                          )
                        : Text("S'inscrire"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher les critères du mot de passe avec indicateur vert/rouge
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: isMet ? Colors.green.shade600 : Colors.grey.shade400,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}