class User {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? profileImage;
  final String userType; // 'student' or 'regular'
  final String? university;
  final String? city;

  // Avatar configuration
  final String? gender; // 'male', 'female', 'neutral'
  final String? avatarSkinTone; // 'light', 'medium', 'dark', etc.
  final String? avatarHairStyle; // 'short', 'long', 'bald'
  final String? avatarFacialHair; // 'none', 'beard', 'mustache'

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.profileImage,
    required this.userType,
    this.university,
    this.city,
    this.gender,
    this.avatarSkinTone,
    this.avatarHairStyle,
    this.avatarFacialHair,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? profileImage,
    String? userType,
    String? university,
    String? city,
    String? gender,
    String? avatarSkinTone,
    String? avatarHairStyle,
    String? avatarFacialHair,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      university: university ?? this.university,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      avatarSkinTone: avatarSkinTone ?? this.avatarSkinTone,
      avatarHairStyle: avatarHairStyle ?? this.avatarHairStyle,
      avatarFacialHair: avatarFacialHair ?? this.avatarFacialHair,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      profileImage: json['profileImage'] as String?,
      userType: json['userType'] as String,
      university: json['university'] as String?,
      city: json['city'] as String?,
      gender: json['gender'] as String?,
      avatarSkinTone: json['avatarSkinTone'] as String?,
      avatarHairStyle: json['avatarHairStyle'] as String?,
      avatarFacialHair: json['avatarFacialHair'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'profileImage': profileImage,
      'userType': userType,
      'university': university,
      'city': city,
      'gender': gender,
      'avatarSkinTone': avatarSkinTone,
      'avatarHairStyle': avatarHairStyle,
      'avatarFacialHair': avatarFacialHair,
    };
  }
}
