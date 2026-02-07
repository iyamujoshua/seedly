import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedly/models/secret_model.dart';
import 'package:seedly/providers/secrets_provider.dart';
import 'package:seedly/providers/auth_provider.dart';
import 'package:seedly/screens/secrets/secret_detail_screen.dart';
import 'package:seedly/screens/onboarding_screen.dart';
import 'package:seedly/components/avatar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SecretsListScreen extends StatelessWidget {
  const SecretsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final displayName = authProvider.currentUser?.displayName;
    final email = authProvider.currentUser?.email;
    final userName = displayName?.isNotEmpty == true
        ? displayName
        : email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AvatarWidget(
            avatarId: authProvider.userAvatarId,
            size: 40,
            showBorder: false,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName',
              style: const TextStyle(
                fontFamily: 'Geist',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'My Secrets',
              style: TextStyle(
                fontFamily: 'Geist',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF685AFF),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1A1A1A)),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<SecretsProvider>(
        builder: (context, secretsProvider, child) {
          if (secretsProvider.mySecrets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No secrets yet',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first secret',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: secretsProvider.mySecrets.length,
            itemBuilder: (context, index) {
              final secret = secretsProvider.mySecrets[index];
              return _SecretCard(secret: secret);
            },
          );
        },
      ),
    );
  }
}

class _SecretCard extends StatelessWidget {
  final SecretModel secret;

  const _SecretCard({required this.secret});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (secret.isPasswordProtected) {
          _showPasswordDialog(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecretDetailScreen(secret: secret),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media preview if available
            if (secret.mediaUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: secret.mediaUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (secret.isPasswordProtected)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.lock,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          secret.title,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (secret.sharedWith.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${secret.sharedWith.length}',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (secret.description != null &&
                      secret.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      secret.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Enter Password',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This secret is password protected',
                style: TextStyle(fontFamily: 'Geist'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Geist'),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontFamily: 'Geist',
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                onSubmitted: (_) =>
                    _verifyPassword(context, passwordController.text),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  _verifyPassword(context, passwordController.text),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPassword(BuildContext context, String enteredPassword) {
    if (enteredPassword == secret.password) {
      Navigator.pop(context); // Close dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecretDetailScreen(secret: secret),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect password')));
    }
  }
}
