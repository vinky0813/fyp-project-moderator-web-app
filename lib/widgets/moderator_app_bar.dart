import 'package:flutter/material.dart';

class ModeratorAppBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 50.0),
        child: Text(
          "INTI Accommodation Finder",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
