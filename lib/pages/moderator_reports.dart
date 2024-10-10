import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/pages/ReportsPanel.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_app_bar.dart';
import '../models/report.dart';
import '../widgets/moderator_drawer.dart';
import '../models/property_listing.dart';

class ModeratorReports extends StatefulWidget {
  @override
  State<ModeratorReports> createState() => _ModeratorReportsState();
}

class _ModeratorReportsState extends State<ModeratorReports> {
  List<Report> reportLists = [];
  List<PropertyListing> propertyListings = [];
  PropertyListing? selectedListing;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    reportLists = await fetchPendingReports();

    Set<String> uniqueListingIds = {};
    List<PropertyListing> fetchedPropertyListings = [];

    for (var report in reportLists) {
      if (uniqueListingIds.add(report.listing_id)) {
        PropertyListing? listing = await fetchPropertyListingById(report.listing_id);
        if (listing != null) {
          fetchedPropertyListings.add(listing);
        }
      }
    }

    print(fetchedPropertyListings.length);

    setState(() {
      propertyListings = fetchedPropertyListings;
    });
  }

  Future<List<Report>> fetchPendingReports() async {
    try {
      final response = await Supabase.instance.client
          .from('Reports')
          .select('*')
          .eq('status', 'pending');

      if (response != null) {
        List<Future<Report>> reportFutures = (response as List)
            .map((data) => Report.fromJson(data))
            .toList();

        return await Future.wait(reportFutures);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching pending reports: $e');
      return [];
    }
  }


  Future<PropertyListing?> fetchPropertyListingById(String listingId) async {
    return await PropertyListing.getCurrentProperty(listingId);
  }

  void _removeReport(PropertyListing listing) {
    setState(() {
      propertyListings.remove(listing);

      if (selectedListing == listing) {
        selectedListing = null;
      }
    });
  }

  List<Report> _getReportsForListing(PropertyListing listing) {
    return reportLists.where((report) => report.listing_id == listing.listing_id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModeratorAppBar(),
      drawer: ModeratorDrawer(),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: propertyListings.isNotEmpty
                      ? ListView.builder(
                    itemCount: propertyListings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            propertyListings[index].image_url.isNotEmpty
                                ? propertyListings[index].image_url[0]
                                : 'https://via.placeholder.com/150',
                          ),
                        ),
                        title: Text(propertyListings[index].listing_title),
                        onTap: () {
                          setState(() {
                            selectedListing = propertyListings[index];
                          });
                        },
                      );
                    },
                  ) : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No Pending Reports.'),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            flex: 3,
            child: selectedListing != null
                ? Reportspanel(
              propertyListing: selectedListing!,
              reports: _getReportsForListing(selectedListing!),
              onListingUpdated: () { _removeReport(selectedListing!); },
            )
                : Center(child: Text('Select a listing to view associated reports.')),
          ),
        ],
      ),
    );
  }
}
