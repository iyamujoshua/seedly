import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seedly/models/secret_model.dart';
import 'package:seedly/models/user_model.dart';

/// Service for Firestore database operations
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _secretsCollection =>
      _db.collection('secrets');

  // ==================== USER OPERATIONS ====================

  /// Create or update user profile
  Future<void> saveUser(UserModel user) async {
    await _usersCollection
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Search users by email
  Future<List<UserModel>> searchUsersByEmail(String email) async {
    final query = await _usersCollection
        .where('email', isGreaterThanOrEqualTo: email)
        .where('email', isLessThanOrEqualTo: '$email\uf8ff')
        .limit(10)
        .get();

    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // ==================== SECRET OPERATIONS ====================

  /// Create a new secret
  Future<void> createSecret(SecretModel secret) async {
    await _secretsCollection.doc(secret.id).set(secret.toFirestore());
  }

  /// Update an existing secret
  Future<void> updateSecret(SecretModel secret) async {
    await _secretsCollection.doc(secret.id).update(secret.toFirestore());
  }

  /// Delete a secret
  Future<void> deleteSecret(String secretId) async {
    await _secretsCollection.doc(secretId).delete();
  }

  /// Get a single secret by ID
  Future<SecretModel?> getSecret(String secretId) async {
    final doc = await _secretsCollection.doc(secretId).get();
    if (doc.exists) {
      return SecretModel.fromFirestore(doc);
    }
    return null;
  }

  /// Get all secrets owned by a user
  Stream<List<SecretModel>> getUserSecrets(String userId) {
    return _secretsCollection
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final secrets = snapshot.docs
              .map((doc) => SecretModel.fromFirestore(doc))
              .toList();
          // Sort by createdAt descending (client-side to avoid needing index)
          secrets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return secrets;
        });
  }

  /// Get all secrets shared with a user
  Stream<List<SecretModel>> getSharedWithMe(String userId) {
    return _secretsCollection
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final secrets = snapshot.docs
              .map((doc) => SecretModel.fromFirestore(doc))
              .toList();
          // Sort by createdAt descending (client-side to avoid needing index)
          secrets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return secrets;
        });
  }

  // ==================== SHARING OPERATIONS ====================

  /// Share a secret with another user
  Future<void> shareSecret(String secretId, String userId) async {
    await _secretsCollection.doc(secretId).update({
      'sharedWith': FieldValue.arrayUnion([userId]),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Unshare a secret from a user
  Future<void> unshareSecret(String secretId, String userId) async {
    await _secretsCollection.doc(secretId).update({
      'sharedWith': FieldValue.arrayRemove([userId]),
      'updatedAt': Timestamp.now(),
    });
  }
}
