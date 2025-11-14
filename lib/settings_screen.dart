import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/theme_provider.dart';
import 'package:task_manager/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).iconTheme.color,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: profileProvider.getProfileAvatar(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Change profile picture', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              onTap: () {
                context.read<ProfileProvider>().pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
              ),
            ),
            const Divider(height: 30, thickness: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}