import 'package:firebase1/screens/auth/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    final trimmed = (value ?? '').trim().toLowerCase();
    if (trimmed.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Format d\'email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Mot de passe requis';
    if (v.length < 8) return 'Au moins 8 caractères';
    return null;
  }

  Future<void> ensureInitialized() {
    return GoogleSignInPlatform.instance.init(const InitParameters());
  }

  Future<void> signInWithGoogle() async {
    try {
      await ensureInitialized(); //tout soit chargé
      //authentification
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());

      //recupérer ce jeton id
      final String? idToken = result.authenticationTokens.idToken;

      if (idToken != null) {
        //connecté !
        //récupérer toutes les infos de l'utilisateur
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Utilisateur connecté avec Google ! ${firebaseUser.displayName ?? firebaseUser.email}"),
          ),
        );
      }


      } else {
        //message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la récupération du token Google"),
          ),
        );
      }
    } on GoogleSignInException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur sign in :  $e")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur de firebase auth :  $e")));
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      // Tenter de se connecter au compte avec l'email et le mot de passe
      final email = emailTextController.text.trim().toLowerCase();
      final password = passwordTextController.text;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Connexion réussie - redirection automatique via AuthGate
    } on FirebaseAuthException {
      // Message générique (évite de révéler si l'email existe)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Identifiants invalides.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailTextController.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer votre email')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de réinitialisation envoyé à $email'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'user-not-found' => 'Si cet email existe, un lien de réinitialisation a été envoyé',
        'invalid-email' => 'Email invalide',
        'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
        _ => 'Si cet email existe, un lien de réinitialisation a été envoyé',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion'), backgroundColor: Colors.blue),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: emailTextController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemple@mail.com',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: passwordTextController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                ),
                SizedBox(height: 16),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Vous n'avez pas de compte ? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Inscrivez-vous',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Bouton mot de passe oublié
                TextButton(
                  onPressed: resetPassword,
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : login,
                    child: _isSubmitting
                        ? Row(
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
                              Text('Connexion...'),
                            ],
                          )
                        : Text('Se connecter'),
                  ),
                ),
                SizedBox(height: 10),
                SignInButton(Buttons.google, onPressed: signInWithGoogle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
