import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/screens/profile.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/review_rating/widgets/review_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';
import 'package:provider/provider.dart';

class AllReviewsScreen extends StatefulWidget {
  final String username;
  final List<ReviewRating> reviews;

  const AllReviewsScreen({
    Key? key,
    required this.username,
    required this.reviews,
  }) : super(key: key);

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final authService = AuthService();
  late Future<List<ReviewRating>> reviewsFuture;
  final String baseUrl = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id";

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<List<ReviewRating>> fetchReviews(CookieRequest request) async {
    try {
      final response = await request.get(
        '$baseUrl/profile/${widget.username}/show_json/',
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

  Future<void> refreshData() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      reviewsFuture = fetchReviews(request);
    });
  }

  void _showReviewModal(BuildContext context, CookieRequest request) {
    final TextEditingController reviewController = TextEditingController();
    int _rating = 0;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          modalSetState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      modalSetState(() {
                        errorMessage = null;
                      });

                      if (_rating == 0) {
                        modalSetState(() {
                          errorMessage = 'Please select a rating.';
                        });
                        return;
                      }

                      if (reviewController.text.trim().isEmpty) {
                        modalSetState(() {
                          errorMessage = 'Review text cannot be empty.';
                        });
                        return;
                      }

                      try {
                        String? currentUsername =
                            (await authService.getUserData())['username'];

                        await submitReview(
                          request: request,
                          reviewedUsername: widget.username,
                          reviewerUsername: currentUsername!,
                          rating: _rating,
                          reviewText: reviewController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Review submitted successfully!')),
                          );
                          refreshData();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to submit review: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Submit Review'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> submitReview({
    required CookieRequest request,
    required String reviewedUsername,
    required String reviewerUsername,
    required int rating,
    required String reviewText,
  }) async {
    await request.post(
      '$baseUrl/profile/$reviewedUsername/add_review_flutter/',
      {
        'reviewee_username': reviewedUsername,
        'reviewer_username': reviewerUsername,
        'rating': rating.toString(),
        'review': reviewText,
      },
    );
    refreshData();
  }

  void _deleteReview(
      BuildContext context, CookieRequest request, String reviewId) async {
    try {
      final response = await request
          .post('$baseUrl/profile/delete_review_flutter/$reviewId/', {});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        refreshData();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showDeleteConfirmationDialog(
      String reviewId, BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteReview(context, request, reviewId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFD8E7FF),
      appBar: appBar(context, 'Reviews for ${widget.username}', true),
      body: FutureBuilder<List<ReviewRating>>(
        key: ValueKey(DateTime.now()),
        future: fetchReviews(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading reviews: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reviews available.'));
          }

          List<ReviewRating> reviews = snapshot.data!;
          List<ReviewRating> displayedReviews = reviews.toList();

          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.all(16.0), // Add padding for better spacing
              child: Column(
                children: displayedReviews.map((review) {
                  return FutureBuilder<Map<String, String?>>(
                    future: authService.getUserData(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      String? currentUsername = userSnapshot.data!['username'];
                      String? currentUserRole = userSnapshot.data!['role'];
                      bool canDelete = currentUsername ==
                              review.fields.reviewer.userProfile.name ||
                          currentUserRole == 'ADM';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ReviewCard(
                          name: review.fields.reviewer.userProfile.name,
                          profilePicture:
                              review.fields.reviewer.userProfile.profilePicture,
                          review: review.fields.review,
                          rating: review.fields.rating,
                          canDelete: canDelete,
                          reviewId: review.fields.id,
                          deleteReview: () {
                            showDeleteConfirmationDialog(
                                review.fields.id, context, request);
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReviewModal(context, request);
        },
        backgroundColor: const Color(0xFF4C8BF5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
