import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/pages/userinfopage.dart';

import '../models/boolean_variable.dart';
import '../models/property.dart';
import '../models/property_listing.dart';

class RightPanel extends StatefulWidget {
  final PropertyListing propertyListing;
  final VoidCallback onListingUpdated;

  const RightPanel({Key? key, required this.propertyListing, required this.onListingUpdated}) : super(key: key);

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  Property? property;
  bool isLoading = true;
  late List<BooleanVariable> trueAmenities;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    property = await Property.getPropertyWithId(widget.propertyListing.property_id);
    trueAmenities = widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);

    setState(() {
      isLoading = false;
    });
  }


  Future<void> acceptListing() async {
    try {
      final response = await Supabase.instance.client
          .from('Listing')
          .update({'isPublished': true})
          .eq('listing_id', widget.propertyListing.listing_id);

      Get.snackbar('Success', 'Listing accepted successfully.');

    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Accept'),
          content: const Text('Are you sure you want to accept this listing?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                acceptListing();
                widget.onListingUpdated();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showDenyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deny'),
          content: const Text('Are you sure you want to deny this listing?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PropertyListing.deleteListing(widget.propertyListing.listing_id);
                widget.onListingUpdated();
              },
              child: const Text('Deny'),
            ),
          ],
        );
      },
    );
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
              const Text("Submitted by: "),
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
          automaticallyImplyLeading: false,
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
              onPressed: () {

              },
            ),
            const SizedBox(width: 20,),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Listing Details"),
              Tab(text: "Map"),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
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
            // Floating Action Button
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () {
                      _showAcceptDialog();
                    },
                    child: const Text("Accept", style: TextStyle(color: Colors.white),)
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                      backgroundColor: Colors.black,
                    onPressed: () {
                      _showDenyDialog();
                    },
                    child: const Text("Deny", style: TextStyle(color: Colors.white),)
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
