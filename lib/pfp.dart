import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_tasks_with_alert/register.dart';
import 'package:todo_tasks_with_alert/shared/styles/thems.dart';
import 'dart:math';
import 'package:provider/provider.dart';


import 'layout/todo_layout.dart';


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
    final userData = {'photoUrl': url, 'idUser': _user?.uid, 'fileName': randomFileName};
    await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(userData, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Utilisateur non connecté, gestion de l'erreur
    return;
  }
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
      appBar:  AppBar(
      backgroundColor: defaultLightColor,
      leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          }),
          title: Text("Profile"),
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