import 'package:flutter/material.dart';

class ModeratorCard extends StatelessWidget {
  final String title;
  final String count;

  const ModeratorCard({Key? key, required this.title, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
