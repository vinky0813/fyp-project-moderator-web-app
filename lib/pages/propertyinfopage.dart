import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/ChatService.dart';
import 'package:fyp_moderator_web_app/pages/ChatRightPanel.dart';
import 'package:fyp_moderator_web_app/pages/ListingDetailsPanel.dart';
import 'package:fyp_moderator_web_app/pages/userinfopage.dart';
import '../models/property.dart';
import '../models/property_listing.dart';
import '../models/user.dart' as project_user;

class Propertyinfopage extends StatefulWidget {
  final Property property;

  Propertyinfopage({required this.property});

  @override
  State<Propertyinfopage> createState() => _PropertyinfopageState();
}

class _PropertyinfopageState extends State<Propertyinfopage> {
  List<PropertyListing> propertyListings = [];
  List<project_user.User> tenantList = [];
  bool isLoading = true;
  String? userid;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {

    userid = Supabase.instance.client.auth.currentUser?.id;
    try {
      propertyListings = await PropertyListing.getPropertyListing(widget.property.property_id);
      tenantList = await project_user.User.getTenants(widget.property.property_id);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading // Check loading state
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Name
            Text(
              widget.property.property_title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Owner Info
            GestureDetector(
              onTap: () {
                Get.to(() => UserInfoPage(user: widget.property.owner));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.property.owner.profile_pic),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Owner Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Owner Name: ${widget.property.owner.username}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Contact Details: ${widget.property.owner.contact_no}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Listings
            Text('Listings:', style: TextStyle(fontSize: 18)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: propertyListings.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => Listingdetailspanel(
                        propertyListing: propertyListings[index],
                        onListingUpdated: () {},
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (propertyListings[index].image_url[0] != null)
                            Image.network(
                              propertyListings[index].image_url[0],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          SizedBox(width: 40,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                propertyListings[index].listing_title!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Price: ${propertyListings[index].price}'),
                              Text(
                                'Occupied by: ${propertyListings[index].tenant != null ? propertyListings[index].tenant!.username : "Not occupied"}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // Address
            Text('Address:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(widget.property.address),
            SizedBox(height: 20),
            // Tenants
            Text('Tenants:', style: TextStyle(fontSize: 18)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tenantList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(tenantList[index].profilePic),
                        ),
                        onTap: () {
                          Get.to(() => UserInfoPage(user: tenantList[index]),
                              transition: Transition.circularReveal,
                              duration: const Duration(seconds: 1));
                        },
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${tenantList[index].username}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  onPressed: () async {
                                    String? groupId = await Chatservice.findOneOnOneGroupId(userid!, tenantList[index].id);

                                    if (groupId != null) {
                                      Get.to(() => Chatrightpanel(groupId: groupId));
                                    } else {
                                      final newGroupId = await Chatservice.createGroup([userid!, tenantList[index].id]);

                                      if (newGroupId != null) {
                                        Get.to(() => Chatrightpanel(groupId: newGroupId));
                                      } else {
                                        Get.snackbar("Error", "Failed to create chat group.");
                                      }
                                    }
                                  },
                                  style: IconButton.styleFrom(backgroundColor: Colors.black),
                                  icon: Icon(Icons.chat, color: Colors.white,),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
