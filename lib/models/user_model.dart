import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a Secretly app user
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? avatarId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.avatarId,
    required this.createdAt,
  });

  /// Create from Firebase Auth User
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: DateTime.now(),
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      avatarId: data['avatarId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'avatarId': avatarId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with new values
  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? avatarId,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt,
    );
  }
}
