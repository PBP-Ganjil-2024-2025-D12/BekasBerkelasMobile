// To parse this JSON data, do
//
//     final reviewRating = reviewRatingFromJson(jsonString);

import 'dart:convert';

List<ReviewRating> reviewRatingFromJson(String str) => List<ReviewRating>.from(json.decode(str).map((x) => ReviewRating.fromJson(x)));

String reviewRatingToJson(List<ReviewRating> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewRating {
    Fields fields;

    ReviewRating({
        required this.fields,
    });

    factory ReviewRating.fromJson(Map<String, dynamic> json) => ReviewRating(
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "fields": fields.toJson(),
    };
}

class Fields {
    int rating;
    String review;
    String id;
    bool canDelete;
    Reviewer reviewer;

    Fields({
        required this.rating,
        required this.review,
        required this.id,
        required this.canDelete,
        required this.reviewer,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        rating: json["rating"],
        review: json["review"],
        id: json["id"],
        canDelete: json["can_delete"],
        reviewer: Reviewer.fromJson(json["reviewer"]),
    );

    Map<String, dynamic> toJson() => {
        "rating": rating,
        "review": review,
        "id": id,
        "can_delete": canDelete,
        "reviewer": reviewer.toJson(),
    };
}

class Reviewer {
    UserProfileForReview userProfile;

    Reviewer({
        required this.userProfile,
    });

    factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        userProfile: UserProfileForReview.fromJson(json["user_profile"]),
    );

    Map<String, dynamic> toJson() => {
        "user_profile": userProfile.toJson(),
    };
}

class UserProfileForReview {
    String name;
    String? profilePicture;

    UserProfileForReview({
        required this.name,
        this.profilePicture,
    });

    factory UserProfileForReview.fromJson(Map<String, dynamic> json) => UserProfileForReview(
        name: json["name"],
        profilePicture: json["profile_picture"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "profile_picture": profilePicture,
    };
}