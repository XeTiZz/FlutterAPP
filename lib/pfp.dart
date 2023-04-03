import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  File? _image;

  String generateRandomString(int length) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  final random = Random();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      return;
    }
    final randomFileName = generateRandomString(20) + '.jpg';
    final ref = FirebaseStorage.instance.ref().child(randomFileName);
    await ref.putFile(_image!);
    final url = await ref.getDownloadURL();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Utilisateur non connecté, gestion de l'erreur
      return;
    }
    await user.updatePhotoURL(url);

    final User? _user = FirebaseAuth.instance.currentUser;
    // Enregistrez l'URL dans Firestore si nécessaire
    final userData = {'photoUrl': url, 'idUser': _user?.uid};
    await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(userData, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) ...[
              Image.file(_image!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Enregistrer'),
              ),
            ] else ...[
              const Icon(Icons.person, size: 128),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Choisir une photo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}