import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase import

class ProfileData {
  String name;
  String email;
  String phone;
  String location;
  String? profileImagePath;
  bool notificationsEnabled;
  String dob;

  ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.profileImagePath,
    this.notificationsEnabled = true,
    this.dob = '',
  });

  /// ✅ Convert profile data to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'profileImagePath': profileImagePath,
      'notificationsEnabled': notificationsEnabled,
      'dob': dob,
    };
  }

  /// ✅ Create a ProfileData object from saved JSON
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      profileImagePath: json['profileImagePath'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dob: json['dob'] ?? '',
    );
  }
}

class ProfileProvider with ChangeNotifier {
  /// ✅ Default profile data (used until real data is loaded)
  ProfileData _profileData = ProfileData(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+91 98765 43210',
    location: 'Mumbai, India',
    dob: '1990-01-01',
  );

  ProfileData get profileData => _profileData;

  /// ✅ Load profile data from SharedPreferences
  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile_data');

    if (profileJson != null) {
      final Map<String, dynamic> profileMap = json.decode(profileJson);
      _profileData = ProfileData.fromJson(profileMap);
      notifyListeners();
    }
  }

  /// ✅ Save profile data to SharedPreferences
  Future<void> saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String profileJson = json.encode(_profileData.toJson());
    await prefs.setString('profile_data', profileJson);
    notifyListeners();
  }

  /// ✅ Update profile fields and save
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? profileImagePath,
    bool? notificationsEnabled,
    String? dob,
  }) {
    _profileData = ProfileData(
      name: name ?? _profileData.name,
      email: email ?? _profileData.email,
      phone: phone ?? _profileData.phone,
      location: location ?? _profileData.location,
      profileImagePath: profileImagePath ?? _profileData.profileImagePath,
      notificationsEnabled:
          notificationsEnabled ?? _profileData.notificationsEnabled,
      dob: dob ?? _profileData.dob,
    );
    saveProfileData(); // ✅ Auto-save after update
  }

  /// ✅ Load Firebase user details into profile (e.g. after login/signup)
  Future<void> loadUserFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      updateProfile(
        name: user.displayName ?? _profileData.name,
        email: user.email ?? _profileData.email,
      );
    }
  }
}
