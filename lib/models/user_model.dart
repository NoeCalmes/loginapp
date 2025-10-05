import 'package:firebase_auth/firebase_auth.dart';

/// Modèle simple pour représenter un utilisateur
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
  });

  /// Créer UserModel depuis Firebase User
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  /// Nom d'affichage ou email si pas de nom
  String get displayText => displayName?.isNotEmpty == true ? displayName! : email;

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
}