import 'dart:convert';

import 'package:fyp_moderator_web_app/models/property.dart';
import 'package:fyp_moderator_web_app/models/review.dart';
import 'package:fyp_moderator_web_app/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_project;

import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import 'boolean_variable.dart';

class PropertyListing {
  String listing_id;
  String listing_title;
  double rating;
  List<String> image_url;
  double price;
  String room_type;
  double deposit;
  String description;
  String sex_preference;
  String nationality_preference;
  List<BooleanVariable> amenities;
  String property_id;
  List<Review> reviews;
  User? tenant;
  bool isPublished;
  bool isVerified;
  int view_count;

  PropertyListing({
    required this.listing_id,
    required this.listing_title,
    required this.rating,
    required this.image_url,
    required this.price,
    required this.room_type,
    required this.deposit,
    required this.description,
    required this.sex_preference,
    required this.nationality_preference,
    required this.amenities,
    required this.property_id,
    required this.reviews,
    required this.tenant,
    required this.isPublished,
    required this.isVerified,
    required this.view_count,
  });

  static Future<List<PropertyListing>> getPropertyListing(String property_id) async {

    List<PropertyListing> propertyListings = [];

    print("property id: ${property_id}");

    final url = Uri.parse("http://localhost:2000/api/get-all-listing/$property_id");
    try {
      final response = await http.get(url);
      print(response.statusCode.toString());

      if (response.statusCode == 200) {
        final List<dynamic> listings = jsonDecode(response.body)["data"];
        print("Listings Data: ${listings.runtimeType}");

        print(listings.toString());
        print(listings.toString());

        final List<Future<PropertyListing>> futures = listings
            .map((listingJson) => _processListing(listingJson, property_id))
            .toList();

        propertyListings = await Future.wait(futures);

        return propertyListings;

      } else {
        print("Failed to load listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching listings: $e");
      return [];
    }
  }

  static Future<PropertyListing> _processListing(dynamic listingJson, String property_id) async {
    String listing_Id = listingJson["listing_id"];

    List<String> images = await _getListingImages(listing_Id);

    print(images.toString());

    List<BooleanVariable> amenities = await _getAmenities(listing_Id);

    print("amenities: ${amenities.toString()}");
    print("amenities: ${amenities.length}");

    String room_type = _determineRoomType(amenities);

    print("room type: $room_type");

    List<Review> reviews = await _getReviews(listing_Id);

    print("reviews: ${reviews.toString()}");

    User? tenant;

    if (listingJson["tenant"] != null) {
      try {
        tenant = await User.getUserById(listingJson["tenant"]);
      } catch (e) {
        print("Error fetching tenant: $e");
        tenant = null;
      }
    }

    print("tenant: ${tenant.toString()}");

    PropertyListing propertyListingItem = PropertyListing(
      listing_id: listing_Id,
      listing_title: listingJson["listing_title"] ?? "WRONG TITLE",
      rating: listingJson["rating"].toDouble() ?? 0.0.toDouble(),
      price: listingJson["price"].toDouble() ?? 0.0.toDouble(),
      deposit: listingJson["deposit"].toDouble() ?? 0.0.toDouble(),
      description: listingJson["description"] ?? "WRONG DESCRIPTION",
      room_type: room_type,
      nationality_preference: listingJson["nationality_preference"] ?? "WRONG PREFERENCE",
      sex_preference: listingJson["sex_preference"] ?? "WRONG PREFERENCE",
      image_url: images,
      amenities: amenities,
      property_id: property_id,
      reviews: reviews,
      isPublished: listingJson["isPublished"],
      isVerified: listingJson["isVerified"],
      tenant: tenant, view_count: listingJson["view_count"],
    );

    return propertyListingItem;
  }

  static Future<List<Review>> _getReviews(String listing_Id) async {
    final reviewsResponse = await http
        .get(Uri.parse("http://localhost:2000/api/get-all-reviews/$listing_Id"));

    if (reviewsResponse.statusCode == 200) {
      final reviewsJsonResponse = jsonDecode(reviewsResponse.body);

      return List<Review>.from(
          reviewsJsonResponse["data"].map((item) => Review.fromJson(item)));
    } else if (reviewsResponse.statusCode == 404) {
      print("no reviews for this listing");
      return [];
    } else {
      return [];
    }
  }

  static Future<List<String>> _getListingImages(String listing_Id) async {
    final imagesResponse = await http.get(
        Uri.parse("http://localhost:2000/api/get-listing-images/$listing_Id"));

    if (imagesResponse.statusCode == 200) {
      final imagesjsonResponse = jsonDecode(imagesResponse.body);

      print("Images JSON Response: $imagesjsonResponse");

      return imagesjsonResponse.map<String>((item) => item["image_url"] as String).toList();
    } else {
      return [];
    }
  }

  static Future<List<BooleanVariable>> _getAmenities(String listing_Id) async {
    final url =
        Uri.parse("http://localhost:2000/api/get-all-amenities/$listing_Id");
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final amenitiesJson = jsonDecode(response.body);

      if (amenitiesJson["data"] is List) {
        final List<dynamic> amenitiesList = amenitiesJson["data"];

        final List<Map<String, dynamic>> cleanedAmenitiesList = amenitiesList.map((item) {
          if (item is Map) {
            final Map<String, dynamic> cleanedItem = Map<String, dynamic>.from(item);
            cleanedItem.remove("listing_id");
            return cleanedItem;
          }
          return <String, dynamic>{};
        }).toList();

        print("CLEANED: ${cleanedAmenitiesList.toString()}");

        List<BooleanVariable> amenities = [];

        for (var item in cleanedAmenitiesList) {
          for (var pair in item.entries) {
            amenities.add(BooleanVariable(name: pair.key, value: pair.value));
          }
        }
        return amenities;
      }
    }
    return [];
  }

  static String _determineRoomType(List<BooleanVariable> amenities) {
    String room_type = "";
    if (amenities[0].value) {
      room_type = "master";
    } else if (amenities[1].value) {
      room_type = "single";
    } else if (amenities[2].value) {
      room_type = "shared";
    } else if (amenities[3].value) {
      room_type = "suite";
    }
    return room_type;
  }

  static Future<void> deleteImages(List<String> imageUrls) async {

    for (String imageUrl in imageUrls) {
      final response = await supabase_project.Supabase.instance.client.storage.from("property-images").remove([imageUrl]);

      if (response.isEmpty) {
        print("Successfully deleted images: ${imageUrl}");
      } else {
        print("Some images may not have been deleted: ${response.map((file) => file.name).join(', ')}");
      }
    }
  }

  static Future<void> deleteListing(String listing_id) async {

    final image_delete_url = Uri.parse("http://localhost:2000/api/delete-listing-images/$listing_id");

    try {
      final response = await http.delete(image_delete_url);

      print(response.body);
      if (response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);
        final imagesData = responseBody["data"] as List<dynamic>;
        final imagesToDeleteFromStorage = imagesData.map<String>((item) => item["image_url"] as String).toList();

        print("Images to delete: ${imagesToDeleteFromStorage.toString()}");

        await deleteImages(imagesToDeleteFromStorage);

      } else {
        final responseBody = jsonDecode(response.body);
        print("Error deleting images: ${responseBody}");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }

    final amenities_url = Uri.parse("http://localhost:2000/api/delete-listing-amenities/$listing_id");

    try {
      final response = await http.delete(amenities_url);

      if (response.statusCode == 200) {
        print("amenities deleted successfully");
      } else {
        final responseBody = jsonDecode(response.body);
        print('Error deleting listing: ${responseBody['message']}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }

    final listing_url = Uri.parse("http://localhost:2000/api/delete-listing/$listing_id");

    try {
      final response = await http.delete(listing_url);

      if (response.statusCode == 200) {
        print("Listing deleted successfully");
      } else {
        final responseBody = jsonDecode(response.body);
        print("'Error deleting listing: ${responseBody}'");
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  static Future<PropertyListing?> getCurrentProperty(String? listing_id) async {

    final url = Uri.parse("http://localhost:2000/api/get-listing-with-id/$listing_id");
    try {
      final response = await http.get(url);
      print(response.statusCode.toString());

      if (response.statusCode == 200) {
        final listings = jsonDecode(response.body)["data"];

        print(listings.toString());

        PropertyListing propertyListing = await _processListing(listings, listings["property_id"]);

        return propertyListing;

      } else {
        print("Failed to load current listing: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching current listing: $e");
      return null;
    }
  }

  static Future<List<PropertyListing>> getSearchResult(double lat, double long) async {
    List<PropertyListing> searchResultListing = [];

    final propertyList = await Property.getSearchedProperty(lat, long);

    for (Property property in propertyList) {
      List<PropertyListing> listings = await getPropertyListing(property.property_id);

      searchResultListing.addAll(listings);
    }
    List<PropertyListing> publishedListings = searchResultListing.where((listing) => listing.isPublished).toList();

    return publishedListings;
  }

  static Future<List<PropertyListing>> fetchUnpublishedListings() async {
    List<PropertyListing> unpublishedListings = [];

    final url = Uri.parse("http://localhost:2000/api/get-all-unpublished-listings");
    try {
      final response = await http.get(url);
      print("Unpublished Listings Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> listings = jsonDecode(response.body);
        print("Unpublished Listings Data: ${listings.toString()}");

        final List<Future<PropertyListing>> futures = listings
            .map((listingJson) => _processListing(listingJson, listingJson["property_id"]))
            .toList();

        unpublishedListings = await Future.wait(futures);
      } else {
        print("Failed to load unpublished listings: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching unpublished listings: $e");
    }

    return unpublishedListings;
  }

}
