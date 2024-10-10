import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:fyp_moderator_web_app/pages/userinfopage.dart';
import '../models/owner.dart';
import '../models/user.dart' as project_user;
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';

class Chatrightpanel extends StatefulWidget {
  final String groupId;

  Chatrightpanel({required this.groupId});

  @override
  _Chatrightpanelstate createState() => _Chatrightpanelstate();
}

class _Chatrightpanelstate extends State<Chatrightpanel> {

  List<types.Message> _messages = [];
  String? userId;
  late types.User _user;
  List<types.User> _groupMembers = [];
  List<String> _fcmTokens = [];
  late Map<String, dynamic> _serviceAccount;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
      _user = types.User(id: userId!);
    }
    _loadServiceAccount();
    _loadMessages();
    _subscribeToMessages();
    _fetchGroupMembers();
  }

  @override
  void didUpdateWidget(Chatrightpanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      _loadMessages();
      _fetchGroupMembers();
    }
  }

  Future<String> getAccessToken() async {
    final serviceAccount = await loadServiceAccount();
    final clientEmail = serviceAccount['client_email'];
    final privateKey = serviceAccount['private_key'];

    const scopes = 'https://www.googleapis.com/auth/firebase.messaging';

    final accountCredentials = ServiceAccountCredentials(
      clientEmail,
      privateKey,
      scopes,
    );

    final client = await clientViaServiceAccount(accountCredentials, [scopes]);

    final response = await client.get(Uri.parse('https://www.googleapis.com/token'));

    return client.credentials.accessToken.data;
  }

  Future<Map<String, dynamic>> loadServiceAccount() async {
    final jsonString = await rootBundle.loadString('lib/service-account.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  }

  Future<void> _loadServiceAccount() async {
    _serviceAccount = await loadServiceAccount();
  }

  Future<void> _fetchGroupMembers() async {
    final response = await Supabase.instance.client
        .from('Group_Members')
        .select('user_id, profiles(username, avatar_url, user_type, fcm_token)')
        .eq('group_id', widget.groupId);

    if (response != null) {
      final members = (response as List<dynamic>).map((member) {
        return types.User(
            id: member['user_id'],
            firstName: member['profiles']['username'],
            imageUrl: member['profiles']['avatar_url']?.trim(),
            metadata: {
              "userType": member['profiles']['user_type'],
              "fcm_token": member['profiles']['fcm_token'],
            }
        );
      }).toList();

      setState(() {
        _groupMembers = members;
        _fcmTokens = members.map((member) => member.metadata?['fcm_token'] as String?).whereType<String>().toList();
      });
    }
  }

  void _showGroupMembers() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Group Members'),
          content: SingleChildScrollView(
            child: Column(
              children: _groupMembers.map((user) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.imageUrl != null
                        ? NetworkImage(user.imageUrl!)
                        : null,
                    child: user.imageUrl == null
                        ? Text(user.firstName?.substring(0, 1) ?? 'A')
                        : null,
                  ),
                  title: Text(user.firstName ?? 'Unknown'),
                  onTap: () async {
                    if (user.metadata?['userType'] == 'renter') {

                      final projectUser = await project_user.User.getUserById(user.id);

                      Get.to(() => UserInfoPage(user: projectUser));
                    } else if (user.metadata?['userType'] == 'owner') {
                      final owner = await Owner.getOwnerWithId(user.id);

                      Get.to(() => UserInfoPage(user: owner));
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _subscribeToMessages() {
    Supabase.instance.client
        .channel('realtime:public')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'Messages',
      callback: (payload) {
        final newMessage = payload.newRecord;
        final message = types.TextMessage(
          author: types.User(id: newMessage['sender_id']),
          createdAt: DateTime.parse(newMessage['created_at']).millisecondsSinceEpoch,
          id: newMessage['id'],
          text: newMessage['content'],
        );
        setState(() {
          _messages.insert(0, message);
        });
      },
    ).subscribe();
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );
    await _saveMessageToDatabase(textMessage);
    await _insertMessageReadStatus(textMessage);
    await _sendNotifications(textMessage);
    await _markMessageAsRead(textMessage.id);
  }

  Future<void> _saveMessageToDatabase(types.TextMessage message) async {
    final response = await Supabase.instance.client
        .from('Messages')
        .insert({
      'id': message.id,
      'group_id': widget.groupId,
      'sender_id': _user.id,
      'content': message.text,
    });
  }

  Future<void> _loadMessages() async {
    final response = await Supabase.instance.client
        .from("Messages")
        .select()
        .eq('group_id', widget.groupId)
        .order('created_at', ascending: false);

    final loadedMessages = response.map<types.TextMessage>((message) {
      return types.TextMessage(
        author: types.User(id: message['sender_id']),
        createdAt: DateTime.parse(message['created_at']).millisecondsSinceEpoch,
        id: message['id'],
        text: message['content'],
      );
    }).toList();

    setState(() {
      _messages = loadedMessages;
    });

    for (var message in loadedMessages) {
      await _markMessageAsRead(message.id);
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    final existingStatus = await Supabase.instance.client
        .from('Message_Read_Status')
        .select('id')
        .eq('message_id', messageId)
        .eq('user_id', _user.id)
        .single();

    if (existingStatus != null) {
      await Supabase.instance.client
          .from('Message_Read_Status')
          .update({'is_read': true})
          .eq('message_id', messageId)
          .eq('user_id', _user.id);
    }
  }

  Future<void> _insertMessageReadStatus(types.TextMessage message) async {
    for (final member in _groupMembers) {
      await Supabase.instance.client
          .from('Message_Read_Status')
          .insert({
        'message_id': message.id,
        'user_id': member.id,
        'is_read': false,
      });
    }
  }

  Future<void> _sendNotifications(types.TextMessage message) async {
    for (String token in _fcmTokens) {
      await _sendFCMNotification(token, message);
    }
  }

  Future<void> _sendFCMNotification(String fcmToken, types.TextMessage message) async {

    if (message.author.id == _user.id) {
      return;
    }

    print("SENDING NOTIFICATION");
    final accessToken = await getAccessToken();
    final url = 'https://fcm.googleapis.com/v1/projects/${_serviceAccount["project_id"]}/messages:send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({
      "message": {
        "token": fcmToken,
        "notification": {
          "title": "New Message in Group ${widget.groupId}",
          "body": message.text,
        },
      }
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Notification sent successfully!');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _showGroupMembers,
          ),
        ],),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
      ),
    );
  }
}
