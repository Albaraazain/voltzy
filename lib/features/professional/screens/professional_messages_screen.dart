import 'package:flutter/material.dart';

class ProfessionalMessagesScreen extends StatelessWidget {
  const ProfessionalMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Messages Screen - Coming Soon'),
      ),
    );
  }
}
