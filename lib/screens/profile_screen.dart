import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/login_screen.dart'; // Import your LoginScreen for logout functionality

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _profilePictureUrl = ''; // Variable to hold profile picture URL
  String? _previewImageUrl; // Variable to hold the preview image URL
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'] ?? '';
          _profilePictureUrl =
              userDoc['profilePicture'] ?? ''; // Get profile picture URL
          _nameController.text = _name;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _name,
          'profilePicture': _profilePictureUrl, // Update profile picture URL
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _previewImageUrl = image.path; // Update preview image URL
        });

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profilePictures/${_auth.currentUser!.uid}.jpg');

        // Upload the file to Firebase Storage
        await ref.putFile(File(image.path));

        // Get the download URL
        String downloadUrl = await ref.getDownloadURL();

        setState(() {
          _profilePictureUrl = downloadUrl; // Update the profile picture URL
        });

        // Update the Firestore with the new profile picture URL
        await _updateProfile();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen()), // Navigate to Login screen
              );
            },
          ),
        ],
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    // Display current profile picture
                    GestureDetector(
                      onTap:
                          _pickImage, // Allow user to tap and change the image
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _previewImageUrl != null
                            ? FileImage(File(
                                _previewImageUrl!)) // Show preview image if available
                            : _profilePictureUrl.isNotEmpty
                                ? NetworkImage(
                                    _profilePictureUrl) // Load image from URL
                                : AssetImage('assets/default_profile.png')
                                    as ImageProvider, // Default image if no URL
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        setState(() {
                          _name = value; // Update _name when the text changes
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _updateProfile();
                        _loadUserData(); // Refresh user data
                      },
                      child: Text('Update Profile'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your Posts:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts')
                            .where('userId', isEqualTo: user.uid)
                            .snapshots(),
                        builder: (context, postsSnapshot) {
                          if (postsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (postsSnapshot.hasError ||
                              !postsSnapshot.hasData) {
                            return Center(child: Text('Error loading posts'));
                          }

                          var posts = postsSnapshot.data!.docs;

                          if (posts.isEmpty) {
                            return Center(child: Text('No posts yet!'));
                          }

                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              var postData =
                                  posts[index].data() as Map<String, dynamic>;
                              String postContent =
                                  postData['content'] ?? 'No Content';
                              String? imageUrl =
                                  postData['imageUrl']; // Retrieve image URL

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(postContent),
                                      if (imageUrl != null &&
                                          imageUrl
                                              .isNotEmpty) // Check if imageUrl is not null
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            height:
                                                200, // You can adjust the height
                                            width: double.infinity,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(child: Text('User not logged in')),
    );
  }
}
