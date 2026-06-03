import 'package:flutter/material.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';
import 'package:provider/provider.dart';

// I got some help from here: 
// https://hemant-aws-devops.medium.com/day-22-creating-custom-dialogs-in-flutter-a-step-by-step-guide-for-our-noted-app-beb33203ce57

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthModel>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as ${user?.displayName}'),
            ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Reset Account'),
                      content: const Text('Are you sure you wish to reset your account?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await context.read<PortfolioModel>().resetAccount();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                          child: const Text('Proceed'),
                        ),
                      ],
                    );
                  },  
                );
              },
              child: const Text('Reset Account'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthModel>().signOut(); 
              },  
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),    
    );
  }
}