import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/widgets/review_card.dart';

class ReviewsPage extends StatefulWidget {
  final String username; // Accepting username as a parameter

  const ReviewsPage({Key? key, required this.username}) : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  Future<List<ReviewRating>> fetchReviews(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/profile/${widget.username}/show_json/',
      );
      var data = response;

      List<ReviewRating> listReview = [];
      for (var d in data) {
        if (d != null) {
          listReview.add(ReviewRating.fromJson(d));
        }
      }
      return listReview;
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E7FF),
      appBar: AppBar(
        title: Text('Reviews for ${widget.username}'),
        backgroundColor: const Color(0xFF4C8BF5),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<ReviewRating>>(
            future: fetchReviews(CookieRequest()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading reviews: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No reviews available.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              } else {
                List<ReviewRating> reviews = snapshot.data!.toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'All Reviews',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C8BF5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...reviews.map((review) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ReviewCard(
                            name: review.fields.reviewer.userProfile.name,
                            profilePicture: review
                                .fields.reviewer.userProfile.profilePicture,
                            review: review.fields.review,
                            rating: review.fields.rating.toDouble(),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}