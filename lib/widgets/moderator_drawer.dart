import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/moderator_chat.dart';
import '../pages/moderator_listing_registration.dart';
import '../pages/moderator_login.dart';
import '../pages/moderator_reports.dart';

class ModeratorDrawer extends StatefulWidget {
  @override
  State<ModeratorDrawer> createState() => _ModeratorDrawerState();
}

class _ModeratorDrawerState extends State<ModeratorDrawer> {
  String? userId;
  String? username;
  String? profilePic;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    print(userId);

    if (userId != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', userId!)
          .single();

      if (response != null) {
        setState(() {
          username = response['username'];
          profilePic = response['avatar_url'];
        });
        print('Username: $username');
        print('Profile Pic URL: $profilePic');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: (profilePic != null && profilePic!.isNotEmpty)
                      ? NetworkImage(profilePic!)
                      : NetworkImage("https://via.placeholder.com/150"),
                  radius: 30,
                ),
                SizedBox(height: 10),
                Text(
                  username ?? 'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              // Handle navigation to dashboard
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('All Properties'),
            onTap: () {
              // Handle navigation to all properties
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat'),
            onTap: () {
              Get.to(() => ModeratorChat());
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Reports'),
            onTap: () {
              Get.to(() => ModeratorReports());
            },
          ),
          ListTile(
            leading: Icon(Icons.app_registration),
            title: Text('Registration'),
            onTap: () {
              Get.to(() => ModeratorListingRegistration());
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              Supabase.instance.client.auth.signOut();
              Get.offAll(() => LoginModerators());
            },
          ),
        ],
      ),
    );
  }
}
