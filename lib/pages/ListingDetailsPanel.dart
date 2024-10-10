import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/ChatService.dart';
import 'package:fyp_moderator_web_app/pages/ChatRightPanel.dart';
import 'package:fyp_moderator_web_app/pages/userinfopage.dart';

import '../models/boolean_variable.dart';
import '../models/property.dart';
import '../models/property_listing.dart';
import '../models/user.dart' as project_user;

class Listingdetailspanel extends StatefulWidget {
  final PropertyListing propertyListing;
  final VoidCallback onListingUpdated;

  const Listingdetailspanel({Key? key, required this.propertyListing, required this.onListingUpdated}) : super(key: key);

  @override
  State<Listingdetailspanel> createState() => _Listingdetailspanelstate();
}

class _Listingdetailspanelstate extends State<Listingdetailspanel> {
  Property? property;
  bool isLoading = true;
  late List<BooleanVariable> trueAmenities;
  String? userid;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    userid = Supabase.instance.client.auth.currentUser?.id;

    property = await Property.getPropertyWithId(widget.propertyListing.property_id);
    trueAmenities = widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(property?.owner.profile_pic ?? ''),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  property?.owner.username ?? 'Loading...',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("View Profile", style: TextStyle(color: Colors.white),),
              onPressed: () {
                Get.to(() => UserInfoPage(user: property!.owner));
              },
            ),
            const SizedBox(width: 20,),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Chat", style: TextStyle(color: Colors.white),),
              onPressed: () async {
                String? groupId = await Chatservice.findOneOnOneGroupId(userid!, property!.owner.id);

                if (groupId != null) {
                  Get.to(() => Chatrightpanel(groupId: groupId));
                } else {
                  final newGroupId = await Chatservice.createGroup([userid!, property!.owner.id]);

                  if (newGroupId != null) {
                    Get.to(() => Chatrightpanel(groupId: newGroupId));
                  } else {
                    Get.snackbar("Error", "Failed to create chat group.");
                  }
                }
              },
            ),
            const SizedBox(width: 20,),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Listing Details"),
              Tab(text: "Review"),
              Tab(text: "Map"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Listing Details Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      viewportFraction: 0.5,
                      height: 400,
                    ),
                    items: widget.propertyListing.image_url.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.propertyListing.listing_title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    'Rating:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow),
                      Text("${widget.propertyListing.rating}/5"),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    'Address:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('${property?.address ?? 'Loading...'}'),
                  const SizedBox(height: 20),
                  const Text(
                    'Preference:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Sex: ${widget.propertyListing.sex_preference}\nNationality: ${widget.propertyListing.nationality_preference}',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Amenities:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: trueAmenities.map((amenity) {
                      return Chip(
                        label: Text(amenity.name),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Price: RM${widget.propertyListing.price}\nDeposit: RM${widget.propertyListing.deposit}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(property!.owner.profile_pic),
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
                                "Owner Name: ${property!.owner.username}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Contact Details: ${property!.owner.contact_no}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          )),
                    ],
                  )
                ],
              ),
            ),
            // Review Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  widget.propertyListing.reviews.isEmpty
                      ? const Center(child: Text('No Reviews'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.propertyListing.reviews.length,
                    itemBuilder: (context, index) {
                      final review = widget.propertyListing.reviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.yellow),
                                Text("${review.rating}/5"),
                              ],
                            ),
                            Text(review.comment),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Map Tab
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(property!.lat, property!.long),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(property!.lat, property!.long),
                        child: Container(
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
