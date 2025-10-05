import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service centralisé pour l'authentification Firebase
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Utilisateur actuel
  static UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  /// Stream des changements d'authentification
  static Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebase(user) : null;
    });
  }

  /// Inscription avec email, mot de passe et nom
  static Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();

      // Optionnel : Envoyer email de vérification
      await credential.user?.sendEmailVerification();

      return UserModel.fromFirebase(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Connexion avec email et mot de passe
  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return UserModel.fromFirebase(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Réinitialisation du mot de passe
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Déconnexion
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Gestion centralisée des erreurs Firebase
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'email-already-in-use':
        return 'Un compte existe déjà pour cet email';
      case 'invalid-email':
        return 'L\'adresse email est invalide';
      case 'user-not-found':
        return 'Aucun compte trouvé pour cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'L\'inscription par email n\'est pas activée';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}