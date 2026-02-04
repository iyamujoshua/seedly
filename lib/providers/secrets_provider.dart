import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:seedly/models/secret_model.dart';
import 'package:seedly/services/database_service.dart';
// import 'package:seedly/services/storage_service.dart'; // Disabled - requires Blaze plan
import 'package:uuid/uuid.dart';

/// Provider for managing secrets state
class SecretsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  // final StorageService _storageService = StorageService(); // Disabled - requires Blaze plan
  final Uuid _uuid = const Uuid();

  List<SecretModel> _mySecrets = [];
  List<SecretModel> _sharedWithMe = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  // Getters
  List<SecretModel> get mySecrets => _mySecrets;
  List<SecretModel> get sharedWithMe => _sharedWithMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize provider with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    _listenToSecrets(userId);
    _listenToSharedSecrets(userId);
  }

  /// Listen to user's own secrets
  void _listenToSecrets(String userId) {
    _databaseService
        .getUserSecrets(userId)
        .listen(
          (secrets) {
            _mySecrets = secrets;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = 'Failed to load secrets';
            notifyListeners();
          },
        );
  }

  /// Listen to secrets shared with user
  void _listenToSharedSecrets(String userId) {
    _databaseService
        .getSharedWithMe(userId)
        .listen(
          (secrets) {
            _sharedWithMe = secrets;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = 'Failed to load shared secrets';
            notifyListeners();
          },
        );
  }

  /// Create a new secret
  Future<bool> createSecret({
    required String title,
    String? description,
    List<File>? mediaFiles,
    SecretMediaType mediaType = SecretMediaType.none,
    String? password,
  }) async {
    if (_currentUserId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final secretId = _uuid.v4();
      List<String> mediaUrls = [];

      // Skip media upload for now - Firebase Storage requires Blaze plan
      // TODO: Re-enable when storage is available
      // if (mediaFiles != null && mediaFiles.isNotEmpty) {
      //   mediaUrls = await _storageService.uploadFiles(
      //     files: mediaFiles,
      //     userId: _currentUserId!,
      //     secretId: secretId,
      //   );
      // }

      // Create secret
      final secret = SecretModel.create(
        id: secretId,
        ownerId: _currentUserId!,
        title: title,
        description: description,
        mediaUrls: mediaUrls,
        mediaType: SecretMediaType.none, // Force text-only for now
        password: password,
      );

      await _databaseService.createSecret(secret);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create secret: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Delete a secret
  Future<bool> deleteSecret(SecretModel secret) async {
    if (_currentUserId == null) return false;
    if (!secret.isOwner(_currentUserId!)) return false;

    _setLoading(true);
    _clearError();

    try {
      // Skip media deletion - Firebase Storage requires Blaze plan
      // TODO: Re-enable when storage is available
      // await _storageService.deleteSecretFiles(
      //   userId: _currentUserId!,
      //   secretId: secret.id,
      // );

      // Delete secret document
      await _databaseService.deleteSecret(secret.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete secret';
      _setLoading(false);
      return false;
    }
  }

  /// Share a secret with another user
  Future<bool> shareSecret(String secretId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.shareSecret(secretId, userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to share secret';
      _setLoading(false);
      return false;
    }
  }

  /// Unshare a secret from a user
  Future<bool> unshareSecret(String secretId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.unshareSecret(secretId, userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unshare secret';
      _setLoading(false);
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

  /// Clean up when user logs out
  void reset() {
    _mySecrets = [];
    _sharedWithMe = [];
    _currentUserId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
