import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class ProfileData {
  String name;
  String email;
  String phone;
  String location;
  String? profileImagePath;
  bool notificationsEnabled;

  ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.profileImagePath,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'profileImagePath': profileImagePath,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      profileImagePath: json['profileImagePath'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }
}

class ProfileProvider with ChangeNotifier {
  ProfileData _profileData = ProfileData(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+91 98765 43210',
    location: 'Mumbai, India',
  );

  ProfileData get profileData => _profileData;

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile_data');

    if (profileJson != null) {
      final Map<String, dynamic> profileMap = json.decode(profileJson);
      _profileData = ProfileData.fromJson(profileMap);
      notifyListeners();
    }
  }

  Future<void> saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String profileJson = json.encode(_profileData.toJson());
    await prefs.setString('profile_data', profileJson);
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? profileImagePath,
    bool? notificationsEnabled,
  }) {
    _profileData = ProfileData(
      name: name ?? _profileData.name,
      email: email ?? _profileData.email,
      phone: phone ?? _profileData.phone,
      location: location ?? _profileData.location,
      profileImagePath: profileImagePath ?? _profileData.profileImagePath,
      notificationsEnabled:
          notificationsEnabled ?? _profileData.notificationsEnabled,
    );
    saveProfileData();
  }
}
