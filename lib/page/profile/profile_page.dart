import 'package:flutter/material.dart';
import 'package:habitualize/page/profile/edit_profile_page.dart';
import 'package:provider/provider.dart';
import 'package:habitualize/providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileData = context.watch<ProfileProvider>().profileData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: profileData.profileImagePath != null
                  ? FileImage(File(profileData.profileImagePath!))
                  : const NetworkImage('https://via.placeholder.com/150')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              profileData.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Email
            Text(
              profileData.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: 24),
            // Profile Sections
            _buildProfileSection(
              title: 'Personal Information',
              children: [
                _buildProfileTile(
                  icon: Icons.phone,
                  title: 'Phone Number',
                  subtitle: profileData.phone,
                ),
                _buildProfileTile(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: profileData.location,
                ),
                _buildProfileTile(
                  icon: Icons.calendar_today,
                  title: 'Date of Birth',
                  subtitle: profileData.dob,
                ),
              ],
            ),
            _buildProfileSection(
              title: 'App Settings',
              children: [
                _buildProfileTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  trailing: Switch(
                    value: profileData.notificationsEnabled,
                    onChanged: (value) {
                      context.read<ProfileProvider>().updateProfile(
                            notificationsEnabled: value,
                          );
                    },
                  ),
                ),
                _buildProfileTile(
                  icon: Icons.lock,
                  title: 'Privacy',
                  onTap: () {
                    // TODO: Navigate to privacy settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
