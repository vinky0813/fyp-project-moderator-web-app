import 'package:flutter/material.dart';
import 'package:fyp_moderator_web_app/pages/RightPanel.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_app_bar.dart';
import '../widgets/moderator_drawer.dart';
import '../models/property_listing.dart';

class ModeratorListingRegistration extends StatefulWidget {
  @override
  State<ModeratorListingRegistration> createState() => _ModeratorListingRegistrationState();
}

class _ModeratorListingRegistrationState extends State<ModeratorListingRegistration> {
  List<PropertyListing> propertyRegistrations = [];
  List<PropertyListing> filteredListings = [];
  TextEditingController searchController = TextEditingController();
  PropertyListing? selectedProperty;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    propertyRegistrations = await PropertyListing.fetchUnpublishedListings();

    print("number of property registrations: ${propertyRegistrations.length}");
    setState(() {
      filteredListings = propertyRegistrations;
    });
  }

  void _filterListings(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredListings = propertyRegistrations;
      });
    } else {
      setState(() {
        filteredListings = propertyRegistrations.where((listing) {
          return listing.listing_title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _removeListing(PropertyListing listing) {
    setState(() {

      propertyRegistrations.remove(listing);

      filteredListings.remove(listing);

      if (selectedProperty == listing) {
        selectedProperty = null;
      }
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
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterListings,
                    decoration: InputDecoration(
                      hintText: 'Search Property Registration',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredListings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              filteredListings[index].image_url.isNotEmpty
                                  ? filteredListings[index].image_url[0]
                                  : 'https://via.placeholder.com/150'
                          ),
                        ),
                        title: Text(filteredListings[index].listing_title),
                        onTap: () {
                          setState(() {
                            selectedProperty = filteredListings[index];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: selectedProperty != null
                ? RightPanel(
              propertyListing: selectedProperty!, onListingUpdated: () { _removeListing(selectedProperty!); },
            )
                : Center(child: Text('Select a property to view details.')),
          ),
        ],
      ),
    );
  }
}
