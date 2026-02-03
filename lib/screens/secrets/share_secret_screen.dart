import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedly/components/seedly_button.dart';
import 'package:seedly/models/secret_model.dart';
import 'package:seedly/models/user_model.dart';
import 'package:seedly/providers/secrets_provider.dart';
import 'package:seedly/services/database_service.dart';

class ShareSecretScreen extends StatefulWidget {
  final SecretModel secret;

  const ShareSecretScreen({super.key, required this.secret});

  @override
  State<ShareSecretScreen> createState() => _ShareSecretScreenState();
}

class _ShareSecretScreenState extends State<ShareSecretScreen> {
  final _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _databaseService.searchUsersByEmail(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _shareWithUser(UserModel user) async {
    final secretsProvider = Provider.of<SecretsProvider>(
      context,
      listen: false,
    );
    final success = await secretsProvider.shareSecret(
      widget.secret.id,
      user.uid,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Shared with ${user.email}')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to share')));
      }
    }
  }

  Future<void> _unshareWithUser(String userId) async {
    final secretsProvider = Provider.of<SecretsProvider>(
      context,
      listen: false,
    );
    final success = await secretsProvider.unshareSecret(
      widget.secret.id,
      userId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Access removed')));
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove access')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Share Secret',
          style: TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              style: const TextStyle(fontFamily: 'Geist'),
              decoration: InputDecoration(
                hintText: 'Search by email...',
                hintStyle: TextStyle(
                  fontFamily: 'Geist',
                  color: Colors.grey.shade400,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

          // Currently shared with
          if (widget.secret.sharedWith.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Shared with',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.secret.sharedWith.map(
              (userId) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(30),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  userId.substring(0, 8) + '...',
                  style: const TextStyle(fontFamily: 'Geist'),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => _unshareWithUser(userId),
                ),
              ),
            ),
            const Divider(),
          ],

          // Search results
          if (_searchResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Search Results',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final isAlreadyShared = widget.secret.sharedWith.contains(
                    user.uid,
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(30),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      user.email,
                      style: const TextStyle(fontFamily: 'Geist'),
                    ),
                    subtitle: user.displayName != null
                        ? Text(
                            user.displayName!,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              color: Colors.grey.shade500,
                            ),
                          )
                        : null,
                    trailing: isAlreadyShared
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : SeedlyButton(
                            label: 'Share',
                            onPressed: () => _shareWithUser(user),
                            size: SeedlyButtonSize.small,
                          ),
                  );
                },
              ),
            ),
          ] else if (_searchController.text.isNotEmpty && !_isSearching) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for users by email',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type at least 3 characters',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
