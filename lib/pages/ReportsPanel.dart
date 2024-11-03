import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/models/report.dart';
import 'package:fyp_moderator_web_app/pages/userinfopage.dart';

import '../ChatService.dart';
import '../models/boolean_variable.dart';
import '../models/property.dart';
import '../models/property_listing.dart';
import 'ChatRightPanel.dart';

class Reportspanel extends StatefulWidget {
  final PropertyListing propertyListing;
  final List<Report> reports;
  final VoidCallback onListingUpdated;

  const Reportspanel({Key? key, required this.propertyListing, required this.reports, required this.onListingUpdated}) : super(key: key);

  @override
  State<Reportspanel> createState() => _Reportspanelstate();
}

class _Reportspanelstate extends State<Reportspanel> {
  Property? property;
  bool isLoading = true;
  late List<BooleanVariable> trueAmenities;
  String? userId;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;
    property = await Property.getPropertyWithId(widget.propertyListing.property_id);
    trueAmenities = widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);

    setState(() {
      isLoading = false;
    });
  }

  void _resolveReportAndRemoveDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Resolve and Remove'),
          content: const Text('Are you sure you want to resolve and remove this listing'),
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
                _resolveReportAndRemove(widget.propertyListing.listing_id);
                Get.snackbar('Success', 'Listing Removed successfully.');
                widget.onListingUpdated();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _resolveReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Resolve'),
          content: const Text('Are you sure you want to resolve this listing?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                for (Report report in widget.reports) {
                  await _resolveReport(report.report_id);
                }
                Get.snackbar('Success', 'Report Resolved successfully.');
                widget.onListingUpdated();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resolveReport(String reportId) async {
    try {

      final response = await Supabase.instance.client
          .from('Reports')
          .update({'status': 'resolved'})
          .eq('report_id', reportId);

      if (response != null) {
        print('Report $reportId has been resolved successfully.');
      } else {
        print('Error resolving report: Report not found.');
      }
    } catch (e) {
      print('Error resolving report: $e');
    }
  }

  Future<void> _resolveReportAndRemove(String listingId) async {
    try {
      await PropertyListing.deleteListing(listingId);

      print('Listing $listingId has been deleted successfully.');
      Get.snackbar('Success', 'Listing deleted successfully.');
    } catch (e) {
      print('Error resolving report and deleting listing: $e');
    }
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
              const Text("Listing Owner: "),
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
              child: const Text("View Profile", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Get.to(() => UserInfoPage(user: property!.owner));
              },
            ),
            const SizedBox(width: 20),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Chat", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                String? groupId = await Chatservice.findOneOnOneGroupId(
                    userId!, property!.owner.id);

                if (groupId != null) {
                  Get.to(() => Chatrightpanel(groupId: groupId));
                } else {
                  final newGroupId = await Chatservice.createGroup(
                      [userId!, property!.owner.id]);

                  if (newGroupId != null) {
                    Get.to(() => Chatrightpanel(groupId: newGroupId));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to create chat group")));
                  }
                }
              },
            ),
            const SizedBox(width: 20),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Listing Details"),
              Tab(text: "Review"),
              Tab(text: "Map"),
            ],
          ),
        ),
        body: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 250,
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reports",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.reports.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 200,
                              child: ListTile(
                                title: Text(widget.reports[index].reason),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (widget.reports[index].details != null && widget.reports[index].details.isNotEmpty)
                                          ? widget.reports[index].details
                                          : "No Details Provided",
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Reported by: ${widget.reports[index].reported_by.username}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
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
                            const SizedBox(height: 20),
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
                                  ),
                                ),
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
              ],
            ),
            Positioned( // Position the buttons in the bottom right corner
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _resolveReportDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Resolve Report', style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _resolveReportAndRemoveDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete Listing', style: TextStyle(color: Colors.black),),
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
