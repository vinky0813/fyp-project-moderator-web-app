import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSearchDialog extends StatefulWidget {
  final Function(String userId) onUserSelected;

  UserSearchDialog({required this.onUserSelected});

  @override
  _UserSearchDialogState createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  List<Map<String, dynamic>> _searchResults = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchAllUsers();
  }

  Future<void> _fetchCurrentUserId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      currentUserId = user.id;
    }
  }

  Future<void> _fetchAllUsers() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name');

    setState(() {
      _searchResults = (response as List<Map<String, dynamic>>)
          .where((user) => user['id'] != currentUserId)
          .toList();
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      await _fetchAllUsers();
      return;
    }

    final response = await Supabase.instance.client
        .from('profiles')
        .select('id, full_name')
        .ilike('full_name', '%$query%');

    setState(() {
      _searchResults = (response as List<Map<String, dynamic>>)
          .where((user) => user['id'] != currentUserId)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _searchUsers,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  title: Text(user['full_name']),
                  onTap: () {
                    widget.onUserSelected(user['id']);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
