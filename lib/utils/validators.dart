/// Classe utilitaire pour les validations
class Validators {
  /// Validation d'email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email requis';
    }
    
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }

  /// Validation de nom d'affichage
  static String? displayName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Nom requis';
    if (trimmed.length < 2) return 'Au moins 2 caractères';
    return null;
  }

  /// Validation de mot de passe
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    
    if (value.length < 8) {
      return 'Au moins 8 caractères requis';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Au moins 1 chiffre requis';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|_\-+=\[\]\\/<>]').hasMatch(value)) {
      return 'Au moins 1 caractère spécial requis';
    }
    
    return null;
  }

  /// Validation de confirmation de mot de passe
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirmation de mot de passe requise';
    }
    
    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
}

/// Classe pour vérifier la force du mot de passe
class PasswordStrength {
  final String password;
  
  PasswordStrength(this.password);
  
  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|_\-+=\[\]\\/<>]').hasMatch(password);
  
  bool get isValid => hasMinLength && hasNumber && hasSpecialChar;
  
  List<PasswordRequirement> get requirements => [
    PasswordRequirement('Au moins 8 caractères', hasMinLength),
    PasswordRequirement('Au moins 1 chiffre (0-9)', hasNumber),
    PasswordRequirement('Au moins 1 symbole (!@#\$%...)', hasSpecialChar),
  ];
}

class PasswordRequirement {
  final String text;
  final bool isMet;
  
  PasswordRequirement(this.text, this.isMet);
}