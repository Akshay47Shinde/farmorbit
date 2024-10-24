class UserModel {
  final String uid; // Unique identifier for the user
  final String name; // User's name
  final String email; // User's email
  final String profilePicture; // URL for the user's profile picture

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  // Method to convert a Map into a UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
    );
  }

  // Method to convert UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
    };
  }
}
