import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ChatService.dart';
import '../widgets/UserSearchDialog.dart';

class ChatListPanel extends StatefulWidget {
  final Function(String) onChatSelected;

  ChatListPanel({required this.onChatSelected});

  @override
  _ChatListPanelState createState() => _ChatListPanelState();
}

class _ChatListPanelState extends State<ChatListPanel> {
  List<String> _groupIds = [];
  String? userId;
  List<String?> chatThumbnailUrl = [];
  bool isLoading = true;
  List<int> unreadMessagesCount = [];
  List<String> chatNames = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
      await _loadGroupIds();
      await _loadChatPictures();
      await _loadUnreadMessagesCount();
      await _fetchGroupMembers();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchGroupMembers() async {
    for (String groupId in _groupIds){
      final response = await Supabase.instance.client
          .from('Group_Members')
          .select('user_id, profiles(username)')
          .eq('group_id', groupId);

      if (response != null) {
        List groupUsernames = response.map((member) => member['profiles']['username'] ?? 'Unknown User').toList();
        chatNames.add(groupUsernames.join(', '));
      }
    }
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      unreadMessagesCount = List.filled(_groupIds.length, 0);

      final unreadMessagesResponse = await Supabase.instance.client
          .from('Message_Read_Status')
          .select('message_id')
          .eq('is_read', false)
          .eq('user_id', userId!);

      if (unreadMessagesResponse.isNotEmpty) {
        List<dynamic> unreadMessagesData = unreadMessagesResponse;
        Map<String, int> groupUnreadCount = {};

        for (var message in unreadMessagesData) {
          final messageId = message['message_id'];

          final messageResponse = await Supabase.instance.client
              .from('Messages')
              .select('group_id')
              .eq('id', messageId)
              .single();

          if (messageResponse != null) {
            String groupId = messageResponse['group_id'];

            groupUnreadCount[groupId] = (groupUnreadCount[groupId] ?? 0) + 1;
          }
        }

        for (int i = 0; i < _groupIds.length; i++) {
          String groupId = _groupIds[i];
          unreadMessagesCount[i] = groupUnreadCount[groupId] ?? 0;
        }
      }
      setState(() {});
    } catch (error) {
      print('Error fetching unread messages count: $error');
    }
  }

  Future<void> _loadChatPictures() async {
    try {
      chatThumbnailUrl.clear();
      for (String groupId in _groupIds) {
        final response = await Supabase.instance.client
            .from('Group_Members')
            .select('user_id')
            .eq('group_id', groupId)
            .limit(1)
            .single();

        if (response != null) {
          String firstUserId = response['user_id'];

          final profileResponse = await Supabase.instance.client
              .from('profiles')
              .select('avatar_url')
              .eq('id', firstUserId)
              .single();

          if (profileResponse != null) {
            String? avatarUrl = profileResponse['avatar_url']?.trim();
            chatThumbnailUrl.add(avatarUrl);
          } else {
            chatThumbnailUrl.add(null);
          }
        }
      }
      setState(() {});
    } catch (error) {
      print('Error fetching user IDs or avatar URLs: $error');
    }
  }

  Future<void> _loadGroupIds() async {
    try {
      final response = await Supabase.instance.client
          .from('Group_Members')
          .select('group_id')
          .eq('user_id', userId!);

      setState(() {
        _groupIds = List<String>.from(response.map((item) => item['group_id']));
      });
    } catch (error) {
      print('Error fetching group IDs: $error');
    }
  }

  Future<void> _refreshChatList(String newGroupId) async {
    _groupIds.add(newGroupId);
    await _loadChatPictures();
    await _loadUnreadMessagesCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _groupIds.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                backgroundImage: chatThumbnailUrl[index] != null
                    ? NetworkImage(chatThumbnailUrl[index]!)
                    : null,
                child: chatThumbnailUrl[index] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text("${chatNames[index]}"),
              subtitle: unreadMessagesCount[index] > 0
                  ? Text(
                "${unreadMessagesCount[index]} unread message(s)",
                style: TextStyle(color: Colors.red),
              )
                  : null,
              onTap: () {
                widget.onChatSelected(_groupIds[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => UserSearchDialog(
              onUserSelected: (String selectedUserId) async {
                final currentUserId = userId;
                final groupId = await Chatservice.findOneOnOneGroupId(selectedUserId, currentUserId!);

                if (groupId == null) {
                  final newGroupId = await Chatservice.createGroup([selectedUserId, currentUserId]);
                  widget.onChatSelected(newGroupId!);
                  await _refreshChatList(newGroupId);
                } else {
                  widget.onChatSelected(groupId);
                  await _refreshChatList(groupId);
                }
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
