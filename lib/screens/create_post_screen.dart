import 'dart:io'; // For handling files
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To pick images from gallery
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _imageFile; // To store the selected image
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String imageId = Uuid().v4();
      Reference storageRef = _storage.ref().child('post_images/$imageId');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty && _imageFile == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }

    String postId = Uuid().v4(); // Generate a unique post ID
    String? imageUrl;

    if (_imageFile != null) {
      imageUrl =
          await _uploadImage(_imageFile!); // Upload image to Firebase Storage
    }

    Post newPost = Post(
      postId: postId,
      userId: user.uid,
      content: _contentController.text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      likes: [], // Initialize with an empty list of likes
    );

    await _firestore.collection('posts').doc(postId).set(newPost.toMap());

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context); // Go back after posting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isUploading
                ? null
                : _submitPost, // Disable button while uploading
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(hintText: 'Write something...'),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? TextButton.icon(
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Add Image'),
                    onPressed: _pickImage,
                  )
                : Image.file(_imageFile!,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
            if (_isUploading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
