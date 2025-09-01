import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ZenifyTrip Guide',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'ZenifyTrip Guide helps you explore destinations, plan your trips, and discover new experiences. Our mission is to make travel easy and enjoyable for everyone.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}