// To parse this JSON data, do
//
//     final reviewRating = reviewRatingFromJson(jsonString);

import 'dart:convert';

List<ReviewRating> reviewRatingFromJson(String str) => List<ReviewRating>.from(json.decode(str).map((x) => ReviewRating.fromJson(x)));

String reviewRatingToJson(List<ReviewRating> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewRating {
    String model;
    String pk;
    Fields fields;

    ReviewRating({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ReviewRating.fromJson(Map<String, dynamic> json) => ReviewRating(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int rating;
    String review;
    bool canDelete;
    Reviewer reviewer;

    Fields({
        required this.rating,
        required this.review,
        required this.canDelete,
        required this.reviewer,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        rating: json["rating"],
        review: json["review"],
        canDelete: json["can_delete"],
        reviewer: Reviewer.fromJson(json["reviewer"]),
    );

    Map<String, dynamic> toJson() => {
        "rating": rating,
        "review": review,
        "can_delete": canDelete,
        "reviewer": reviewer.toJson(),
    };
}

class Reviewer {
    UserProfile userProfile;

    Reviewer({
        required this.userProfile,
    });

    factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        userProfile: UserProfile.fromJson(json["user_profile"]),
    );

    Map<String, dynamic> toJson() => {
        "user_profile": userProfile.toJson(),
    };
}

class UserProfile {
    String profilePicture;
    User user;

    UserProfile({
        required this.profilePicture,
        required this.user,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        profilePicture: json["profile_picture"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "profile_picture": profilePicture,
        "user": user.toJson(),
    };
}

class User {
    String username;

    User({
        required this.username,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
    };
}
