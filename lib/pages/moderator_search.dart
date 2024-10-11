import 'package:flutter/material.dart';
import 'package:fyp_moderator_web_app/pages/FilterPanel.dart';
import 'package:fyp_moderator_web_app/pages/SearchResultGrid.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_app_bar.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_drawer.dart';
import 'package:get/get.dart';

import '../SearchBarController.dart';

class ModeratorSearch extends StatefulWidget {
  @override
  State<ModeratorSearch> createState() => _ModeratorSearchState();
}


class _ModeratorSearchState extends State<ModeratorSearch> {

  @override
  void initState() {
    super.initState();
    Get.put(SearchResultController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModeratorAppBar(),
      drawer: ModeratorDrawer(),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Filterpanel(),
          ),
          Expanded(
            flex: 5,
            child: SearchResultGrid(),
          ),
        ],
      ),
    );
  }
}
