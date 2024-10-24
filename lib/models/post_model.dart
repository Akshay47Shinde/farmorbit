import 'package:cloud_firestore/cloud_firestore.dart'; // Import the necessary package

class Post {
  String postId;
  String content;
  String userId;
  List<String> likes;
  String? imageUrl; // Optional image URL
  DateTime? timestamp; // Optional timestamp

  Post({
    required this.postId,
    required this.content,
    required this.userId,
    required this.likes,
    this.imageUrl,
    this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      postId: data['postId'] ?? '', // Default value if null
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
      likes: List<String>.from(data['likes'] ?? []), // Ensure it's a List
      imageUrl: data['imageUrl'], // Keep as nullable
      timestamp: (data['timestamp'] as Timestamp?)
          ?.toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'content': content,
      'userId': userId,
      'likes': likes,
      'imageUrl': imageUrl,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(
              timestamp!) // Convert DateTime to Firestore Timestamp
          : null, // Store null if timestamp is not provided
    };
  }
}
