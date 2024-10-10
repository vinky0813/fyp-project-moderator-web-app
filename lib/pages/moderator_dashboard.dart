import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fyp_moderator_web_app/pages/moderator_chat.dart';
import 'package:fyp_moderator_web_app/pages/moderator_listing_registration.dart';
import 'package:fyp_moderator_web_app/widgets/moderator_drawer.dart';
import '../widgets/moderator_card.dart';
import '../widgets/moderator_app_bar.dart';
import 'moderator_reports.dart';

class ModeratorDashboard extends StatefulWidget {
  @override
  State<ModeratorDashboard> createState() => _ModeratorDashboardState();
}

class _ModeratorDashboardState extends State<ModeratorDashboard> {
  int pendingListingsCount = 0;
  int pendingReportsCount = 0;
  int unreadMessagesCount = 0;
  List<ChartData> newSignUpsPerDay = [];
  List<ChartData> reportsPerDay = [];
  late String userid;

  @override
  void initState() {
    super.initState();
    initializeDashboardData();
    setupForegroundMessageHandler();
  }

  void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.messageId}');
      if (message.notification != null) {
        // Show a notification or update the UI as needed
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'Notification'),
              content: Text(message.notification!.body ?? 'No content'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }


  Future<void> initializeDashboardData() async {
    final user = Supabase.instance.client.auth.currentUser;
    userid = user!.id;

    if (user == null) {
      print("User is not logged in.");
      return;
    }

    await FirebaseMessaging.instance.requestPermission();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM TOKEN: $fcmToken");
    if (fcmToken != null) {
      await _setFcmToken(fcmToken);
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        print("FCM TOKEN AFTER SIGNIN: $fcmToken");
        if (fcmToken != null) {
          await _setFcmToken(fcmToken);
        }
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification != null) {
        Get.snackbar("${notification.title}", "${notification.body}");
      }
    });

    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    final signUpsResponse = await Supabase.instance.client
        .from('profiles')
        .select('created_at')
        .gte('created_at', oneWeekAgo.toIso8601String())
        .order('created_at', ascending: true);

    final reportsResponse = await Supabase.instance.client
        .from('Reports')
        .select('created_at')
        .gte('created_at', oneWeekAgo.toIso8601String())
        .order('created_at', ascending: true);

    if (signUpsResponse != null) {
      List<ChartData> newSignUps = [];
      final List<dynamic> signUpsData = signUpsResponse;

      for (var user in signUpsData) {
        DateTime createdAt = DateTime.parse(user['created_at']).toLocal();
        newSignUps.add(ChartData(createdAt, 1));
      }

      newSignUpsPerDay = List.generate(7, (index) {
        DateTime date = DateTime.now().subtract(Duration(days: index)).toLocal();
        int count = newSignUps.where((item) =>
        item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day).fold(0, (prev, _) => prev + 1);

        print("date $date, count $count");
        return ChartData(date, count.toDouble());
      }).reversed.toList();

      setState(() {});
    } else {
      print('Error fetching data: sign-ups: ${signUpsResponse}');
    }

    if (reportsResponse != null) {
      List<ChartData> newReports = [];
      final List<dynamic> reportsData = reportsResponse;

      for (var report in reportsData) {
        DateTime createdAt = DateTime.parse(report['created_at']).toLocal();
        newReports.add(ChartData(createdAt, 1));
      }

      reportsPerDay = List.generate(7, (index) {
        DateTime date = DateTime.now().subtract(Duration(days: index)).toLocal();
        int count = newReports.where((item) =>
        item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day).fold(0, (prev, _) => prev + 1);

        print("date $date, count $count");
        return ChartData(date, count.toDouble());
      }).reversed.toList();

      setState(() {});
    } else {
      print('Error fetching data: reports: ${reportsResponse}');
    }

    final pendingListingsResponse = await Supabase.instance.client
        .from('Listing')
        .select('listing_id')
        .eq('isPublished', false);

    final pendingReportsResponse = await Supabase.instance.client
        .from('Reports')
        .select('report_id')
        .eq('status', 'pending');

    final pendingMessagesResponse = await Supabase.instance.client
        .from('Message_Read_Status')
        .select('id')
        .eq('user_id', user!.id)
        .eq('is_read', false);

    pendingListingsCount = pendingListingsResponse.length;
    pendingReportsCount = pendingReportsResponse.length;
    unreadMessagesCount = pendingMessagesResponse.length;

    setState(() {});
  }

  Future<void> _setFcmToken(String fcmToken) async {
    print("SETTING FCMTOKEN");
    await Supabase.instance.client
        .from('profiles')
        .upsert({
      "id": userid,
      "fcm_token": fcmToken,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModeratorAppBar(),
      drawer: ModeratorDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    ModeratorCard(
                      title: 'Pending Listing Registration',
                      count: '0',
                    ),
                    SizedBox(width: 80),
                    ModeratorCard(
                      title: 'Pending Reports Review',
                      count: '0',
                    ),
                    SizedBox(width: 80),
                    ModeratorCard(
                      title: 'Unread Chat Messages',
                      count: '0',
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 200,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {
                              Get.to(() => ModeratorListingRegistration());
                            },
                            child: Text(
                              "Registration",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {
                              Get.to(() => ModeratorReports());
                            },
                            child: Text(
                              "Reports",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {
                              Get.to(() => ModeratorChat());
                            },
                            child: Text(
                              "Chat",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            onPressed: () {},
                            child: Text(
                              "All Properties",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                    Expanded(
                      child: SizedBox(
                        height: 300,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Number of Logins",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: SfCartesianChart(
                                    primaryXAxis: DateTimeAxis(
                                      dateFormat: DateFormat('MM/dd'),
                                    ),
                                    series: <CartesianSeries>[
                                      LineSeries<ChartData, DateTime>(
                                        dataSource: newSignUpsPerDay,
                                        xValueMapper: (ChartData data, _) => data.date,
                                        yValueMapper: (ChartData data, _) => data.value,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 80,),
                    Expanded(
                      child: SizedBox(
                        height: 300,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Number of Reports",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: SfCartesianChart(
                                    primaryXAxis: DateTimeAxis(
                                      dateFormat: DateFormat('MM/dd'),
                                    ),
                                    series: <CartesianSeries>[
                                      LineSeries<ChartData, DateTime>(
                                        dataSource: reportsPerDay,
                                        xValueMapper: (ChartData data, _) => data.date,
                                        yValueMapper: (ChartData data, _) => data.value,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.date, this.value);

  final DateTime date;
  final double value;
}
