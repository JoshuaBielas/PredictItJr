// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';
import 'package:provider/provider.dart';
import 'package:predictit_jr/providers/theme_model.dart';

// I got some help from here: 
// https://hemant-aws-devops.medium.com/day-22-creating-custom-dialogs-in-flutter-a-step-by-step-guide-for-our-noted-app-beb33203ce57
// I also got help from AI

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
            const SizedBox(height: 24),
            const Text('App theme', style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: context.watch<ThemeModel>().themeMode,
              onChanged: (mode) {
                if (mode != null) context.read<ThemeModel>().setThemeMode(mode);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: context.watch<ThemeModel>().themeMode,
              onChanged: (mode) {
                if (mode != null) context.read<ThemeModel>().setThemeMode(mode);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: context.watch<ThemeModel>().themeMode,
              onChanged: (mode) {
                if (mode != null) context.read<ThemeModel>().setThemeMode(mode);
              },
            ),
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