// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
    String username;
    String name;
    String email;
    String noTelp;
    String role;
    String roleDisplay;
    String profilePicture;
    String profilePictureId;
    bool isVerified;

    UserProfile({
        required this.username,
        required this.name,
        required this.email,
        required this.noTelp,
        required this.role,
        required this.roleDisplay,
        required this.profilePicture,
        required this.profilePictureId,
        required this.isVerified,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json["username"],
        name: json["name"],
        email: json["email"],
        noTelp: json["no_telp"],
        role: json["role"],
        roleDisplay: json["role_display"],
        profilePicture: json["profile_picture"] ?? "default_picture_url", // Default URL if not provided
        profilePictureId: json["profile_picture_id"],
        isVerified: json["is_verified"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "email": email,
        "no_telp": noTelp,
        "role": role,
        "role_display": roleDisplay,
        "profile_picture": profilePicture,
        "profile_picture_id": profilePictureId,
        "is_verified": isVerified,
    };
}
