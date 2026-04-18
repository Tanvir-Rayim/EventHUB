class UserProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;

  UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory UserProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfileModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
    };
  }
}