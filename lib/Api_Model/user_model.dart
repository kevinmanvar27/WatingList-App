class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? createdAt;
  final bool hasPin;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.createdAt,
    required this.hasPin,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
      createdAt: json['created_at'] as String?,
      hasPin: json['has_pin'] as bool,
      isAdmin: json['is_admin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'created_at': createdAt,
      'has_pin': hasPin,
      'is_admin': isAdmin,
    };
  }
}