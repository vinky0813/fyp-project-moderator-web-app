import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../AccessTokenController.dart';

class Review {
  final String user_id;
  final String listing_id;
  final String comment;
  final double rating;

  Review({
    required this.user_id,
    required this.listing_id,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user_id: json["user_id"],
      listing_id: json["listing_id"],
      comment: json["comment"],
      rating: (json["rating"] as num).toDouble(),
    );
  }

  static Future<void> uploadReview(Review review) async {
    final accessTokenController = Get.find<Accesstokencontroller>();
    final accessToken = accessTokenController.token;

    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/upload-review");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $accessToken"},
        body: jsonEncode({
          "rating": review.rating,
          "comment": review.comment,
          "listing_id": review.listing_id,
          "user_id": review.user_id,
        }),
      );

      if (response.statusCode == 200) {
        developer.log('Review uploaded successfully');
      } else {
        developer.log('Failed to upload review: ${response.body}');
        throw Exception('Failed to upload review');
      }
    } catch (error) {
      developer.log('Error uploading review: $error');
      throw error;
    }
  }

  static Future<bool> checkUserReview(String listing_id, String user_id) async {
    final accessTokenController = Get.find<Accesstokencontroller>();
    final accessToken = accessTokenController.token;

    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/check-user-review/$listing_id/$user_id");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        developer.log('User has already reviewed this listing');
        return true;
      } else if (response.statusCode == 404) {
        developer.log('User has not reviewed this listing');
        return false;
      } else {
        developer.log('Error checking user review: ${response.body}');
        throw Exception('Failed to check review');
      }
    } catch (error) {
      developer.log('Error fetching review: $error');
      throw error;
    }
  }
}
