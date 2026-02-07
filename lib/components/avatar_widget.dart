import 'package:flutter/material.dart';

/// Avatar configuration with icon and colors
class AvatarConfig {
  final String id;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const AvatarConfig({
    required this.id,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

/// Available avatar options
class AvatarOptions {
  static const List<AvatarConfig> avatars = [
    AvatarConfig(
      id: 'avatar_1',
      icon: Icons.face,
      backgroundColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF4CAF50),
    ),
    AvatarConfig(
      id: 'avatar_2',
      icon: Icons.sentiment_satisfied_alt,
      backgroundColor: Color(0xFFE3F2FD),
      iconColor: Color(0xFF2196F3),
    ),
    AvatarConfig(
      id: 'avatar_3',
      icon: Icons.pets,
      backgroundColor: Color(0xFFFCE4EC),
      iconColor: Color(0xFFE91E63),
    ),
    AvatarConfig(
      id: 'avatar_4',
      icon: Icons.emoji_nature,
      backgroundColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFF9800),
    ),
    AvatarConfig(
      id: 'avatar_5',
      icon: Icons.rocket_launch,
      backgroundColor: Color(0xFFEDE7F6),
      iconColor: Color(0xFF673AB7),
    ),
    AvatarConfig(
      id: 'avatar_6',
      icon: Icons.star,
      backgroundColor: Color(0xFFFFFDE7),
      iconColor: Color(0xFFFFC107),
    ),
    AvatarConfig(
      id: 'avatar_7',
      icon: Icons.favorite,
      backgroundColor: Color(0xFFFFEBEE),
      iconColor: Color(0xFFF44336),
    ),
    AvatarConfig(
      id: 'avatar_8',
      icon: Icons.eco,
      backgroundColor: Color(0xFFE0F2F1),
      iconColor: Color(0xFF009688),
    ),
  ];

  static AvatarConfig getById(String? id) {
    if (id == null) return avatars.first;
    return avatars.firstWhere(
      (avatar) => avatar.id == id,
      orElse: () => avatars.first,
    );
  }
}

/// Reusable widget that renders an avatar by ID
class AvatarWidget extends StatelessWidget {
  final String? avatarId;
  final double size;
  final bool showBorder;
  final bool isSelected;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.avatarId,
    this.size = 80,
    this.showBorder = true,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarOptions.getById(avatarId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avatar.backgroundColor,
          border: showBorder
              ? Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : avatar.iconColor.withAlpha(100),
                  width: isSelected ? 3 : 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(avatar.icon, size: size * 0.5, color: avatar.iconColor),
        ),
      ),
    );
  }
}
