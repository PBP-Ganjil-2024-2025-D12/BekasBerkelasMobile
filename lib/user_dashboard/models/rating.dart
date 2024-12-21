class Rating {
  final int rating;
  final String review;
  final String reviewer;
  final String reviewerPicture;

  Rating({required this.rating, required this.review, required this.reviewer, required this.reviewerPicture});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'],
      review: json['review'],
      reviewer: json['reviewer'],
      reviewerPicture: json['reviewerPicture'] ?? "",
    );
  }
}