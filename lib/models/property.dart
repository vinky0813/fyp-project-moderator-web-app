import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'owner.dart';


class Property {
  String property_id;
  String property_title;
  Owner owner;
  String address;
  String imageUrl;
  double lat;
  double long;
  String group_id;

  Property({
    required this.property_id,
    required this.property_title,
    required this.owner,
    required this.address,
    required this.imageUrl,
    required this.lat,
    required this.long,
    required this.group_id,
  });

  factory Property.fromJson(Map<String, dynamic> json, Owner owner) {

    List<dynamic> coordinates = json["location"]["coordinates"];

    return Property(
      property_id: json["property_id"],
      property_title: json["property_title"],
      owner: owner,
      address: json["address"],
      imageUrl: json["property_image"],
      lat: coordinates[1].toDouble(),
      long: coordinates[0].toDouble(),
      group_id: json["group_id"],
    );
  }

  static Future<List<Property>> getOwnerProperties(Owner owner) async {
    final url = Uri.parse("http://localhost:2000/api/get-all-owner-properties")
        .replace(queryParameters: {"owner_id": owner.id});
    final response = await http.get(
        url, headers: {"Accept": "application/json"});

    developer.log(response.body);

    developer.log(owner.profile_pic);

    developer.log("what happens here: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      developer.log("data: ${data}");
      final value = data.map((json) {
        return Property.fromJson(json, owner);
      }).toList();
      developer.log("value: ${value}");

      return value;
    } else {
      throw Exception("Failed to load properties");
    }
  }

  static Future<List<Property>> getSearchedProperty(double lat, double long) async {

    final url = Uri.parse("http://localhost:2000/api/search-properties-by-location")
        .replace(queryParameters: {
      "lat": lat.toString(),
      "long": long.toString(),
      "radius" : "100000",
    });

    final response = await http.get(url, headers: {"Accept": "application/json"});

    developer.log("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      developer.log("Data: $data");

      final List<Property> properties = await Future.wait(data.map((json) async {
        String propertyId = json["property_id"];
        return await getPropertyWithId(propertyId);
      }));

      developer.log("Properties: $properties");
      return properties;
    } else {
      throw Exception("Failed to load properties");
    }
  }

  static Future<Property> getPropertyWithId(String property_id) async {

    final url = Uri.parse("http://localhost:2000/api/get-property-with-id/$property_id");

    final response = await http.get(url, headers: {"Accept": "application/json"});

    developer.log("status code: ${response.statusCode}");

    developer.log("response: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body)["property"];

      developer.log("getpropertywithid: $data");

      final Owner owner = await Owner.getOwnerWithId(data["owner_id"]);

      return Property.fromJson(data, owner);

    } else {
      throw Exception("Failed to load properties");
    }
  }
}

