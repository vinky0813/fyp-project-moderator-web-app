import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../SearchBarController.dart';
import '../models/boolean_variable.dart';
import '../models/property_listing.dart';
import 'dart:developer' as developer;

class SearchBarLocation extends StatefulWidget {
  @override
  SearchBarLocationState createState() => SearchBarLocationState();
}

class SearchBarLocationState extends State<SearchBarLocation> {
  final TextEditingController _searchBarController = TextEditingController();
  List<dynamic> suggestions = [];
  double? lat = 0;
  double? long = 0;
  final SearchResultController searchResultController = Get.find<SearchResultController>();
  Map<String, dynamic>? filterData;

  @override
  void initState() {
    super.initState();

    ever(searchResultController.location, (value) {
      developer.log("update location in controller, $value");
      _searchBarController.text = value;
    });

    ever(searchResultController.filterData, (value) {
      developer.log("filter data in controller, $value");
      filterData = value;
    });
  }

  void _onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      final response = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1"));
      if (response.statusCode == 200) {
        setState(() {
          suggestions = json.decode(response.body);
        });
      } else {
        setState(() {
          suggestions = [];
        });
      }
    } else {
      setState(() {
        suggestions = [];
      });
    }
  }

  void onSearchSubmitted() async {
    String value = _searchBarController.text.trim();
    if (value.isNotEmpty) {
      final response = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1"));
      if (response.statusCode == 200) {
        var results = json.decode(response.body);
        if (results.isNotEmpty) {
          lat = double.tryParse(results[0]["lat"]);
          long = double.tryParse(results[0]["lon"]);
          List<PropertyListing> searchResult = await PropertyListing.getSearchResult(lat!, long!);
          searchResultController.updateLocationLat(lat!);
          searchResultController.updateLocationLong(long!);

          searchResultController.updateSearchResultUnfiltered(searchResult);

          developer.log("search result length 2: ${searchResult.length}");

          List<PropertyListing> filteredResults = _filterSearchResults(searchResult);

          searchResultController.updateSearchResult(filteredResults);
          searchResultController.updateLocation(value);

          setState(() {});
        }
      }
    }
  }

  List<PropertyListing> _filterSearchResults(List<PropertyListing> searchResult) {
    List<PropertyListing> filteredResults = [];

    for (PropertyListing listing in searchResult) {
      bool shouldAddListing = true;

      if (filterData != null) {
        double? minPrice = filterData?["min_price"];
        double? maxPrice = filterData?["max_price"];

        if ((minPrice != null && listing.price < minPrice) ||
            (maxPrice != null && listing.price > maxPrice)) {
          developer.log("Filtered by price");
          shouldAddListing = false;
        }

        String preferredNationality = filterData?["nationality_preference"];
        if (preferredNationality != null && preferredNationality != "no preference" &&
            listing.nationality_preference != preferredNationality) {
          developer.log("Filtered by nationality");
          shouldAddListing = false;
        }

        String preferredSex = filterData?["sex_preference"];
        if (preferredSex != null && preferredSex != "no preference" &&
            listing.sex_preference != preferredSex) {
          developer.log("Filtered by sex");
          shouldAddListing = false;
        }

        String preferredRoomType = filterData?["room_type"];
        if (preferredRoomType != null && preferredRoomType.isNotEmpty &&
            listing.room_type != preferredRoomType) {
          developer.log("Filtered by room type");
          shouldAddListing = false;
        }

        if (filterData?["amenities"] != null) {
          List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filterData?["amenities"]);
          for (var amenity in requiredAmenities) {
            String amenityName = amenity.name;
            if (amenity.value) {
              var listingAmenity = listing.amenities.firstWhere(
                    (element) => element.name == amenityName,
                orElse: () => BooleanVariable(name: amenityName, value: false),
              );
              if (!listingAmenity.value) {
                developer.log("Filtered out by missing amenity: $amenityName");
                shouldAddListing = false;
                break;
              }
            }
          }
        }
      }
      if (shouldAddListing) {
        filteredResults.add(listing);
      }
    }
    return filteredResults;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 30),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchBarController,
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              onSearchSubmitted();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter Location",
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(suggestions[index]["display_name"]),
                      onTap: () async {
                        _searchBarController.text = suggestions[index]["display_name"];
                        lat = double.tryParse(suggestions[index]["lat"]);
                        long = double.tryParse(suggestions[index]["lon"]);
                        setState(() {
                          suggestions = [];
                        });
                        List<PropertyListing> searchResult = await PropertyListing.getSearchResult(lat!, long!);
                        
                        searchResultController.updateSearchResultUnfiltered(searchResult);
                        searchResultController.updateLocationLat(lat!);
                        searchResultController.updateLocationLong(long!);

                        developer.log("search result length: ${searchResult.length}");
                        List<PropertyListing> filteredResults = _filterSearchResults(searchResult);

                        developer.log("search filteredResults length: ${filteredResults.length}");
                        searchResultController.updateSearchResult(filteredResults);
                        searchResultController.updateLocation(_searchBarController.text);

                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
