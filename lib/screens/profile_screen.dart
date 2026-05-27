import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign in coming in A7.'),
            ElevatedButton(
              onPressed: null, 
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),    
    );
  }
}