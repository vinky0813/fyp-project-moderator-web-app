import 'package:flutter/material.dart';
import 'package:fyp_moderator_web_app/pages/ListingDetailsPanel.dart';
import 'package:get/get.dart';
import '../SearchBarController.dart';
import '../models/property_listing.dart';
import '../widgets/SearchBarLocation.dart';

class SearchResultGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SearchResultController searchResultController = Get.find<SearchResultController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchBarLocation(),
        ),
        Expanded(
          child: Obx(() {
            List<PropertyListing> searchResults = searchResultController.searchResult;
            return Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: (MediaQuery.of(context).size.width) /
                      (MediaQuery.of(context).size.height/1.5),
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 20,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  PropertyListing listing = searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => Listingdetailspanel(
                        propertyListing: listing,
                        onListingUpdated: () {},
                      ));
                    },
                    child: Card(
                      elevation: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                              child: Image.network(
                                listing.image_url[0],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.listing_title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '\$${listing.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
