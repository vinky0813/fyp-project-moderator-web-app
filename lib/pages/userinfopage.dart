import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/pages/ChatRightPanel.dart';
import 'package:fyp_moderator_web_app/pages/propertyinfopage.dart';
import '../ChatService.dart';
import '../models/owner.dart';
import '../models/property.dart';
import '../models/property_listing.dart';
import '../models/user.dart' as project_user;

class UserInfoPage extends StatefulWidget {
  final dynamic user;

  UserInfoPage({required this.user});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late List<Property> propertyList;
  PropertyListing? propertyListing;
  bool isLoading = true;
  String? userid;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    userid = Supabase.instance.client.auth.currentUser?.id;

    if (widget.user is Owner) {
      propertyList = await Property.getOwnerProperties(widget.user as Owner);
    } else if (widget.user is project_user.User) {
      if (widget.user.isAccommodating) {
        propertyListing = await PropertyListing.getCurrentProperty(widget.user.listing_id);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : widget.user is Owner
          ? OwnerInfo(owner: widget.user as Owner, properties: propertyList, userid: userid,)
          : RenterInfo(renter: widget.user as project_user.User, propertyListing: propertyListing, userid: userid),
    );
  }
}

class OwnerInfo extends StatelessWidget {
  final Owner owner;
  final List<Property> properties;
  final String? userid;

  OwnerInfo({required this.owner, required this.properties, required this.userid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(owner.profile_pic),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Owner Name: ${owner.username}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Chat", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      String? groupId = await Chatservice.findOneOnOneGroupId(userid!, owner.id);

                      if (groupId != null) {
                        Get.to(() => Chatrightpanel(groupId: groupId));
                      } else {
                        final newGroupId = await Chatservice.createGroup([userid!, owner.id]);

                        if (newGroupId != null) {
                          Get.to(() => Chatrightpanel(groupId: newGroupId));
                        } else {
                          Get.snackbar("Error", "Failed to create chat group.");
                        }
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('User ID: ${owner.id}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Properties Owned:', style: TextStyle(fontSize: 18)),
              Expanded(
                child: properties.isNotEmpty
                    ? ListView.builder(
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => Propertyinfopage(property: properties[index]));
                      },
                      child: Container(
                        width: 500,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(properties[index].imageUrl),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          title: Text(properties[index].property_title),
                          subtitle: Text('Location: ${properties[index].address}'),
                        ),
                      ),
                    );
                  },
                )
                    : Center(child: Text('No properties owned.')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RenterInfo extends StatelessWidget {
  final project_user.User renter;
  final PropertyListing? propertyListing;
  final String? userid;

  RenterInfo({required this.renter, this.propertyListing, this.userid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(renter.profilePic),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Renter Name: ${renter.username}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Chat", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      // Use the userid
                      String? groupId = await Chatservice.findOneOnOneGroupId(userid!, renter.id);

                      if (groupId != null) {
                        Get.to(() => Chatrightpanel(groupId: groupId));
                      } else {
                        final newGroupId = await Chatservice.createGroup([userid!, renter.id]);

                        if (newGroupId != null) {
                          Get.to(() => Chatrightpanel(groupId: newGroupId));
                        } else {
                          Get.snackbar("Error", "Failed to create chat group.");
                        }
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Renter ID: ${renter.id}', style: TextStyle(fontSize: 16)),
              if (propertyListing != null)
                Row(
                  children: [
                    Image.network(
                      propertyListing!.image_url[0],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Currently Occupying: ${propertyListing!.listing_title}'),
                        Text('Listing ID: ${propertyListing!.listing_id}'),
                      ],
                    ),
                  ],
                )
              else
                Text('Currently not occupying any property.'),
            ],
          ),
        ),
      ),
    );
  }
}
