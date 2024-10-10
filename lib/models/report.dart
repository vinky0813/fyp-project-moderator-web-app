

import 'package:fyp_moderator_web_app/models/user.dart';

class Report {
  final String report_id;
  final User reported_by;
  final String reason;
  final String details;
  final String status;
  final String listing_id;

  Report({
    required this.report_id,
    required this.reported_by,
    required this.reason,
    required this.details,
    required this.status,
    required this.listing_id,
  });

  static Future<Report> fromJson(Map<String, dynamic> json) async {
    String userId = json["reported_by"];

    User reportedBy = await User.getUserById(userId);

    return Report(
      report_id: json["report_id"],
      reported_by: reportedBy,
      reason: json["reason"],
      details: json["details"],
      status: json["status"],
      listing_id: json["listing_id"],
    );
  }
}