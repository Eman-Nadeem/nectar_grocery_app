class UserModel {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final String zone;
  final String area;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.zone,
    required this.area,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'zone': zone,
      'area': area,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
