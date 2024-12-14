import 'dart:convert';

class User {
  String role;
  dynamic userProfile;

  User({
    required this.role,
    required this.userProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var name = json['user_profile']['name'] ?? '';
    var email = json['user_profile']['email'] ?? '';
    var noTelp = json['user_profile']['no_telp'] ?? '';
    var profilePicture = json['user_profile']['profile_picture'] ?? '';
    var profilePictureId = json['user_profile']['profile_picture_id'] ?? '';
    var isVerified = json['user_profile']['is_verified'] ?? false;
    var role = json['user_profile']['role'] ?? '';

    // Dynamically parse the user profile based on the role
    dynamic userProfile;
    userProfile = UserProfile(
      name: name,
      email: email,
      noTelp: noTelp,
      role: role,
      profilePicture: profilePicture,
      profilePictureId: profilePictureId,
      isVerified: isVerified,
    );

    return User(
      role: role,
      userProfile: userProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "user_profile": userProfile.toJson(),
    };
  }
}

class SellerProfile {
  int totalSales;
  double rating;
  UserProfile userProfile;

  SellerProfile({
    required this.totalSales,
    required this.rating,
    required this.userProfile,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      totalSales: json['total_sales'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      userProfile: UserProfile.fromJson(json['user_profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'rating': rating,
      'user_profile': userProfile.toJson(),
    };
  }
}

class BuyerProfile {
  UserProfile userProfile;

  BuyerProfile({
    required this.userProfile,
  });

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    return BuyerProfile(
      userProfile: UserProfile.fromJson(json['user_profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_profile': userProfile.toJson(),
    };
  }
}

class AdminProfile {
  UserProfile userProfile;

  AdminProfile({
    required this.userProfile,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      userProfile: UserProfile.fromJson(json['user_profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_profile': userProfile.toJson(),
    };
  }
}
class UserProfile {
  String name;
  String email;
  String noTelp;
  String role;
  String profilePicture;
  String profilePictureId;
  bool isVerified;

  UserProfile({
    required this.name,
    required this.email,
    required this.noTelp,
    required this.role,
    required this.profilePicture,
    required this.profilePictureId,
    required this.isVerified,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String profilePicture = json['profile_picture'] ?? '';
    if (profilePicture == 'None') {
      profilePicture = 'assets/default_profile_picture.png';
    }

    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      noTelp: json['no_telp'] ?? '',
      role: json['role'] ?? '',
      profilePicture: profilePicture,
      profilePictureId: json['profile_picture_id'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'no_telp': noTelp,
      'role': role,
      'profile_picture': profilePicture,
      'profile_picture_id': profilePictureId,
      'is_verified': isVerified,
    };
  }
}
