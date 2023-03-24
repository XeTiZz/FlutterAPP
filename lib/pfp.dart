// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class MyHomePage extends StatefulWidget {
//   MyHomePage({super.key});


//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   File _image = new File('assets/default profile.png');

//   Future getImage() async {
//     final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future uploadFile() async {
//     final storage = FirebaseStorage.instance;
//     final ref = storage.ref().child('images/${_image.path}');
//     final task = ref.putFile(_image);
//     await task.whenComplete(() => print('File uploaded to Firebase Storage'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image != null
//                 ? Image.file(
//                     _image,
//                     height: 150,
//                   )
//                 : Container(),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: getImage,
//               child: Text("Choose Image"),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _image != null ? uploadFile : null,
//               child: Text("Upload Image"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }