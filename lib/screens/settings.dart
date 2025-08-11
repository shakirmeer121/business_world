import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  bool _isUploading = false;

  String displayName = "Loading...";
  String email = "";
  String photoUrl = "https://via.placeholder.com/150";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    // Get email & photo from Auth
    setState(() {
      email = user!.email ?? "No email";
      photoUrl = user!.photoURL ?? "https://via.placeholder.com/150";
    });

    try {
      // Fetch 'name' from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          displayName = doc.data()?['name'] ?? "No name set";
        });
      } else {
        displayName = "No name set";
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null || user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user!.uid}.jpg');

      await storageRef.putFile(_imageFile!);
      final newPhotoUrl = await storageRef.getDownloadURL();

      // Update Firebase Auth profile
      await user!.updatePhotoURL(newPhotoUrl);
      await user!.reload();

      // Update Firestore user document (merge to avoid overwrite)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'photoUrl': newPhotoUrl}, SetOptions(merge: true));

      setState(() {
        photoUrl = newPhotoUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile picture updated!')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example static values
    final int forbesRank = 42;
    final double taxesPaid = 1500.75;
    final double totalEarnings = 10000.50;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(photoUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                displayName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: const TextStyle(color: Colors.grey),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(),
                ),
              const Divider(height: 30),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.leaderboard),
          title: const Text('Forbes List Ranking'),
          trailing: Text('#$forbesRank'),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Total Taxes Paid'),
          trailing: Text('\$${taxesPaid.toStringAsFixed(2)}'),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Total Earnings'),
          trailing: Text('\$${totalEarnings.toStringAsFixed(2)}'),
        ),
      ],
    );
  }
}
