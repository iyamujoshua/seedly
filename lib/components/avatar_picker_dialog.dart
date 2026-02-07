import 'package:flutter/material.dart';
import 'package:seedly/components/avatar_widget.dart';

/// Dialog for selecting an avatar
class AvatarPickerDialog extends StatelessWidget {
  final String? currentAvatarId;
  final Function(String) onAvatarSelected;

  const AvatarPickerDialog({
    super.key,
    this.currentAvatarId,
    required this.onAvatarSelected,
  });

  static Future<String?> show(BuildContext context, {String? currentAvatarId}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AvatarPickerDialog(
        currentAvatarId: currentAvatarId,
        onAvatarSelected: (avatarId) {
          Navigator.pop(context, avatarId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Choose Your Avatar',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an avatar to personalize your profile',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Avatar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: AvatarOptions.avatars.length,
            itemBuilder: (context, index) {
              final avatar = AvatarOptions.avatars[index];
              final isSelected =
                  avatar.id == currentAvatarId ||
                  (currentAvatarId == null && index == 0);

              return AvatarWidget(
                avatarId: avatar.id,
                size: 70,
                isSelected: isSelected,
                onTap: () => onAvatarSelected(avatar.id),
              );
            },
          ),

          const SizedBox(height: 24),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          // Safe area padding for bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
