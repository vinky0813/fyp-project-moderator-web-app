import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../AccessTokenController.dart';

final accessTokenController = Get.find<Accesstokencontroller>();
final accessToken = accessTokenController.token;

class Owner {
  String id;
  String username;
  String contact_no;
  String profile_pic;

  Owner({
    required this.id,
    required this.username,
    required this.contact_no,
    required this.profile_pic,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json["user_id"],
      username: json["username"] ?? "no username",
      contact_no: json["contact_no"],
      profile_pic: json["profile_pic"] ?? "https://via.placeholder.com/150",
    );
  }

  static Future<Owner> getOwnerWithId(String ownerId) async {
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/get-owner-with-id/$ownerId");

    final response = await http.get(
      url, headers: {"Accept": "application/json", "Authorization": "Bearer $accessToken"}
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Owner.fromJson(data);
    } else {
      throw Exception("Cannot find owner");
    }
  }

  static Future<void> updateOwner(String user_id, String username, String contactNo, String profilePic) async {
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/update-owner-information/$user_id");

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
      developer.log("Successfully updated owner: ${response.statusCode}.");
    } else {
      throw Exception("Cannot find owner");
    }
  }
}

