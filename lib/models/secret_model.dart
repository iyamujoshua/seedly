import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for secret media types
enum SecretMediaType { image, video, none }

/// Secret model representing a user's secret
class SecretModel {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final List<String> mediaUrls;
  final SecretMediaType mediaType;
  final List<String> sharedWith;
  final String?
  password; // Password protection (stored as plain text for simplicity, consider hashing in production)
  final DateTime createdAt;
  final DateTime updatedAt;

  SecretModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.mediaUrls = const [],
    this.mediaType = SecretMediaType.none,
    this.sharedWith = const [],
    this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPasswordProtected => password != null && password!.isNotEmpty;

  /// Create a new secret
  factory SecretModel.create({
    required String id,
    required String ownerId,
    required String title,
    String? description,
    List<String> mediaUrls = const [],
    SecretMediaType mediaType = SecretMediaType.none,
    String? password,
  }) {
    final now = DateTime.now();
    return SecretModel(
      id: id,
      ownerId: ownerId,
      title: title,
      description: description,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      sharedWith: [],
      password: password,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Firestore document
  factory SecretModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SecretModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      mediaType: _parseMediaType(data['mediaType']),
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      password: data['password'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType.name,
      'sharedWith': sharedWith,
      'password': password,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copy with new values
  SecretModel copyWith({
    String? title,
    String? description,
    List<String>? mediaUrls,
    SecretMediaType? mediaType,
    List<String>? sharedWith,
    String? password,
  }) {
    return SecretModel(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      sharedWith: sharedWith ?? this.sharedWith,
      password: password ?? this.password,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if user has access to this secret
  bool hasAccess(String userId) {
    return ownerId == userId || sharedWith.contains(userId);
  }

  /// Check if user is the owner
  bool isOwner(String userId) => ownerId == userId;

  static SecretMediaType _parseMediaType(String? type) {
    switch (type) {
      case 'image':
        return SecretMediaType.image;
      case 'video':
        return SecretMediaType.video;
      default:
        return SecretMediaType.none;
    }
  }
}
