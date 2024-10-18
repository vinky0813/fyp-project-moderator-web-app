import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_moderator_web_app/pages/moderator_dashboard.dart';

import 'package:fyp_moderator_web_app/widgets/moderator_app_bar.dart';

class LoginModerators extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModeratorAppBar(),
      body: Center(
        child: Container(
          width: 1480,
          height: 900,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 250,
                top: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Email:",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    // Email TextField
                    Container(
                      width: 460,
                      height: 47,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFDFDFDF)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextField(
                        controller: emailController,
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Color(0xFF828282), fontSize: 20),
                          counterText: "",
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password Label
                    Text(
                      "Enter Password:",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    // Password TextField
                    Container(
                      width: 460,
                      height: 47,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFDFDFDF)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Color(0xFF828282), fontSize: 20),
                          counterText: "",
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Login Button
                    _buildLoginButton(context),
                  ],
                ),
              ),
              Positioned(
                right: 130,
                top: 130,
                child: Container(
                  width: 400,
                  height: 400,
                  child: Image.asset(
                    "lib/src/INTI_Logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final response = await Supabase.instance.client.auth.signInWithPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          final userId = response.user?.id;

          if (userId != null) {
            final profileResponse = await Supabase.instance.client
                .from('profiles')
                .select('user_type')
                .eq('id', userId)
                .single();

            final userType = profileResponse["user_type"];
            print("usertype: $userType");

            if (userType == 'moderator') {
              Get.offAll(ModeratorDashboard());
            } else {
              _showErrorDialog(context, 'Access denied! Only moderators can log in.');
            }
          } else {
            _showErrorDialog(context, 'Invalid login credentials.');
          }
        } catch (error) {
          print('Login error: $error');
          _showErrorDialog(context, 'Login failed. Please try again.');
        }
      },
      child: Container(
        width: 86,
        height: 47,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Login',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
