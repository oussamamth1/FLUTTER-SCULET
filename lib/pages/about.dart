import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final String? id;
  const AboutPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Page')),
      body: Center(
        child: Text('Details ID: $id'),
      ),
    );
  }
}
