import 'package:flutter/material.dart';
import 'package:fyp_moderator_web_app/pages/ChatListPanel.dart';
import 'package:fyp_moderator_web_app/pages/ChatRightPanel.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_app_bar.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_drawer.dart';

class ModeratorChat extends StatefulWidget {
  @override
  _ModeratorChatState createState() => _ModeratorChatState();
}

class _ModeratorChatState extends State<ModeratorChat> {
  String? selectedGroupId;

  void _onChatSelected(String groupId) {
    setState(() {
      selectedGroupId = groupId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModeratorAppBar(),
      drawer: ModeratorDrawer(),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ChatListPanel(
              onChatSelected: _onChatSelected,
            ),
          ),
          Expanded(
            flex: 7,
            child: selectedGroupId != null
                ? Chatrightpanel(groupId: selectedGroupId!)
                : Center(child: Text("Select a chat to view messages")),
          ),
        ],
      ),
    );
  }
}
