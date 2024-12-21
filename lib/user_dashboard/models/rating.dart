class Rating {
  final int rating;
  final String review;
  final String reviewer;
  final String reviewerPicture;
  final String createdAt;

  Rating({required this.rating, required this.review, required this.reviewer, required this.reviewerPicture, required this.createdAt});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'],
      review: json['review'],
      reviewer: json['reviewer'],
      reviewerPicture: json['reviewerPicture'] ?? "",
      createdAt: json['created_at'],
    );
  }
}