// user_model.dart
class UserModel {
  String id;
  String name;
  String email;
  int level;
  String? photoUrl; // <-- Added field for profile picture

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      level: map['level'] ?? 0,
      photoUrl: map['photoUrl'],
    );
  }
}
