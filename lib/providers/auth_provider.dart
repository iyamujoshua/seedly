import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:seedly/services/auth_service.dart';
import 'package:seedly/services/database_service.dart';

/// Authentication state provider for managing user authentication
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _authService.isSignedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _authService.currentUser;
  String? get email => currentUser?.email;
  String? get errorMessage => _errorMessage;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithGoogle();
      _setLoading(false);
      return result != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _userAvatarId = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to sign out. Please try again.';
      _setLoading(false);
    }
  }

  // Avatar management
  String? _userAvatarId;
  String? get userAvatarId => _userAvatarId;

  /// Set avatar ID (called when fetching user data)
  void setAvatarId(String? avatarId) {
    _userAvatarId = avatarId;
    notifyListeners();
  }

  /// Update user's avatar selection
  Future<bool> updateAvatar(String avatarId) async {
    if (currentUser == null) {
      debugPrint('updateAvatar: No current user');
      return false;
    }

    try {
      debugPrint(
        'updateAvatar: Updating avatar to $avatarId for user ${currentUser!.uid}',
      );
      final DatabaseService db = DatabaseService();
      await db.updateUserAvatar(currentUser!.uid, avatarId);
      _userAvatarId = avatarId;
      debugPrint('updateAvatar: Success! Avatar updated to $avatarId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('updateAvatar: Error - $e');
      _errorMessage = 'Failed to update avatar. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
