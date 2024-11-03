import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../AccessTokenController.dart';

final accessTokenController = Get.find<Accesstokencontroller>();
final accessToken = accessTokenController.token;

class User {
  String id;
  String username;
  String profilePic;
  String contactDetails;
  final String sex;
  final String nationality;
  bool isAccommodating;
  String? listing_id;

  User({
    required this.id,
    required this.username,
    required this.profilePic,
    required this.contactDetails,
    required this.sex,
    required this.nationality,
    required this.isAccommodating,
    this.listing_id
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["user_id"],
      username: json["username"] ?? "no username",
      profilePic: json["profile_pic"] ?? "https://via.placeholder.com/150",
      contactDetails: json["contact_no"],
      sex: json["sex"],
      nationality: json["nationality"],
      isAccommodating: json["isAccommodating"],
      listing_id: json["listing_id"],
    );
  }

  static Future<User> getUserById(String user_id) async {
    developer.log("im here");
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/get-renter-with-id/$user_id");
    final response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      developer.log("jsonresponse: $jsonResponse");

      if (jsonResponse["renterData"].isNotEmpty) {
        return User.fromJson(jsonResponse["renterData"]);
      } else {
        throw Exception("No user found");
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<bool> checkRenterId(String renter_id) async {
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/check-renter/$renter_id");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        developer.log("Successfully, renter is ok: ${response.body}");
        return true;
      } else {
        developer.log("Failed , renter is not ok: ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error renter not found: $error");
      return false;
    }
  }
  static Future<List<User>> getTenants(String property_id) async {

    developer.log("start of getTenant");
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/get-tenants/$property_id");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $accessToken"},
      );

      developer.log("Response status code: ${response.statusCode}");
      developer.log("Raw response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        developer.log("get tenants: $jsonResponse");

        List<Map<String, dynamic>> renterData = List<Map<String, dynamic>>.from(jsonResponse["data"]);

        List<User> tenants = [];
        for (Map<String, dynamic> renter in renterData) {
          String renterId = renter['renter_id'];
          try {
            User user = await getUserById(renterId);
            tenants.add(user);
          } catch (e) {
            developer.log("Error fetching user with ID $renterId: $e");
          }
        }

        developer.log("Successfully fetched tenants: ${tenants.length} tenants found.");
        return tenants;

      } else {
        developer.log("Failed to fetch tenants: ${response.body}");
        return [];
      }
    } catch (error) {
      developer.log("Error fetching tenants: $error");
      return [];
    }
  }

  static Future<void> updateUser(String user_id, String username, String contactNo, String profilePic) async {
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/update-renter-information/$user_id");

    developer.log("${user_id}, ${username}, ${contactNo}, ${profilePic}");

    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $accessToken"},
        body: jsonEncode({
          "username": username,
          "contact_no": contactNo,
          "profile_pic": profilePic,
        })
    );

    if (response.statusCode == 200) {
      developer.log("Successfully updated renter: ${response.statusCode}.");
      developer.log("Response Body: ${response.body}");
    } else {
      throw Exception("Cannot find renter");
    }
  }
}