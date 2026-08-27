class UserModel {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final String zone;
  final String area;
  final bool isAdmin;
  final String role;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.zone,
    required this.area,
    this.isAdmin = false,
    this.role = 'user',
  });

  /// Convert Firestore document data into UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      zone: map['zone'] ?? '',
      area: map['area'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      role: map['role'] ?? 'user',
    );
  }

  /// Convert UserModel object into Map JSON for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'zone': zone,
      'area': area,
      'isAdmin': isAdmin,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
