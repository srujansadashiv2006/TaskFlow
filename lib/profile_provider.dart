import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String? _imagePath;
  String? get imagePath => _imagePath;

  final ImagePicker _picker = ImagePicker();

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString('profileImagePath');
    notifyListeners();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imagePath = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('profileImagePath', _imagePath!);
      notifyListeners();
    }
  }

  Widget getProfileAvatar() {
    if (_imagePath != null) {
      return CircleAvatar(
        backgroundImage: FileImage(File(_imagePath!)),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person_outline, color: Colors.black),
      );
    }
  }
}